package com.ddsolutions.kafka.publisher;

import com.amazonaws.services.kinesis.producer.Attempt;
import com.amazonaws.services.kinesis.producer.KinesisProducer;
import com.amazonaws.services.kinesis.producer.UserRecordFailedException;
import com.amazonaws.services.kinesis.producer.UserRecordResult;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class RSVPKCLPublisherImpl implements RSVPKCLPublisher {
    private static final Logger LOGGER = LoggerFactory.getLogger(RSVPKCLPublisherImpl.class);

    private final KinesisProducer kinesisProducer;

    @Value("${stream.name}")
    private String streamName;

    // The number of records that have finished (either successfully put, or failed)
    final AtomicLong completed = new AtomicLong(0);
    private static final String TIMESTAMP_AS_PARTITION_KEY = Long.toString(System.currentTimeMillis());

    @Autowired
    public RSVPKCLPublisherImpl(KinesisProducer kinesisProducer) {
        this.kinesisProducer = kinesisProducer;
    }

    @Override
    public void publishDataIntoKinesis(String payload) throws Exception {
        FutureCallback<UserRecordResult> futureCallback = new FutureCallback<UserRecordResult>() {

            @Override
            public void onFailure(Throwable t) {

                // If we see any failures, we will log them.
                int attempts = ((UserRecordFailedException) t).getResult().getAttempts().size() - 1;
                Attempt last =
                        ((UserRecordFailedException) t).getResult().getAttempts().get(attempts);
                if (attempts > 1) {
                    Attempt previous = ((UserRecordFailedException) t).getResult().getAttempts()
                            .get(attempts - 1);
                    LOGGER.error(String.format(
                            "Failed to put record - %s : %s. Previous failure - %s : %s",
                            last.getErrorCode(), last.getErrorMessage(),
                            previous.getErrorCode(), previous.getErrorMessage()));
                } else {
                    LOGGER.error(String.format("Failed to put record - %s : %s.",
                            last.getErrorCode(), last.getErrorMessage()));
                }

                LOGGER.error("Exception during put", t);
            }

            @Override
            public void onSuccess(UserRecordResult result) {

                assert result != null;
                long totalTime = result.getAttempts().stream()
                        .mapToLong(a -> a.getDelay() + a.getDuration()).sum();

                LOGGER.info("Data writing success. Total time taken to write data = {}", totalTime);

                completed.getAndIncrement();
            }
        };


        final ExecutorService callbackThreadPool = Executors.newCachedThreadPool();
        ByteBuffer data = null;
        data = ByteBuffer.wrap(payload.getBytes(StandardCharsets.UTF_8));

        while (kinesisProducer.getOutstandingRecordsCount() > 1) {
            Thread.sleep(1);
        }

        ListenableFuture<UserRecordResult> result =
                kinesisProducer.addUserRecord(streamName, TIMESTAMP_AS_PARTITION_KEY, data);
        Futures.addCallback(result, futureCallback, callbackThreadPool);

    }

    @Override
    public void stop() {
        if (kinesisProducer != null) {
            kinesisProducer.flushSync();
            kinesisProducer.destroy();
        }
    }
}
