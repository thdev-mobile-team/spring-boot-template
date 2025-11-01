pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "lekimtanloc/spring-boot-template"
        REGISTRY_CREDENTIAL = '777172c9-f65b-4520-99bb-098e9a079c75'
        GITHUB_CREDENTIAL = 'github-cred'  // <-- ID credential GitHub bạn vừa tạo trong Jenkins
        CD_REPO_URL = 'https://github.com/thdev-mobile-team/spring-boot-template.git'
        CD_REPO_BRANCH = 'main'
    }

    stages {
        stage('Checkout Source') {
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

        stage('Build & Push Docker Image') {
            steps {
                echo 'Building and pushing Docker image...'
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${REGISTRY_CREDENTIAL}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker logout
                        """
                    }
                }
            }
        }

       stage('Update Helm values.yaml') {
            steps {
                echo 'Updating image tag in Helm values.yaml...'
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${GITHUB_CREDENTIAL}",
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                    )]) {
                        sh '''
                            CHART_PATH="charts/rpe-spring-boot-template/values.yaml"

                            echo "yq -i '(.image.repository = env(DOCKER_IMAGE)) | (.image.tag = env(DOCKER_TAG))' '$CHART_PATH'" > /tmp/yq-update.sh
                            chmod +x /tmp/yq-update.sh

                            docker run --rm \
                            -v "$PWD:/work" -w /work \
                            -e DOCKER_IMAGE="${DOCKER_IMAGE}" \
                            -e DOCKER_TAG="${DOCKER_TAG}" \
                            mikefarah/yq:4 \
                            sh /tmp/yq-update.sh

                            # Cấu hình Git và push
                            git config user.name "thdev-mobile-team"
                            git config user.email "lekimtanloc2002@gmail.com"

                            CURRENT_URL=$(git remote get-url origin)
                            git remote set-url origin "https://${GIT_USER}:${GIT_TOKEN}@${CURRENT_URL#https://}"

                            git add "$CHART_PATH"
                            git commit -m "Update image tag to ${DOCKER_TAG}" || echo "No changes to commit"
                            git push origin ${CD_REPO_BRANCH}
                        '''
                    }
                }
            }
        }

    }

    post {
        success {
            echo '✅ CI pipeline completed successfully — ArgoCD will deploy automatically.'
        }
        failure {
            echo '❌ CI pipeline failed.'
        }
    }
}
