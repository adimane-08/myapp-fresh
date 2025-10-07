pipeline {
    agent any

    environment {
        KUBECONFIG = 'C:\\Users\\Aditya\\.kube\\config'
        // Base64 TLS cert stored as Jenkins credentials
        MYAPP_TLS_CRT = credentials('myapp-tls-crt')
        MYAPP_TLS_KEY = credentials('myapp-tls-key')
    }

    stages {
        stage('Clean Workspace') {
            steps { cleanWs() }
        }

        stage('Clone Repo') {
            steps { checkout scm }
        }

        stage('Build Docker Images') {
            steps {
                bat '''
                @echo off
                call minikube -p minikube docker-env > docker_env.bat
                call docker_env.bat
                docker build --no-cache -t adimane0801/myapp:%BUILD_NUMBER% ./myapp
                docker build --no-cache -t adimane0801/myapp2:%BUILD_NUMBER% ./myapp2
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    docker context use default
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker tag adimane0801/myapp:%BUILD_NUMBER% adimane0801/myapp:%BUILD_NUMBER%
                    docker push adimane0801/myapp:%BUILD_NUMBER%
                    docker tag adimane0801/myapp2:%BUILD_NUMBER% adimane0801/myapp2:%BUILD_NUMBER%
                    docker push adimane0801/myapp2:%BUILD_NUMBER%
                    """
                }
            }
        }

        stage('Create TLS Secret') {
            steps {
                bat """
                REM --- TLS for both apps ---
                echo %MYAPP_TLS_CRT% > myapp.local.crt.base64
                echo %MYAPP_TLS_KEY% > myapp.local.key.base64
                certutil -decode myapp.local.crt.base64 myapp.local.crt
                certutil -decode myapp.local.key.base64 myapp.local.key
                kubectl create secret tls myapp-tls --cert=myapp.local.crt --key=myapp.local.key --dry-run=client -o yaml | kubectl apply -f -
                """
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat """
                kubectl apply -f deployments/myapp-deployment.yaml --validate=false
                kubectl apply -f deployments/myapp2-deployment.yaml --validate=false
                """
            }
        }

        stage('Update Deployments') {
            steps {
                bat """
                kubectl set image deployment/myapp myapp=adimane0801/myapp:%BUILD_NUMBER%
                kubectl set image deployment/myapp2 myapp2=adimane0801/myapp2:%BUILD_NUMBER%
                kubectl rollout restart deployment myapp
                kubectl rollout restart deployment myapp2
                kubectl rollout status deployment myapp
                kubectl rollout status deployment myapp2
                """
            }
        }

        stage('Apply HPA, Service, and Ingress') {
            steps {
                bat """
                kubectl apply -f hpa.yaml
                kubectl apply -f services/myapp-service.yaml
                kubectl apply -f services/myapp2-service.yaml
                kubectl apply -f ingress/myapps-ingress.yaml
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment completed! Both apps are accessible over HTTPS using a single TLS secret.'
        }
        failure {
            echo 'Deployment failed. Check Jenkins logs for errors.'
        }
    }
}
