pipeline {

    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        CLUSTER_NAME = 'sarvjeet-cluster-run'
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

              stage('SonarQube - SAST') {
            steps {
                   withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                  sh """
                  mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar \
                  -Dsonar.projectKey=numeric-application \
                  -Dsonar.host.url=http://54.205.195.131:9000/ \
                  -Dsonar.login=\$SONAR_TOKEN
                 """
    }
  }
}
         stage('Vulnerability Scan - Docker ') {
             steps {
                   sh "mvn dependency-check:check"
             }
               post {
                  always {
                      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
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
                    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION

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
                    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION

                    echo "=== AWS Identity ==="
                    aws sts get-caller-identity

                    echo "=== Deploy ==="
                    kubectl apply -f k8s/
                '''
            }
        }
    }
}