pipeline {
    agent any

    environment {
        IMAGE_NAME = "cicd-lab"
        CONTAINER_NAME = "cicd-container"
    }

    stages {

        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Stop Old Container') {
            steps {
                sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true
                '''
            }
        }

        stage('Deploy New Container') {
            steps {
                sh '''
                docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'docker ps'
            }
        }
    }
}
