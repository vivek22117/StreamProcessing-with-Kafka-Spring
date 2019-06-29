package com.ddsolutions.kafka.configuration;

import com.ddsolutions.kafka.kinesis.EventProcessorFactory;
import com.ddsolutions.kafka.kinesis.KinesisRecordProcessor;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisClient;
import software.amazon.kinesis.common.ConfigsBuilder;
import software.amazon.kinesis.coordinator.Scheduler;
import software.amazon.kinesis.leases.LeaseManagementConfig;
import software.amazon.kinesis.metrics.MetricsConfig;
import software.amazon.kinesis.metrics.MetricsLevel;
import software.amazon.kinesis.processor.ProcessorConfig;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.function.Supplier;

@Configuration
public class AppConfiguration {

    private final KafkaProperties kafkaProperties;
    private ApplicationContext applicationContext;

    @Value("${bootstrap.servers}")
    private String bootstrapServers;

    @Value("${kafka.rsvp.topic}")
    private String topicName;

    @Value("${stream.name}")
    private String streamName;

    @Value("${app.name}")
    private String appName;

    @Value("${table.name}")
    private String tableName;

    @Autowired
    public AppConfiguration(KafkaProperties kafkaProperties) {
        this.kafkaProperties = kafkaProperties;
    }

    @Bean
    public Supplier<KinesisRecordProcessor> createProcessor(){
        return () -> applicationContext.getBean(KinesisRecordProcessor.class);
    }

    @Bean
    public KinesisClient createPublisherClient(){
        return KinesisClient.builder().credentialsProvider(new AwsCredentialsProvider() {
            @Override
            public AwsCredentials resolveCredentials() {
                return InstanceProfileCredentialsProvider.create().resolveCredentials();
            }
        }).region(Region.US_EAST_1).build();
    }

    @Bean
    public KinesisAsyncClient createKinesisClient() {
        return KinesisAsyncClient.builder()
                .credentialsProvider(new AwsCredentialsProvider() {
                    @Override
                    public AwsCredentials resolveCredentials() {
                        return InstanceProfileCredentialsProvider.create().resolveCredentials();
                    }
                }).region(Region.US_EAST_1).build();
    }

    @Bean
    public DynamoDbAsyncClient createDynamoDBClient() {
        return DynamoDbAsyncClient.builder()
                .credentialsProvider(new AwsCredentialsProvider() {
                    @Override
                    public AwsCredentials resolveCredentials() {
                        return InstanceProfileCredentialsProvider.create().resolveCredentials();
                    }
                }).region(Region.US_EAST_1).build();
    }

    @Bean
    public CloudWatchAsyncClient createCloudWatchClient() {
        return CloudWatchAsyncClient.builder()
                .credentialsProvider(new AwsCredentialsProvider() {
                    @Override
                    public AwsCredentials resolveCredentials() {
                        return InstanceProfileCredentialsProvider.create().resolveCredentials();
                    }
                }).region(Region.US_EAST_1).build();
    }

    @Bean
    public ConfigsBuilder createConfigBuilder(KinesisAsyncClient kinesisAsyncClient,
                                              DynamoDbAsyncClient dynamoDbAsyncClient,
                                              CloudWatchAsyncClient cloudWatchAsyncClient) {
        return new ConfigsBuilder(streamName, appName, kinesisAsyncClient, dynamoDbAsyncClient,
                cloudWatchAsyncClient, UUID.randomUUID().toString(), new EventProcessorFactory(createProcessor()))
                .tableName(tableName);
    }

    @Bean
    public Scheduler creatScheduler(ConfigsBuilder configsBuilder){
        ProcessorConfig processorConfig = configsBuilder.processorConfig()
                .callProcessRecordsEvenForEmptyRecordList(true);
        MetricsConfig metricsConfig = configsBuilder.metricsConfig().metricsLevel(MetricsLevel.NONE);
        LeaseManagementConfig leaseManagementConfig = configsBuilder.leaseManagementConfig()
                .cleanupLeasesUponShardCompletion(true).maxLeasesForWorker(25).consistentReads(true);

        return new Scheduler(configsBuilder.checkpointConfig(), configsBuilder.coordinatorConfig(),
                leaseManagementConfig, configsBuilder.lifecycleConfig(),
                metricsConfig, processorConfig, configsBuilder.retrievalConfig());
    }

    @Bean
    public Map<String, Object> producerConfig() {
        Map<String, Object> props = new HashMap<>(kafkaProperties.buildProducerProperties());

        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // properties for kafka safe producer
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.toString(Integer.MAX_VALUE));
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, "5");

        //High Throughput ssetting
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
        props.put(ProducerConfig.LINGER_MS_CONFIG, "20");
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, Integer.toString(32 * 1024));

        return props;
    }

    @Bean
    public ProducerFactory<String, Object> producerFactory() {
        return new DefaultKafkaProducerFactory<>(producerConfig());
    }

    @Bean
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    @Bean
    public NewTopic createNewTopic() {
        return new NewTopic(topicName, 5, (short) 1);
    }

    @Bean
    public KafkaProducer<String, Object> getKafkaProducer() {
        return new KafkaProducer<String, Object>(producerConfig());
    }
}
