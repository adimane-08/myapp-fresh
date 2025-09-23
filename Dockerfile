FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/myapp.jar .
EXPOSE 80
CMD ["java", "-jar", "myapp.jar"]