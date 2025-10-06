# Multi-stage build for Spring Boot app
FROM maven:3.9.6-eclipse-temurin-21 as build

# Set working directory
WORKDIR /app

# Copy pom.xml first for better Docker layer caching
COPY pom.xml ./

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Production stage
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy built jar from build stage
COPY --from=build /app/target/burger-builder-backend-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
CMD ["java", "-jar", "app.jar"]