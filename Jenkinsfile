pipeline {
    agent any

    environment {
        KUBECONFIG = 'C:\\Users\\Aditya\\.kube\\config'
        DOCKER_IMAGE_1 = 'adimane0801/myapp'
        DOCKER_IMAGE_2 = 'adimane0801/myapp2'
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
                docker build --no-cache -t adimane0801/myapp:%BUILD_NUMBER% .
                docker build --no-cache -t adimane0801/myapp2:%BUILD_NUMBER% .
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    docker context use default
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker push adimane0801/myapp:%BUILD_NUMBER%
                    docker push adimane0801/myapp2:%BUILD_NUMBER%
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat """
                kubectl apply -f k8s-deployment.yaml --validate=false
                """
            }
        }

        stage('Update Deployments') {
            steps {
                bat """
                kubectl set image deployment/myapp-deployment myapp=adimane0801/myapp:%BUILD_NUMBER%
                kubectl set image deployment/myapp2-deployment myapp2=adimane0801/myapp2:%BUILD_NUMBER%
                kubectl rollout restart deployment myapp-deployment
                kubectl rollout restart deployment myapp2-deployment
                kubectl rollout status deployment myapp-deployment
                kubectl rollout status deployment myapp2-deployment
                """
            }
        }

        stage('Apply HPA, Service, and Ingress') {
            steps {
                bat """
                kubectl apply -f hpa.yaml
                kubectl apply -f service.yaml
                kubectl apply -f ingress.yaml
                """
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully! Access via https://myapp.local or https://myapp2.local'
        }
        failure {
            echo '❌ Deployment failed. Check Jenkins logs for details.'
        }
    }
}
