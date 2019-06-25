package com.ddsolutions.kafka.twitter.publisher;

import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class KafkaPublisher {

    private static final Logger LOGGER = LoggerFactory.getLogger(KafkaPublisher.class);

    private KafkaTemplate<String, Object> kafkaTemplate;
    private KafkaProducer<String, String> kafkaProducer;
    private NewTopic kafkaTopic;

    public KafkaPublisher(KafkaTemplate<String, Object> kafkaTemplate, NewTopic kafkaTopic,
                          KafkaProducer<String, String> kafkaProducer) {
        this.kafkaTemplate = kafkaTemplate;
        this.kafkaTopic = kafkaTopic;
        this.kafkaProducer = kafkaProducer;
    }

    public void publishTwitterTweets(String tweet) {
        ProducerRecord<String, String> producerRecord = new ProducerRecord<>(kafkaTopic.name(), "null", tweet);

        //add shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            LOGGER.info("closing kafka producer....");
            kafkaProducer.close();
            LOGGER.info("DONE!");
        }));

        kafkaProducer.send(producerRecord, new Callback() {
            @Override
            public void onCompletion(RecordMetadata recordMetadata, Exception e) {
                if (e != null) {
                    LOGGER.error("Error while publishing rsvp: ", e);
                } else {
                    LOGGER.info("Received metadata: \n" +
                            "TopicName:" + recordMetadata.topic() + "\n" +
                            "Partition:" + recordMetadata.partition() + "\n" +
                            "Offset:" + recordMetadata.offset() + "\n" +
                            "Timestamp:" + recordMetadata.timestamp());
                }
            }
        });
    }
}
