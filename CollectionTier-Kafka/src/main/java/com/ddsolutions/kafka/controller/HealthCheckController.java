package com.ddsolutions.kafka.controller;

import org.springframework.boot.actuate.health.AbstractHealthIndicator;
import org.springframework.boot.actuate.health.Health;
import org.springframework.stereotype.Component;

@Component
public class HealthCheckController extends AbstractHealthIndicator {

    @Override
    protected void doHealthCheck(Health.Builder builder) {
        builder.up().withDetail("Application", "Up and Running!")
                .withDetail("Error", "Nothing, I am good!");

    }
}
