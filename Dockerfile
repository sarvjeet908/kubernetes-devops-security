# Use Eclipse Temurin (official OpenJDK builds)----- -----
#FROM eclipse-temurin:8-jdk-alpine

#EXPOSE 8080
#ARG JAR_FILE=target/*.jar
#COPY ${JAR_FILE} app.jar
#ENTRYPOINT ["java","-jar","/app.jar"]


FROM eclipse-temurin:17-jdk-alpine

EXPOSE 8080

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-jar","/app.jar"]
