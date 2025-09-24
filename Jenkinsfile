pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'adimane0801/myapp'
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                // Deletes old files in Jenkins workspace
                cleanWs()
            }
        }
        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat 'docker build -t %DOCKER_IMAGE%:v1 .'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        docker.image("${DOCKER_IMAGE}:v1").push()
                    }
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    bat 'kubectl apply -f k8s-deployment.yaml --validate=false'
                }
            }
        }
    }
}