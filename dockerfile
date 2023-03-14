FROM openjdk:17-jdk-slim-buster
WORKDIR /app

COPY app/build/lib/* build/lib/

COPY app/build/libs/javadockerdemo1-0.0.1-SNAPSHOT.jar build/

WORKDIR /app/build
EXPOSE 8080

ENTRYPOINT java -jar javadockerdemo1-0.0.1-SNAPSHOT.jar