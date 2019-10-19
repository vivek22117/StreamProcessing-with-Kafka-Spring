package com.ddsolutions.kafka.publisher;

import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.util.concurrent.ListenableFutureCallback;
import org.springframework.web.socket.WebSocketMessage;

@Component
public class RSVPKafkaPublisher {

    private static final Logger LOGGER = LoggerFactory.getLogger(RSVPKafkaPublisher.class);

    @Value("${kafka.rsvp.topic}")
    private String topicName;

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final KafkaProducer<String, Object> kafkaProducer;
    private final NewTopic topic;

    @Autowired
    public RSVPKafkaPublisher(
            final KafkaProducer<String, Object> kafkaProducer,
            final KafkaTemplate<String, Object> kafkaTemplate,
            final NewTopic topic){
        this.kafkaProducer = kafkaProducer;
        this.kafkaTemplate = kafkaTemplate;
        this.topic = topic;
    }

    public void sendRSVPMessages(WebSocketMessage<?> rsvpMessage){
        ListenableFuture<SendResult<String, Object>> result =
                kafkaTemplate.send(topic.name(), rsvpMessage);

    }

    public void sendRSVPMessageByProducerRecord(WebSocketMessage<?> rsvpMessage) {
        ProducerRecord<String, Object> producerRecord = new ProducerRecord<>(topicName, rsvpMessage.getPayload().toString());

        kafkaTemplate.send(producerRecord)
                .addCallback(new ListenableFutureCallback<SendResult<String, Object>>() {
            @Override
            public void onSuccess(SendResult<String, Object> stringObjectSendResult) {
                RecordMetadata recordMetadata = stringObjectSendResult.getRecordMetadata();

                LOGGER.info("Received metadata: \n" +
                        "TopicName:" + recordMetadata.topic() + "\n" +
                        "Partition:" + recordMetadata.partition() + "\n" +
                        "Offset:" + recordMetadata.offset() + "\n" +
                        "Timestamp:" + recordMetadata.timestamp());
            }

            @Override
            public void onFailure(Throwable throwable) {
                LOGGER.error("Error while publishing rsvp to kafka: ", throwable);
            }
        });

    }

    public void sendRSVPMessageWithCallBack(WebSocketMessage<?> rsvpMessage){
        ProducerRecord<String, Object> producerRecord = new ProducerRecord<>(topicName, rsvpMessage);
        kafkaProducer.send(producerRecord, new Callback() {
            @Override
            public void onCompletion(RecordMetadata recordMetadata, Exception e) {
                if (e != null){
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
