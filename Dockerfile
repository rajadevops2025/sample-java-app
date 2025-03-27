# Use official OpenJDK image with slim Debian base
FROM eclipse-temurin:17-jdk-jammy AS builder

# Set working directory
WORKDIR /workspace/app

# Copy the Maven wrapper and give execute permissions
COPY mvnw .
RUN chmod +x mvnw

# Copy the entire project
COPY . .

# Build the application
RUN ./mvnw clean package -DskipTests

# Debugging: Verify JAR file exists
RUN ls -lh target/

# --------------------- Final Image ---------------------

FROM eclipse-temurin:17-jre-jammy

# Set app user and group
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Create app directory and set permissions
RUN mkdir -p /app && chown appuser:appgroup /app
WORKDIR /app
USER appuser

# Copy the built JAR from builder stage
COPY --from=builder /workspace/app/target/demo-*.jar app.jar

# Set default environment variables
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
    SERVER_PORT=9090

# Expose the port (for documentation)
EXPOSE 9090

# Health check for Spring Boot application
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:9090/actuator/health || exit 1

# Optimized entrypoint
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -jar app.jar"]
