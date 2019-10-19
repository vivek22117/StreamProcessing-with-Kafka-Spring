package com.ddsolutions.kafka;

import com.ddsolutions.kafka.handler.RSVPWebSocketHandler;
import com.ddsolutions.kafka.publisher.RSVPKafkaPublisher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;

@SpringBootApplication
public class RSVPCollectionApplication {

    private static final String MEETUP_RSVP_ENDPOINT = "ws://stream.meetup.com/2/rsvps";

    public static void main(String[] args) {
        SpringApplication.run(RSVPCollectionApplication.class, args);
    }

    @Bean
    public ApplicationRunner init(RSVPWebSocketHandler handler){
        return new ApplicationRunner() {
            @Override
            public void run(ApplicationArguments args) throws Exception {
                WebSocketClient client = new StandardWebSocketClient();
                client.doHandshake(handler, MEETUP_RSVP_ENDPOINT);
            }
        };

    }
}
