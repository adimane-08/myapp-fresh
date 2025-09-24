# Use a Java runtime image
FROM openjdk:17-jdk-alpine

# Set working directory
WORKDIR /app

# Copy compiled class files
COPY target/ . 

# Command to run the app
CMD ["java", "App"]
