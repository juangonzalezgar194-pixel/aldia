package com.aldia.aldia_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AldiaBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(AldiaBackendApplication.class, args);
	}

}