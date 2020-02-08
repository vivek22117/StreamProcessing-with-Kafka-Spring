package com.ddsolutions.kafka.handler;

import com.ddsolutions.kafka.publisher.RSVPKafkaPublisher;
import com.ddsolutions.kafka.publisher.RSVPKinesisPublisher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;

@Component
public class RSVPWebSocketHandler extends AbstractWebSocketHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(RSVPWebSocketHandler.class);

    private RSVPKafkaPublisher kafkaPublisher;
    private RSVPKinesisPublisher kinesisPublisher;

    @Autowired
    public RSVPWebSocketHandler(RSVPKafkaPublisher kafkaPublisher, RSVPKinesisPublisher kinesisPublisher) {
        this.kafkaPublisher = kafkaPublisher;
        this.kinesisPublisher = kinesisPublisher;
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        try {
//            kafkaPublisher.sendRSVPMessageByProducerRecord(message);
            kinesisPublisher.publish(message);
        } catch (Exception ex) {
            LOGGER.error("Processing failed while publishing message, {} to Kafka or Kinesis", message.getPayload(), ex);
        }
    }
}
