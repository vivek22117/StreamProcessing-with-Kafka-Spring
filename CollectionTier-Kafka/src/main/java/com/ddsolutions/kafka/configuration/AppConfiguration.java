package com.ddsolutions.kafka.configuration;

import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.auth.EC2ContainerCredentialsProviderWrapper;
import com.amazonaws.services.kinesis.producer.KinesisProducer;
import com.amazonaws.services.kinesis.producer.KinesisProducerConfiguration;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
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
import org.springframework.context.annotation.Profile;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisClient;

import java.util.HashMap;
import java.util.Map;

import static com.ddsolutions.kafka.utility.PropertyLoaderUtility.getInstance;

@Configuration
public class AppConfiguration {

    private final KafkaProperties kafkaProperties;
    private static AwsCredentialsProvider awsCredentialsProvider;
    private static AWSCredentialsProvider authAWSCredentialsProvider;

    private ApplicationContext applicationContext;

    @Value("${bootstrap.servers: No server value}")
    private String bootstrapServers;

    @Value("${kafka.rsvp.topic: No topic value}")
    private String topicName;

    @Value("${isRunningInEC2: No value}")
    private boolean isRunningInEC2;

    @Value("${isRunningInLocal: No value}")
    private boolean isRunningInLocal;

    @Autowired
    public AppConfiguration(KafkaProperties kafkaProperties, ApplicationContext applicationContext) {
        this.kafkaProperties = kafkaProperties;
        this.applicationContext = applicationContext;
    }

    @Bean
    public Gson createGson(){
        return new GsonBuilder().setPrettyPrinting().create();
    }

    @Bean
    public KinesisClient createPublisherClient() {
        return KinesisClient.builder()
                .credentialsProvider(getAwsCredentials())
                .region(Region.US_EAST_1).build();
    }

    @Bean
    @Autowired
    public KinesisProducer createKinesisProducer(KinesisProducerConfiguration config) {
        return new KinesisProducer(config);
    }

    @Bean
    public KinesisProducerConfiguration KinesisProducerConfig() {
        KinesisProducerConfiguration config = new KinesisProducerConfiguration();
        config.setRegion(Region.US_EAST_1.toString());
        config.setCredentialsProvider(getAuthAWSCredentials());
        config.setMaxConnections(1);
        config.setRequestTimeout(6000);
        config.setRecordMaxBufferedTime(1000);

        return config;
    }


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

        //High Throughput settings
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
        return new NewTopic(topicName, 3, (short) 1);
    }

    @Bean
    public KafkaProducer<String, Object> getKafkaProducer() {
        return new KafkaProducer<String, Object>(producerConfig());
    }

    private AwsCredentialsProvider getAwsCredentials() {
        if (awsCredentialsProvider == null) {
            if (isRunningInEC2) {
                awsCredentialsProvider = InstanceProfileCredentialsProvider.builder().build();
            } else if (isRunningInLocal) {
                awsCredentialsProvider = ProfileCredentialsProvider.builder().profileName("admin").build();
            } else {
                awsCredentialsProvider = DefaultCredentialsProvider.builder().build();
            }
        }
        return awsCredentialsProvider;
    }

    private AWSCredentialsProvider getAuthAWSCredentials() {
        if (authAWSCredentialsProvider == null) {
            if (isRunningInEC2) {
                authAWSCredentialsProvider = new com.amazonaws.auth.InstanceProfileCredentialsProvider(false);
            } else if (isRunningInLocal) {
                authAWSCredentialsProvider = new com.amazonaws.auth.profile.ProfileCredentialsProvider("qa-admin");
            } else {
                authAWSCredentialsProvider = new DefaultAWSCredentialsProviderChain();
            }
        }
        return authAWSCredentialsProvider;
    }
}
