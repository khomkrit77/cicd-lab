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
                checkout scm [cite: 1, 2]
            }
        }
        
        stage('Prepare Versioning') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                script {
                    def deployDate = sh(script: "date '+%Y-%m-%d %H:%M:%S'", returnStdout: true).trim()
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim() [cite: 3]
                    echo "Deploying Commit: ${commitMsg}"
                    sh "sed -i 's/BUILD_NUMBER_PLACEHOLDER/${BUILD_NUMBER}/g' index.html"
                    sh "sed -i 's/DEPLOY_DATE_PLACEHOLDER/${deployDate}/g' index.html" [cite: 4]
                    sh "sed -i \"s|COMMIT_MESSAGE_PLACEHOLDER|${commitMsg}|g\" index.html"
                }
            }
        }  

        stage('Build Image') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                // ขั้นตอนนี้แค่ Build Image ไว้ในเครื่องเพื่อรอสแกน
                sh "docker build -t ${REGISTRY_IMAGE}:latest ." [cite: 7]
            }
        }

        stage('Image Scan (Security)') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                script {
                    echo "🛡️ กำลังสแกนหาช่องโหว่ใน Image..."
                    // สั่ง Trivy สแกนระดับ HIGH และ CRITICAL 
                    // ถ้าเจอช่องโหว่ร้ายแรง จะสั่งให้ Pipeline หยุดทำงานทันที (exit code 1)
                    sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${REGISTRY_IMAGE}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            when { expression { params.ROLLBACK_VERSION == '' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                 passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) { [cite: 5]
                    
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin" [cite: 6, 7]
                    
                    sh "docker tag ${REGISTRY_IMAGE}:latest ${REGISTRY_IMAGE}:${BUILD_NUMBER}" [cite: 7]
                    sh "docker push ${REGISTRY_IMAGE}:latest" [cite: 8]
                    sh "docker push ${REGISTRY_IMAGE}:${BUILD_NUMBER}" [cite: 8]
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // เลือกใช้ Tag ตามที่ระบุใน Parameter (ถ้าว่างใช้ latest)
                    def targetTag = params.ROLLBACK_VERSION ?: "latest"
                    echo "🚀 กำลัง Deploy Version: ${targetTag}"

                    sh "docker stop ${CONTAINER_NAME} || true" [cite: 9, 10]
                    sh "docker rm ${CONTAINER_NAME} || true" [cite: 11]
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
