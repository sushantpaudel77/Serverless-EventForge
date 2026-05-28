import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

const sns = new SNSClient({});

export const handler = async (event) => {
  const failures = [];

  for (const record of event.Records) {
    try {
      const sqsMessage = JSON.parse(record.body);
      const detail = sqsMessage.detail || {};

      await sns.send(
        new PublishCommand({
          TopicArn: process.env.SNS_TOPIC_ARN,
          Subject: `Item ${detail.action}: ${detail.itemId}`,
          Message: JSON.stringify({
            itemId: detail.itemId,
            action: detail.action,
            timestamp: detail.timestamp,
            eventType: sqsMessage['detail-type'],
          }),
        })
      );

      console.log(`Published to SNS: ${detail.action} on ${detail.itemId}`);
    } catch (error) {
      console.error('Error processing record:', error);
      failures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures: failures };
};
