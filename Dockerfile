FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/demo-1.0.0.jar app.jar
EXPOSE 9090
CMD ["java", "-jar", "app.jar"]
