pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID for Docker Hub
        DOCKER_IMAGE_NAME = 'abhivajani/todo-app1' // Change this to your Docker Hub username and app name
        DOCKER_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}" // Tag image with branch name and build number
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-creds' // Jenkins credentials ID for Kubeconfig
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm // Checkout code from the repository
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
                    // Set kubeconfig for the EKS cluster
                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh 'export KUBECONFIG=${KUBECONFIG_FILE}'

                        // Update deployment.yml with the new image
                        sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}|g' deployment.yml"

                        // Apply the Kubernetes manifests
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