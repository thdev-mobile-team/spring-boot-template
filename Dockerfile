
#BUILD STAGE

FROM eclipse-temurin:21-jdk-jammy AS build

WORKDIR /workspace

# Copy file build config
COPY gradlew gradlew.bat build.gradle ./
COPY gradle/ gradle/

# Cấp quyền excute cho gradlew
RUN chmod +x gradlew

# Kéo dependency Gradle 
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon -q help

# Copy source 
COPY src/ src/

# Build jar SpringBoot
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon clean bootJar -x test



#RUNTIME STAGE

FROM eclipse-temurin:21-jre-jammy AS runtime

RUN useradd --system --uid 1001 --home /home/devops --shell /usr/sbin/nologin devops

WORKDIR /opt/app

# Copy jar đã build sang stage runtime
COPY --from=build /workspace/build/libs/spring-boot-template.jar /opt/app/app.jar

# Chạy port 8060
EXPOSE 8060

USER devops

ENTRYPOINT ["java","-jar","/opt/app/app.jar"]
