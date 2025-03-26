# Use a lightweight JDK image
FROM openjdk:17-jdk-slim

# Set a non-root user for security
RUN addgroup --system appgroup && adduser --system --group appuser
USER appuser

# Set working directory inside the container
WORKDIR /app

# Copy the built JAR file from the target directory
COPY target/demo-1.0.0.jar app.jar

# Expose application port
EXPOSE 9090

# Define environment variables (optional)
ENV SPRING_PROFILES_ACTIVE=prod

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Health check to verify app is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD curl -f http://localhost:9090/api/hello || exit 1
