import { DynamoDBClient, DeleteItemCommand } from "@aws-sdk/client-dynamodb";
import { EventBridgeClient, PutEventsCommand } from "@aws-sdk/client-eventbridge";

const db = new DynamoDBClient({});
const eb = new EventBridgeClient({});

export const handler = async (event) => {
  try {
    const itemId = event.pathParameters?.id;
    
    await db.send(new DeleteItemCommand({
      TableName: process.env.TABLE_NAME,
      Key: { id: { S: itemId } }
    }));
    
    await eb.send(new PutEventsCommand({
      Entries: [{
        EventBusName: process.env.EVENT_BUS_NAME,
        Source: "items.api",
        DetailType: "ItemDeleted",
        Detail: JSON.stringify({
          itemId: itemId,
          action: "delete",
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
      body: JSON.stringify({ message: "Item deleted successfully", id: itemId })
    };
  } catch (error) {
    console.error("Error deleting item:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to delete item" })
    };
  }
};