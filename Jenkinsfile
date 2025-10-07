pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'adimane0801/myapp'
        KUBECONFIG = 'C:\\Users\\Aditya\\.kube\\config'
        MYAPP_TLS_CRT = credentials('myapp-tls-crt')  // Base64 of myapp.local.crt
        MYAPP_TLS_KEY = credentials('myapp-tls-key')  // Base64 of myapp.local.key
    }

    stages {
        stage('Clean Workspace') {
            steps { cleanWs() }
        }

        stage('Clone Repo') {
            steps { checkout scm }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                @echo off
                call minikube -p minikube docker-env > docker_env.bat
                call docker_env.bat
                docker build --no-cache -t adimane0801/myapp:%BUILD_NUMBER% .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    docker context use default
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker tag myapp:%BUILD_NUMBER% adimane0801/myapp:%BUILD_NUMBER%
                    docker push adimane0801/myapp:%BUILD_NUMBER%
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')]) {
                    
                    // Create TLS secret dynamically
                    bat """
                    echo %MYAPP_TLS_CRT% > myapp.local.crt.base64
                    echo %MYAPP_TLS_KEY% > myapp.local.key.base64
                    certutil -decode myapp.local.crt.base64 myapp.local.crt
                    certutil -decode myapp.local.key.base64 myapp.local.key
                    kubectl create secret tls myapp-tls --cert=myapp.local.crt --key=myapp.local.key --dry-run=client -o yaml | kubectl apply -f -
                    """

                    // Apply deployments
                    bat 'kubectl apply -f k8s-deployment.yaml --validate=false'
                }
            }
        }

        stage('Update Deployment') {
            steps {
                bat "kubectl set image deployment/myapp myapp=adimane0801/myapp:%BUILD_NUMBER%"
                bat "kubectl rollout restart deployment myapp"
                bat "kubectl rollout status deployment myapp"
            }
        }

        stage('Apply HPA, Service and Ingress') {
            steps {
                bat 'kubectl apply -f hpa.yaml'
                bat 'kubectl apply -f service.yaml'
                bat 'kubectl apply -f ingress.yaml'
            }
        }
    }

    post {
        success { echo 'Deployment completed! https://myapp.local should be accessible.' }
        failure { echo 'Deployment failed. Check logs for details.' }
    }
}
