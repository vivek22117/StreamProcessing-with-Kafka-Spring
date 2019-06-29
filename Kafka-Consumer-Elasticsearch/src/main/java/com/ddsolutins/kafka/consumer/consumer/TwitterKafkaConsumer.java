package com.ddsolutins.kafka.consumer.consumer;

import com.ddsolutins.kafka.consumer.publisher.ElasticSearchPublisher;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.elasticsearch.action.bulk.BulkRequest;
import org.elasticsearch.action.index.IndexRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.time.Duration;
import java.util.Arrays;
import java.util.function.Consumer;

public class TwitterKafkaConsumer {

    private static final Logger LOGGER = LoggerFactory.getLogger(TwitterKafkaConsumer.class);

    private KafkaConsumer<String, Object> kafkaConsumer;
    private ElasticSearchPublisher publisher;

    @Value("${kafka.topic}")
    private String kafkaTopic;

    @Autowired
    public TwitterKafkaConsumer(KafkaConsumer<String, Object> kafkaConsumer, ElasticSearchPublisher publisher) {
        this.kafkaConsumer = kafkaConsumer;
        this.publisher = publisher;
    }

    public void consumeTwitterTweets() throws IOException {
        kafkaConsumer.subscribe(Arrays.asList(kafkaTopic));

        while (true) {
            ConsumerRecords<String, Object> consumerRecords = kafkaConsumer.poll(Duration.ofMillis(5000));
            //Only for bulk publisher
            BulkRequest bulkRequest = new BulkRequest();

            Integer recordCount = consumerRecords.count();
            LOGGER.debug("Received " + recordCount + " records");

            for (ConsumerRecord<String, Object> record : consumerRecords) {
                //single record at a time
                publisher.publishToElasticSearch(record);

                //using bulk publisher
                publisher.createBulkRequest(record).ifPresent(new Consumer<IndexRequest>() {
                    @Override
                    public void accept(IndexRequest request) {
                        bulkRequest.add(request);
                    }
                });
            }
            if (recordCount > 0) {
                publisher.publishBulkRecordsToElasticSearch(bulkRequest);
                kafkaConsumer.commitSync();
                LOGGER.debug("Offset has been committed");
            }
        }
    }
}
