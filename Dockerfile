FROM openjdk:17-jdk

WORKDIR /app

# Correctly copy the Java file
COPY src/App.java .

# Compile
RUN javac App.java

# Run the app
CMD ["java", "App"]
