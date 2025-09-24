# Use OpenJDK image
FROM openjdk:17-jdk

# Set working directory
WORKDIR /app

# Copy the Java file from src/ to /app
COPY src/App.java .

# Compile Java program
RUN javac App.java

# Run the Java program
CMD ["java", "App"]
