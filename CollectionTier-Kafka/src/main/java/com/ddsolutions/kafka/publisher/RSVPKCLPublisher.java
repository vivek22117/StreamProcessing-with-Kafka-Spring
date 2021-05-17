package com.ddsolutions.kafka.publisher;

public interface RSVPKCLPublisher {

    public void publishDataIntoKinesis(String payload) throws Exception ;
    public void stop();


}
