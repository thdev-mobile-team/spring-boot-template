#####################################
# ===== BUILD STAGE =====
#####################################
FROM eclipse-temurin:21-jdk-jammy AS build

WORKDIR /workspace

# Copy file Gradle config 
COPY gradlew gradlew.bat build.gradle* settings.gradle* ./
COPY gradle/ gradle/
#Cấp quyền
RUN chmod +x gradlew

RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon -q help || true

COPY src/ src/

RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon clean bootJar -x test


#####################################
# ===== RUNTIME STAGE =====
#####################################
FROM eclipse-temurin:21-jre-jammy AS runtime

RUN useradd --system --uid 1001 --home /home/devops --shell /usr/sbin/nologin devops

WORKDIR /opt/app

COPY --from=build /workspace/build/libs/*.jar /opt/app/app.jar

EXPOSE 8080

USER devops

ENTRYPOINT ["java","-jar","/opt/app/app.jar"]
