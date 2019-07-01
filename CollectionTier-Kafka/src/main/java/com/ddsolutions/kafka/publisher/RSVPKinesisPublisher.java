package com.ddsolutions.kafka.publisher;

import com.ddsolutions.kafka.domain.RSVPEventRecord;
import com.ddsolutions.kafka.utility.GzipUtility;
import com.ddsolutions.kafka.utility.JsonUtility;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketMessage;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class RSVPKinesisPublisher {
    private static final Logger LOGGER = LoggerFactory.getLogger(RSVPKinesisPublisher.class);

    private KinesisClient kinesisClient;
    private JsonUtility jsonUtility;

    @Value("${stream.name}")
    private String streamName;

    @Autowired
    public RSVPKinesisPublisher(KinesisClient kinesisClient, JsonUtility jsonUtility) {
        this.kinesisClient = kinesisClient;
        this.jsonUtility = jsonUtility;
    }

    public void publish(WebSocketMessage<?> message) {
       /* RSVPEventRecord rsvpEventRecord =
                jsonUtility.convertFromJson(message.getPayload().toString(), RSVPEventRecord.class);*/
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        RSVPEventRecord rsvpEventRecord = gson.fromJson(message.getPayload().toString(), RSVPEventRecord.class);
        List<RSVPEventRecord> rsvpEventRecords = Collections.singletonList(rsvpEventRecord);

        // Do some processing or enhancement of data
        List<PutRecordsRequestEntry> requestEntries = rsvpEventRecords.stream()
                .map(record -> {
                    try {
                        return jsonUtility.convertToString(rsvpEventRecord);
                    } catch (JsonProcessingException e) {
                        LOGGER.error("Unable to convert record into json object");
                        return null;
                    }
                })
                .filter(Objects::nonNull)
                .map(GzipUtility::serializeData).filter(Objects::nonNull)
                .map(GzipUtility::compressData).filter(Objects::nonNull)
                .map(data ->
                        PutRecordsRequestEntry.builder()
                                .partitionKey(UUID.randomUUID().toString())
                                .data(SdkBytes.fromByteArray(data))
                                .build()).collect(Collectors.toList());

        PutRecordsRequest putRecordsRequest =
                PutRecordsRequest.builder().streamName(streamName).records(requestEntries).build();
        PutRecordsResponse putRecordsResponse = kinesisClient.putRecords(putRecordsRequest);
        if (putRecordsResponse == null || putRecordsResponse.failedRecordCount() > 0) {
            LOGGER.error("Failed to publish records...");
        }
        LOGGER.debug("RSVP event published successfully..");
    }
}
