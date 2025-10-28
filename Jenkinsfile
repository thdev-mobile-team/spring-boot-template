pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "lekimtanloc/spring-boot-template"
        REGISTRY_CREDENTIAL = '777172c9-f65b-4520-99bb-098e9a079c75' // Jenkins credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/thdev-mobile-team/spring-boot-template.git'
            }
        }

        stage('Set Docker Tag') {
            steps {
                script {
                    // Lấy commit hash ngắn làm tag Docker
                    env.DOCKER_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Docker tag will be: ${env.DOCKER_TAG}"
                }
            }
        }

        stage('Build JAR') {
            steps {
                echo '🔧 Building Spring Boot application...'
                sh 'chmod +x gradlew'
                sh './gradlew clean bootJar -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${REGISTRY_CREDENTIAL}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker logout
                        """
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                echo '🚀 Deploying container via Docker Compose...'
                script {
                    sh """
                        if [ -f docker-compose.yml ]; then
                            # Dừng và remove container cũ (nếu có)
                            docker rm -f springboot-app || true

                            # Cập nhật tag mới trong docker-compose.yml
                            sed -i "s|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|" docker-compose.yml

                            # Recreate container với image mới
                            docker compose up -d --force-recreate
                        else
                            echo "docker-compose.yml not found, skipping deploy."
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline executed successfully!'
        }
        failure {
            echo '❌ CI/CD pipeline failed!'
        }
    }
}
