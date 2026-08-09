pipeline {

    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        CLUSTER_NAME = 'sarvjeet908-cluster-run'
    }

    stages {

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests=true'

                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }

            post {
                always {
                    junit 'target/surefire-reports/*.xml'

                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {

                    withDockerRegistry(
                        credentialsId: 'docker-hub',
                        toolName: 'docker'
                    ) {

                        sh 'docker build -t sarvjeet908/rammayan:5 .'

                        sh 'docker push sarvjeet908/rammayan:5'
                    }
                }
            }
        }

        stage('EKS Authentication') {
            steps {
                sh '''

                    echo "=== Test EKS ==="
                    kubectl get nodes

                    echo "=== Test Authorization ==="
                    kubectl auth can-i get pods --all-namespaces
                '''
            }
        }

        stage('Deploy to EKS - Dev') {
    steps {
        sh '''
            echo "=== AWS Identity ==="
            aws sts get-caller-identity

            echo "=== Deploy ==="
            kubectl apply -f k8s/
        '''
    }
}
    }
}