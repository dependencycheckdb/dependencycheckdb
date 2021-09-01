FROM openjdk:11-jre

ENV DCVERSION=6.3.1
ENV H2VERSION=1.4.199

RUN useradd --create-home h2
USER h2
WORKDIR /home/h2

RUN curl -L -o dependency-check.zip https://github.com/jeremylong/DependencyCheck/releases/download/v${DCVERSION}/dependency-check-${DCVERSION}-release.zip \
    && curl -o h2.jar https://repo1.maven.org/maven2/com/h2database/h2/${H2VERSION}/h2-${H2VERSION}.jar  \
    && curl -o initialize.sql https://raw.githubusercontent.com/jeremylong/DependencyCheck/v${DCVERSION}/core/src/main/resources/data/initialize.sql \
    && curl -o dependency-check-core.jar https://repo1.maven.org/maven2/org/owasp/dependency-check-core/${DCVERSION}/dependency-check-core-${DCVERSION}.jar

RUN unzip dependency-check.zip -d . \
    && rm dependency-check.zip

RUN java -cp h2.jar:dependency-check-core.jar org.h2.tools.RunScript -url jdbc:h2:/home/h2/db -user sa -password sa -script initialize.sql

RUN echo "data.password=sa" > dependency-check.properties \
    && ./dependency-check/bin/dependency-check.sh --updateonly --connectionString jdbc:h2:/home/h2/db --dbUser sa --propertyfile dependency-check.properties

RUN java -cp h2.jar:dependency-check-core.jar org.h2.tools.Shell -url jdbc:h2:/home/h2/db -user sa -password sa -sql "CREATE USER readonly PASSWORD 'readonly'; \
GRANT SELECT ON cpeEcosystemCache TO PUBLIC; \
GRANT SELECT ON cpeEntry TO PUBLIC; \
GRANT SELECT ON cweEntry TO PUBLIC; \
GRANT SELECT ON properties TO PUBLIC; \
GRANT SELECT ON reference TO PUBLIC; \
GRANT SELECT ON software TO PUBLIC; \
GRANT SELECT ON vulnerability TO PUBLIC;"

COPY --chown=h2:h2 entrypoint.sh .

EXPOSE 9092

ENTRYPOINT "./entrypoint.sh"
