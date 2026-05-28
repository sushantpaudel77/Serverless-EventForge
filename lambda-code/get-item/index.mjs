import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

const client = new DynamoDBClient({});

export const handler = async (event) => {
  try {
    const itemId = event.pathParameters?.id;
    
    const command = new GetItemCommand({
      TableName: process.env.TABLE_NAME,
      Key: {
        id: { S: itemId }
      }
    });
    
    const result = await client.send(command);
    
    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "Item not found" })
      };
    }
    
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(unmarshall(result.Item))
    };
  } catch (error) {
    console.error("Error getting item:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to get item" })
    };
  }
};