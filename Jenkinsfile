pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'adimane0801/myapp'
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
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
           withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            // Run Windows batch commands
             bat """
                docker context use default
                echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                docker tag myapp:v1 adimane0801/myapp:v1
                docker push adimane0801/myapp:v1
            """
        }
    }
        }
                
        stage('Test K8s') {
          steps {
            withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')]) {
               bat 'kubectl get nodes'
            }
        }
    }

        
        stage('Run maven') {
          steps {
            container('maven') {
              bat 'mvn -version'
            }
          }
        }
      

  

         stage('Deploy to Minikube') {
             steps {
                 script {
                       // withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            bat 'kubectl apply -f k8s-deployment.yaml --validate=false'
                }
            }
       // }
    }
    }
}
    
        }
    }
    }
