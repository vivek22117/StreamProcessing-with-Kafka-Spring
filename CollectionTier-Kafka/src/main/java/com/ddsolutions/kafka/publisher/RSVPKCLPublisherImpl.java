package com.ddsolutions.kafka.publisher;

import com.amazonaws.services.kinesis.producer.KinesisProducer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class RSVPKCLPublisherImpl implements RSVPKCLPublisher {
    private static final Logger LOGGER = LoggerFactory.getLogger(RSVPKCLPublisherImpl.class);

    private final KinesisProducer kinesisProducer;

    @Value("${stream.name}")
    private String streamName;

    @Autowired
    public RSVPKCLPublisherImpl(KinesisProducer kinesisProducer) {
        this.kinesisProducer = kinesisProducer;
    }

    @Override
    public void publishDataIntoKinesis(String payload) throws Exception {

    }

    @Override
    public void stop() {

    }
}
