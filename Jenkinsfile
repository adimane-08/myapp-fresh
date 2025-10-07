pipeline {
    agent any

    environment {
        KUBECONFIG = 'C:\\Users\\Aditya\\.kube\\config'
        // Base64 TLS certs stored as Jenkins credentials
        MYAPP1_TLS_CRT = credentials('myapp-tls-crt')
        MYAPP1_TLS_KEY = credentials('myapp-tls-key')
        MYAPP2_TLS_CRT = credentials('myapp2-tls-crt')
        MYAPP2_TLS_KEY = credentials('myapp2-tls-key')
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

        stage('Create TLS Secrets') {
            steps {
                bat """
                REM --- App 1 TLS ---
                echo %MYAPP1_TLS_CRT% > myapp.local.crt.base64
                echo %MYAPP1_TLS_KEY% > myapp.local.key.base64
                certutil -decode myapp.local.crt.base64 myapp.local.crt
                certutil -decode myapp.local.key.base64 myapp.local.key
                kubectl create secret tls myapp-tls --cert=myapp.local.crt --key=myapp.local.key --dry-run=client -o yaml | kubectl apply -f -

                REM --- App 2 TLS ---
                echo %MYAPP2_TLS_CRT% > myapp2.local.crt.base64
                echo %MYAPP2_TLS_KEY% > myapp2.local.key.base64
                certutil -decode myapp2.local.crt.base64 myapp2.local.crt
                certutil -decode myapp2.local.key.base64 myapp2.local.key
                kubectl create secret tls myapp2-tls --cert=myapp2.local.crt --key=myapp2.local.key --dry-run=client -o yaml | kubectl apply -f -
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
            echo 'Deployment completed! Both apps should be accessible over HTTPS.'
        }
        failure {
            echo 'Deployment failed. Check Jenkins logs for errors.'
        }
    }
}
