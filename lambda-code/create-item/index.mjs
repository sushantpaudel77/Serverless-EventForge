import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import { EventBridgeClient, PutEventsCommand } from "@aws-sdk/client-eventbridge";

const db = new DynamoDBClient({});
const eb = new EventBridgeClient({});

// XSS sanitization function
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
    const body = JSON.parse(event.body || "{}");
    
    // Validate required fields
    if (!body.name || body.name.trim().length === 0) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Name is required" })
      };
    }
    
    // Sanitize inputs
    const sanitizedBody = {};
    for (const [key, value] of Object.entries(body)) {
      sanitizedBody[key] = sanitizeInput(value);
    }
    
    const item = {
      id: crypto.randomUUID(),
      ...sanitizedBody,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    await db.send(new PutItemCommand({
      TableName: process.env.TABLE_NAME,
      Item: marshall(item)
    }));
    
    await eb.send(new PutEventsCommand({
      Entries: [{
        EventBusName: process.env.EVENT_BUS_NAME,
        Source: "items.api",
        DetailType: "ItemCreated",
        Detail: JSON.stringify({
          itemId: item.id,
          action: "create",
          timestamp: item.createdAt
        })
      }]
    }));
    
    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(item)
    };
  } catch (error) {
    console.error("Error creating item:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to create item" })
    };
  }
};