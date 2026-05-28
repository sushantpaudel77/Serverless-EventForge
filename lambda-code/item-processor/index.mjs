import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";

const db = new DynamoDBClient({});

export const handler = async (event) => {
  const failures = [];
  
  for (const record of event.Records) {
    try {
      const sqsBody = JSON.parse(record.body);
      let itemData;
      
      if (sqsBody.Message) {
        itemData = JSON.parse(sqsBody.Message);
      } else {
        itemData = sqsBody;
      }
      
      const auditRecord = {
        id: crypto.randomUUID(),
        itemId: itemData.itemId,
        action: itemData.action,
        eventType: itemData.eventType,
        sourceTimestamp: itemData.timestamp,
        processedAt: new Date().toISOString(),
        source: itemData.source || "unknown"
      };
      
      await db.send(new PutItemCommand({
        TableName: process.env.AUDIT_TABLE,
        Item: marshall(auditRecord)
      }));
      
      console.log(`Audit record created for item: ${itemData.itemId}`);
    } catch (error) {
      console.error("Failed to process message:", error);
      failures.push({ itemIdentifier: record.messageId });
    }
  }
  
  return { batchItemFailures: failures };
};