#####################################
# ===== BUILD STAGE =====
#####################################
FROM eclipse-temurin:21-jdk-jammy AS build

# Thư mục làm việc trong container
WORKDIR /workspace

# Copy file cấu hình Gradle (bắt buộc phải có settings.gradle)
COPY gradlew gradlew.bat build.gradle settings.gradle ./
COPY gradle/ gradle/

# Cấp quyền chạy cho gradlew (tránh lỗi permission)
RUN chmod +x gradlew

# Kéo dependency Gradle để cache (giúp build nhanh hơn ở lần sau)
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon -q help

# Copy source code
COPY src/ src/

# Build file jar Spring Boot (bỏ qua test để build nhanh)
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon clean bootJar -x test


#####################################
# ===== RUNTIME STAGE =====
#####################################
FROM eclipse-temurin:21-jre-jammy AS runtime

# Tạo user không đặc quyền để chạy app
RUN useradd --system --uid 1001 --home /home/devops --shell /usr/sbin/nologin devops

WORKDIR /opt/app

# Copy file jar từ stage build
COPY --from=build /workspace/build/libs/*.jar /opt/app/app.jar

# Mở port ứng dụng
EXPOSE 8060

# Chạy với user devops
USER devops

# Lệnh chạy ứng dụng
ENTRYPOINT ["java","-jar","/opt/app/app.jar"]
