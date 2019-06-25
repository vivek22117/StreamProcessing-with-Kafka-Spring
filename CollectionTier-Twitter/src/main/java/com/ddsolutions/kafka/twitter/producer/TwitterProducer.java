package com.ddsolutions.kafka.twitter.producer;

import com.ddsolutions.kafka.twitter.publisher.KafkaPublisher;
import com.google.common.collect.Lists;
import com.twitter.hbc.ClientBuilder;
import com.twitter.hbc.core.Client;
import com.twitter.hbc.core.Constants;
import com.twitter.hbc.core.Hosts;
import com.twitter.hbc.core.HttpHosts;
import com.twitter.hbc.core.endpoint.StatusesFilterEndpoint;
import com.twitter.hbc.core.processor.StringDelimitedProcessor;
import com.twitter.hbc.httpclient.BasicClient;
import com.twitter.hbc.httpclient.auth.Authentication;
import com.twitter.hbc.httpclient.auth.OAuth1;
import org.apache.kafka.clients.admin.NewTopic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

@Service
public class TwitterProducer {

    private static final Logger LOGGER = LoggerFactory.getLogger(TwitterProducer.class);

    @Autowired
    private BlockingQueue<String> msgQueue;

    private KafkaPublisher kafkaPublisher;
    private Client twitterClient;
    private NewTopic topic;

    @Value("${kafka.consumerKey}")
    private String consumerKey;
    @Value("${kafka.consumerSecret}")
    private String consumerSecret;
    @Value("${kafka.token}")
    private String token;
    @Value("${kafka.secret}")
    private String secret;

    @Autowired
    public TwitterProducer(KafkaPublisher kafkaPublisher, Client twitterClient, NewTopic topic) {
        this.kafkaPublisher = kafkaPublisher;
        this.twitterClient = twitterClient;
        this.topic = topic;
    }

    public void publishToKafka() {
        // Set up your blocking queues: Be sure to size these properly based on expected TPS of your stream */
        // BlockingQueue<String> msgQueue = new LinkedBlockingQueue<String>(1000);
        // Client twitterClient = createTwitterClient(msgQueue);
        twitterClient.connect();

        // add shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            LOGGER.info("stopping application...");
            LOGGER.info("closing twitter client...");
            twitterClient.stop();
        }));

        while (!twitterClient.isDone()) {
            String msg = null;

            try {
                msg = msgQueue.poll(5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                LOGGER.error("Polling interrupted", e);
                twitterClient.stop();
            }
            if (msg != null) {
                LOGGER.info(msg);
                kafkaPublisher.publishTwitterTweets(msg);
            }
        }
        LOGGER.info("End of polling");
    }
}
