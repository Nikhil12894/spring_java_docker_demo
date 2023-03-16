####
# This Dockerfile is used to package the javadockerdemo1 application
#
#
###
FROM maven:3.8.5-openjdk-17 as builder
WORKDIR /usr/src/app
COPY src ./src
COPY pom.xml .

RUN mvn -f /usr/src/app/pom.xml clean install dependency:copy-dependencies

FROM openjdk:17-alpine AS jre-build
WORKDIR /app

# copy the dependencies into the docker image
COPY --from=builder /usr/src/app/target/dependency/* build/lib/
# COPY build/lib/* build/lib/

# copy the executable jar into the docker image
COPY --from=builder /usr/src/app/target/javadockerdemo1-*.jar build/app.jar
# COPY build/libs/app-*.jar build/app.jar

# find JDK dependencies dynamically from jar
RUN jdeps \
# dont worry about missing modules
--ignore-missing-deps \
# suppress any warnings printed to console
-q \
# java release version targeting
--multi-release 17 \
# output the dependencies at end of run
--print-module-deps \
# specify the the dependencies for the jar
--class-path build/lib/* \
# pipe the result of running jdeps on the app jar to file
build/app.jar > jre-deps.info
# new since last time!
RUN jlink --verbose \
--compress 2 \
--strip-java-debug-attributes \
--no-header-files \
--no-man-pages \
--output jre \
--add-modules $(cat jre-deps.info)

# take a smaller runtime image for the final output
FROM alpine:latest
WORKDIR /deployment

# copy the custom JRE produced from jlink
COPY --from=jre-build /app/jre jre

# copy the app dependencies
COPY --from=jre-build /app/build/lib/* lib/

# copy the app
COPY --from=jre-build /app/build/app.jar app.jar

EXPOSE 8080
# run the app on startup
ENTRYPOINT jre/bin/java -jar app.jar
