pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
        DOCKER_IMAGE_NAME = 'abhivajani/jenkins-image'
        DOCKER_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-creds'
        AWS_CREDENTIALS_ID = 'aws-credentials'
    }

    stages {

        stage('Check Environment Variables') {
            steps {
                script {
                    def missingVars = []
                    
                    // Check each variable and add to the list if it's missing
                    if (!env.DOCKER_IMAGE_NAME) {
                        missingVars.add('DOCKER_IMAGE_NAME')
                    }
                    if (!env.DOCKER_TAG) {
                        missingVars.add('DOCKER_TAG')
                    }
                    if (!env.DOCKER_CREDENTIALS_ID) {
                        missingVars.add('DOCKER_CREDENTIALS_ID')
                    }

                    // If any variables are missing, throw an error with details
                    if (missingVars) {
                        error("Missing environment variables: ${missingVars.join(', ')}")
                    }
                }
            }
        }
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
                    // Log in to Docker Hub using the provided credentials
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        // Push the image to Docker Hub
                        echo "Pushing image to Docker Hub: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
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