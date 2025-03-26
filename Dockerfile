# Use official OpenJDK image with slim Debian base
FROM eclipse-temurin:17-jdk-jammy as builder

# Build stage (optional - can use multi-stage build to reduce final image size)
WORKDIR /workspace/app
COPY . .
RUN ./mvnw clean package -DskipTests

# Final image
FROM eclipse-temurin:17-jre-jammy

# Set app user and group
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Create app directory and set permissions
RUN mkdir -p /app && chown appuser:appgroup /app
WORKDIR /app
USER appuser

# Copy the built JAR from builder stage or host
COPY --from=builder /workspace/app/target/demo-*.jar app.jar
# OR if building locally: COPY target/demo-*.jar app.jar

# Set default environment variables
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
    SERVER_PORT=9090

# Expose port (documentation only - doesn't actually publish)
EXPOSE ${SERVER_PORT}

# Health check with Spring Boot Actuator (more reliable)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:${SERVER_PORT}/actuator/health || exit 1

# Optimized entrypoint
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -jar app.jar"]
