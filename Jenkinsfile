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
        
        stage('Prepare Versioning') {
            steps {
                script {
                    def deployDate = sh(script: "date '+%Y-%m-%d %H:%M:%S'", returnStdout: true).trim()
                    
                    // ใช้ sed ค้นหาคำใน index.html แล้วเปลี่ยนเป็นค่าจริงจาก Jenkins
                    sh "sed -i 's/BUILD_NUMBER_PLACEHOLDER/${BUILD_NUMBER}/g' index.html"
                    sh "sed -i 's/DEPLOY_DATE_PLACEHOLDER/${deployDate}/g' index.html"
                }
            }
        }  

        stage('Build and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                 passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    
                    // ต้อง Login ก่อนถึงจะเริ่ม Build ได้เพื่อเลี่ยงปัญหา 401
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                    
                    sh "docker build -t ${REGISTRY_IMAGE}:latest ."
                    sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                    
                    sh "docker push ${REGISTRY_IMAGE}:latest"
                    sh "docker push ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${REGISTRY_IMAGE}:latest"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
