pipeline {
    agent any
    
    // 1. เพิ่มส่วน Parameters เพื่อให้กดเลือกเลข Build ได้
    parameters {
        string(name: 'ROLLBACK_VERSION', defaultValue: '', description: 'ใส่เลข Build Number ที่ต้องการ Rollback (ถ้าต้องการ Deploy ปกติให้ปล่อยว่างไว้)')
    }

    environment {
        DOCKER_HUB_USER = 'romeokiller' [cite: 1]
        IMAGE_NAME = "cicd-lab" [cite: 1]
        REGISTRY_IMAGE = "${DOCKER_HUB_USER}/${IMAGE_NAME}" [cite: 1]
        CONTAINER_NAME = "cicd-container" [cite: 1]
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm [cite: 2]
            }
        }
        
        // ขั้นตอนนี้จะทำเฉพาะตอนที่ไม่ได้สั่ง Rollback
        stage('Prepare Versioning') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                script {
                    def deployDate = sh(script: "date '+%Y-%m-%d %H:%M:%S'", returnStdout: true).trim() [cite: 4]
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim() [cite: 3]
                    echo "Deploying Commit: ${commitMsg}"
                    sh "sed -i 's/BUILD_NUMBER_PLACEHOLDER/${BUILD_NUMBER}/g' index.html"
                    sh "sed -i 's/DEPLOY_DATE_PLACEHOLDER/${deployDate}/g' index.html" [cite: 4]
                    sh "sed -i \"s|COMMIT_MESSAGE_PLACEHOLDER|${commitMsg}|g\" index.html"
                }
            }
        }  

        // ขั้นตอนนี้จะทำเฉพาะตอนที่ไม่ได้สั่ง Rollback
        stage('Build and Push') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                 passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) { [cite: 5]
                    
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin" [cite: 7]
                    sh "docker build -t ${REGISTRY_IMAGE}:latest ."
                    sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY_IMAGE}:latest" [cite: 8]
                    sh "docker push ${REGISTRY_IMAGE}:${BUILD_NUMBER}" [cite: 8]
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // ตรวจสอบว่าเป็นการ Rollback หรือ Deploy ใหม่
                    // ถ้า params.ROLLBACK_VERSION มีค่า จะดึง Tag นั้นมาใช้ ถ้าไม่มีจะใช้ latest 
                    def targetTag = params.ROLLBACK_VERSION ?: "latest"
                    echo "Deploying Version: ${targetTag}"

                    sh "docker stop ${CONTAINER_NAME} || true" [cite: 9, 10]
                    sh "docker rm ${CONTAINER_NAME} || true" [cite: 11]
                    // รันคอนเทนเนอร์ด้วย Tag ที่กำหนด
                    sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${REGISTRY_IMAGE}:${targetTag}"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
