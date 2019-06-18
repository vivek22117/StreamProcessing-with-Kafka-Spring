package com.ddsolutions.kafka.twitter;

import com.ddsolutions.kafka.twitter.producer.TwitterProducer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class TwitterStreamApplication {

    @Autowired
    private TwitterProducer twitterProducer;

    public static void main(String[] args) {
        SpringApplication.run(TwitterStreamApplication.class, args);
    }

    @Bean
    public ApplicationRunner init(){
        return new ApplicationRunner() {
            @Override
            public void run(ApplicationArguments args) throws Exception {
                twitterProducer.publishToKafka();
            }
        };
    }
}
