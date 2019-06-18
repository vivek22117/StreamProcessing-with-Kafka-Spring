package com.ddsolutions.kafka.handler;

import com.ddsolutions.kafka.publisher.RSVPKafkaPublisher;
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

    @Autowired
    public RSVPWebSocketHandler(RSVPKafkaPublisher kafkaPublisher) {
        this.kafkaPublisher = kafkaPublisher;
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        kafkaPublisher.sendRSVPMessageByProducerRecord(message);
    }
}
