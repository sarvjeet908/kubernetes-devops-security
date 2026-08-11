pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-west-1'
        CLUSTER_NAME = 'my-eks-cluster'
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
        stage('SonarQube - SAST-11') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                  mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar \
                  -Dsonar.projectKey=numeric-application \
                  -Dsonar.host.url=http://localhost:9000/ \
                  -Dsonar.login=\$SONAR_TOKEN
                 """
                }
            }
        }
        stage('TRIVY FS SCAN and opa-conf-test-scan') {
            steps {
                parallel (
                    "TRIVY FS SCAN": {
                        sh "trivy fs . > trivyfs.txt"
                    },
                    "Owasp Dependency Check": {
                        dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey   7BA36ED4-9794-F111-8371-0EBF96DE670D', odcInstallation: 'DC'
                        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                    },
                    "OPA Conftest": {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    }
                )
            }
        }
        stage('Docker Build & Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                echo "$DOCKER_PASSWORD" | docker login \
                    --username "$DOCKER_USER" \
                    --password-stdin

                docker build -t sarvjeet908/rammayan:5 .
                docker push sarvjeet908/rammayan:5

                docker logout
            '''
                }
            }
        }
        stage('kube-scan && TRIVY image Scan') {
            steps {
                parallel(
                    "trivy-image-scan": {
                        sh "trivy image sarvjeet908/rammayan:5 > trivyimage.txt"
                    },
                    "kubesec.io - scan": {
                        sh '''
                    chmod +x kube-scan.sh
                    ./kube-scan.sh
                '''
                    }
                )
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
                    kubectl apply -f k8s_deployment_service.yaml
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
        // successs {
        // }
        // failure {
        // }
    }
}
