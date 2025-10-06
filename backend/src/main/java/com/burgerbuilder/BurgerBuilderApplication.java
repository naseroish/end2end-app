package com.burgerbuilder;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class BurgerBuilderApplication {

    public static void main(String[] args) {
        SpringApplication.run(BurgerBuilderApplication.class, args);
    }
    
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                // Get allowed origins from environment variable (set by Terraform)
                String allowedOrigins = System.getenv("CORS_ALLOWED_ORIGINS");
                if (allowedOrigins == null || allowedOrigins.isEmpty()) {
                    // Fallback for local development
                    allowedOrigins = "http://localhost:3000,http://localhost:5173,http://localhost:8080";
                }
                
                registry.addMapping("/**")
                        .allowedOrigins(allowedOrigins.split(","))
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true);
            }
        };
    }
}
