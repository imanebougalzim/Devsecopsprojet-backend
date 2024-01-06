# Stage 1: Build the application
FROM maven:3.9.5 as build


# Définition du répertoire de travail
WORKDIR /home/myuser/workspace/app

COPY pom.xml .
COPY src src
RUN mvn clean install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency ; jar -xf ../*.jar)
# Stage 2: Création de l'image finale avec l'intégration de MySQL
FROM openjdk:19-alpine
VOLUME /tmp
ARG DEPENDENCY=home/myuser/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes/application.properties /app/application.properties
# Ajouter MySQL JDBC driver
COPY --from=build /home/myuser/workspace/app/src/main/resources/mysql-connector-java-*.jar /app/lib/mysql-connector-java.jar

ENTRYPOINT ["java","-cp","app:app/lib/*", "com.bezkoder.spring.datajpa.SpringBootDataJpaApplication"]