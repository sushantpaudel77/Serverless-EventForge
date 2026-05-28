// lambda-code/update-item/index.mjs
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import { EventBridgeClient, PutEventsCommand } from "@aws-sdk/client-eventbridge";

const db = new DynamoDBClient({});
const eb = new EventBridgeClient({});

// Same sanitization as create-item
function sanitizeInput(input) {
  if (typeof input !== 'string') return input;
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}

export const handler = async (event) => {
  try {
    const itemId = event.pathParameters?.id;
    const body = JSON.parse(event.body || "{}");
    
    let updateExpression = "SET";
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};
    
    Object.keys(body).forEach((key, index) => {
      if (key === "id") return;
      const prefix = index === 0 ? " " : ", ";
      updateExpression += `${prefix}#${key} = :${key}`;
      expressionAttributeNames[`#${key}`] = key;
      // Sanitize each value
      expressionAttributeValues[`:${key}`] = sanitizeInput(body[key]);
    });
    
    updateExpression += ", #updatedAt = :updatedAt";
    expressionAttributeNames["#updatedAt"] = "updatedAt";
    expressionAttributeValues[":updatedAt"] = new Date().toISOString();
    
    const result = await db.send(new UpdateItemCommand({
      TableName: process.env.TABLE_NAME,
      Key: { id: { S: itemId } },
      UpdateExpression: updateExpression,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: marshall(expressionAttributeValues),
      ReturnValues: "ALL_NEW"
    }));
    
    await eb.send(new PutEventsCommand({
      Entries: [{
        EventBusName: process.env.EVENT_BUS_NAME,
        Source: "items.api",
        DetailType: "ItemUpdated",
        Detail: JSON.stringify({
          itemId: itemId,
          action: "update",
          timestamp: new Date().toISOString()
        })
      }]
    }));
    
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(result.Attributes)
    };
  } catch (error) {
    console.error("Error updating item:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to update item" })
    };
  }
};