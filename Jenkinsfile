pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "lekimtanloc/spring-boot-template"
        REGISTRY_CREDENTIAL = '777172c9-f65b-4520-99bb-098e9a079c75'
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
                    env.DOCKER_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Docker tag will be: ${env.DOCKER_TAG}"
                }
            }
        }

        stage('Build JAR') {
            steps {
                echo 'Building Spring Boot application...'
                sh 'chmod +x gradlew'
                sh './gradlew clean bootJar -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing image to Docker Hub...'
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
                echo 'Deploying container by Docker Compose...'
                script {
                    sh """
                        if [ -f docker-compose.yml ]; then
                            sed -i "s|image: lekimtanloc/spring-boot-template:.*|image: lekimtanloc/spring-boot-template:${DOCKER_TAG}|" docker-compose.yml
                            docker compose down || true
                            docker compose pull || true
                            docker compose up -d --force-recreate
                            echo "Container updated successfully"
                        else
                            echo "Skipping deploy."
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Successfully!'
        }
        failure {
            echo 'Failed!'
        }
    }
}
