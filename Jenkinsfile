pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
        DOCKER_IMAGE_NAME = 'abhivajani/todo-app1'
        DOCKER_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-creds'
        AWS_CREDENTIALS_ID = 'aws-credentials'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Check Docker Status') {
            steps {
                script {
                    // This will check if Docker is running and accessible
                    sh 'docker ps' // List running Docker containers
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def image = "${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    sh "docker build -t ${image} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def image = "${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        sh "docker push ${image}"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG_FILE'),
                                     usernamePassword(credentialsId: AWS_CREDENTIALS_ID, passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        sh 'export KUBECONFIG=${KUBECONFIG_FILE}'
                        sh 'export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}'
                        sh 'export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}'
                        sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}|g' deployment.yml"
                        sh 'kubectl apply -f deployment.yml'
                        sh 'kubectl apply -f service.yml'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}