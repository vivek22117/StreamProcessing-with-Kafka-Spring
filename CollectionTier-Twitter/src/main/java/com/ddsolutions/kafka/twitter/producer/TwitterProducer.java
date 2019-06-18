package com.ddsolutions.kafka.twitter.producer;

import com.twitter.hbc.ClientBuilder;
import com.twitter.hbc.core.Client;
import com.twitter.hbc.core.processor.StringDelimitedProcessor;
import org.apache.kafka.clients.admin.NewTopic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

@Service
public class TwitterProducer {

    private static final Logger LOGGER = LoggerFactory.getLogger(TwitterProducer.class);

    private ClientBuilder clientBuilder;
    private KafkaTemplate<String, Object> kafkaTemplate;
    private NewTopic topic;

    @Autowired
    public TwitterProducer(ClientBuilder clientBuilder, KafkaTemplate<String, Object> kafkaTemplate,
                           NewTopic topic) {
        this.clientBuilder = clientBuilder;
        this.kafkaTemplate = kafkaTemplate;
        this.topic = topic;
    }

    public void publishToKafka() {
        // Set up your blocking queues: Be sure to size these properly based on expected TPS of your stream */
        BlockingQueue<String> msgQueue = new LinkedBlockingQueue<String>(1000);
        Client client = clientBuilder.processor(new StringDelimitedProcessor(msgQueue)).build();

        while (!client.isDone()) {
            String msg = null;

            try {
                msg = msgQueue.poll(5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                LOGGER.error("Polling interrupted", e);
                client.stop();
            }
            if (msg != null) {
                LOGGER.info(msg);
            }
        }
        LOGGER.info("End of polling");
    }
}
