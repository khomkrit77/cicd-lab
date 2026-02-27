pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'romeokiller'
        IMAGE_NAME = "cicd-lab"
        REGISTRY_IMAGE = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "cicd-container"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Tag Image') {
            steps {
                sh "docker build -t ${REGISTRY_IMAGE}:latest ."
                sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials',
                                 passwordVariable: 'DOCKER_HUB_PASSWORD',
                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                    sh "docker push ${REGISTRY_IMAGE}:latest"
                    sh "docker push ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Stop Old Container') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
            }
        }

        stage('Deploy New Container') {
            steps {
                sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${REGISTRY_IMAGE}:latest"
            }
        }
    }

    post {
        success {
            echo 'Deployment & Push Successful'
        }
        failure {
            echo 'Deployment Failed'
        }
    }
}
