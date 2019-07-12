package com.ddsolutins.kafka.consumer.publisher;

import com.google.gson.JsonParser;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.elasticsearch.action.bulk.BulkRequest;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.xcontent.XContentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.util.Optional;

public class ElasticSearchPublisher {
    private static final Logger LOGGER = LoggerFactory.getLogger(ElasticSearchPublisher.class);

    private RestHighLevelClient client;
    private JsonParser jsonParser;

    @Value("${el.search.index}")
    private String indexName;

    @Autowired
    public ElasticSearchPublisher(RestHighLevelClient client, JsonParser jsonParser) {
        this.client = client;
        this.jsonParser = jsonParser;
    }

    public void publishToElasticSearch(ConsumerRecord<String, Object> record) {
        //Create unique id for each record using kafka
        //String id = record.topic() + "_" + record.partition() + "_" + record.offset();
        try {
            //If you have unique id for each record then use it for idempotent
            String id = extractId(record.value().toString());

            IndexRequest request = new IndexRequest(indexName, "tweets", id)   //id is used to make our consumer idempotent
                    .source(record.value(), XContentType.JSON);

            IndexResponse response = null;

            response = client.index(request, RequestOptions.DEFAULT);
            LOGGER.info(response.getId());
        } catch (IOException | NullPointerException e) {
            LOGGER.error("Unable to publish tweets on elastic search {}", record.value());
        }
    }

    public void publishBulkRecordsToElasticSearch(BulkRequest bulkRequests) throws IOException {
        BulkResponse bulkResponse = client.bulk(bulkRequests, RequestOptions.DEFAULT);
    }

    public Optional<IndexRequest> createBulkRequest(ConsumerRecord<String, Object> record) {
        try {
            String id = extractId(record.value().toString());
            return Optional.ofNullable(new IndexRequest(indexName, "tweets", id)   //id is used to make our consumer idempotent
                    .source(record.value(), XContentType.JSON));
        } catch (NullPointerException e) {
            LOGGER.error("Unable to publish bad data {}", record.value());
        }
        return Optional.empty();
    }

    private String extractId(String jsonTweet) {
        //using gson to extract id
        return jsonParser.parse(jsonTweet)
                .getAsJsonObject()
                .get("id_str")
                .getAsString();
    }
}
