pipeline {
    agent any
    
    parameters {
        string(name: 'ROLLBACK_VERSION', defaultValue: '', description: 'ใส่เลข Build Number ที่ต้องการ Rollback (ถ้าต้องการ Deploy ปกติให้ปล่อยว่างไว้)')
    }

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
        
        stage('Prepare Versioning') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                script {
                    def deployDate = sh(script: "date '+%Y-%m-%d %H:%M:%S'", returnStdout: true).trim()
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Deploying Commit: ${commitMsg}"
                    sh "sed -i 's/BUILD_NUMBER_PLACEHOLDER/${BUILD_NUMBER}/g' index.html"
                    sh "sed -i 's/DEPLOY_DATE_PLACEHOLDER/${deployDate}/g' index.html"
                    sh "sed -i \"s|COMMIT_MESSAGE_PLACEHOLDER|${commitMsg}|g\" index.html"
                }
            }
        }  

        stage('Build Image') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                sh "docker build -t ${REGISTRY_IMAGE}:latest ."
            }
        }

        stage('Image Scan (Security)') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                script {
                    sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${REGISTRY_IMAGE}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                 passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                    sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY_IMAGE}:latest"
                    sh "docker push ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def targetTag = params.ROLLBACK_VERSION ?: "latest"
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${REGISTRY_IMAGE}:${targetTag}"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
        }
    }
}
