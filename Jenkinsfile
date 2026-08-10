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
            
        }
         stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }
        stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarServer') {
          sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar \
		              -Dsonar.projectKey=numeric-application \
		              -Dsonar.host.url=http://54.205.195.131:9000/"
        }
        
      }
    }


       

         stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey   7BA36ED4-9794-F111-8371-0EBF96DE670D', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
           }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(
                        credentialsId: 'docker-hub',
                        toolName: 'docker'
                    ) {
                        sh 'docker build -t sarvjeet908/rammayan:6 .'
                        sh 'docker push sarvjeet908/rammayan:6'
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
       post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
        // success {
        // }
        // failure {
        // }
    }
}