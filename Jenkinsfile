pipeline {
    agent any
 
    environment {
        DOCKER_IMAGE = 'adimane0801/myapp'
        KUBECONFIG = 'C:\\Users\\Aditya\\.kube\\config'
       // KUBECONFIG = credentials('kubeconfig')
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
                
             ::docker tag myapp:%BUILD_NUMBER% adimane0801/myapp:latest
             ::docker push adimane0801/myapp:latest  
            """
        }
    }
}
        stage('Deploy to Minikube') {
          steps {
            withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')]) {
              bat 'kubectl apply -f k8s-deployment.yaml --validate=false'
              // to verify the deployment was successful
    }
  }
}

                
        stage('Update Deployment') {
            steps {
                bat "kubectl set image deployment/myapp-deployment myapp=adimane0801/myapp:%BUILD_NUMBER%"
                bat "kubectl rollout restart deployment myapp-deployment"
                bat "kubectl rollout status deployment myapp-deployment"
            }
        }
        stage('Apply HPA, service and ingress') {
         steps {
          bat 'kubectl apply -f hpa.yaml'
          bat 'kubectl apply -f service.yaml'
          bat 'kubectl apply -f ingress.yaml'
         }

      }
    }


    }

    

    
