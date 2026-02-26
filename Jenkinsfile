pipeline {
    agent any

    environment {
        // กำหนดชื่อบัญชี Docker Hub ของคุณ
        DOCKER_HUB_USER = 'khomkrit77' 
        IMAGE_NAME = "cicd-lab"
        REGISTRY_IMAGE = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "cicd-container"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm [cite: 3]
            }
        }

        stage('Build & Tag Image') {
            steps {
                // สร้าง Image พร้อมติด Tag สำหรับ Registry [cite: 4]
                sh "docker build -t ${REGISTRY_IMAGE}:latest ."
                sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // เรียกใช้ ID 'docker-hub-credentials' ที่คุณเพิ่งสร้างในหน้า UI
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
                // สั่งหยุดคอนเทนเนอร์เดิมถ้ามีอยู่ [cite: 5, 6]
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
            }
        }

        stage('Deploy New Container') {
            steps {
                // รันคอนเทนเนอร์โดยใช้ Image จาก Docker Hub [cite: 7]
                sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${REGISTRY_IMAGE}:latest"
            }
        }
    } [cite: 8]

    post {
        success {
            echo 'Deployment & Push Successful 🚀'
        }
        failure {
            echo 'Deployment Failed ❌'
        }
    }
}
