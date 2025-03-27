# Use official OpenJDK image with slim Debian base for building the app
FROM eclipse-temurin:17-jdk-jammy as builder

# Set working directory inside the container
WORKDIR /workspace/app

# Copy project files
COPY . .

# Copy the Maven wrapper scripts
COPY ./mvnw ./mvnw
COPY ./mvnw.cmd ./mvnw.cmd
RUN chmod +x mvnw

# Build the application
RUN ./mvnw clean package -DskipTests

# Use a smaller JRE-based image for the final runtime
FROM eclipse-temurin:17-jre-jammy

# Set up a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Create an application directory with correct permissions
RUN mkdir -p /app && chown appuser:appgroup /app
WORKDIR /app
USER appuser

# Copy the built JAR from the builder stage
COPY --from=builder /workspace/app/target/demo-*.jar app.jar

# Set default environment variables
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
    SERVER_PORT=9090

# Expose port (documentation only)
EXPOSE ${SERVER_PORT}

# Health check to verify if the app is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:${SERVER_PORT}/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -jar app.jar"]
