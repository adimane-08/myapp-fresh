FROM openjdk:17-jdk

WORKDIR /app

COPY src/App.java .

# Compile
RUN javac App.java

# Run
CMD ["java", "App"]

EXPOSE 8080