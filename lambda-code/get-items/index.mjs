import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

const client = new DynamoDBClient({});

export const handler = async (event) => {
  try {
    const command = new ScanCommand({
      TableName: process.env.TABLE_NAME
    });
    
    const result = await client.send(command);
    const items = result.Items.map(item => unmarshall(item));
    
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(items)
    };
  } catch (error) {
    console.error("Error scanning items:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch items" })
    };
  }
};