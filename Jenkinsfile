pipeline {

    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-west-1'
        CLUSTER_NAME       = 'my-eks-cluster'
        IMAGE_NAME         = "sarvjeet908/devsecops-image:${BUILD_NUMBER}"
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        applicationURL = "http://54.151.74.249/"
        applicationURI = "/increment/99"
    }

    stages {

        // =========================================================
        // 1. CHECKOUT
        // =========================================================
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // =========================================================
        // 2. BUILD
        // =========================================================
        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests=true'

                archiveArtifacts(
                    artifacts: 'target/*.jar',
                    fingerprint: true
                )
            }
        }

        // =========================================================
        // 3. UNIT TEST
        // =========================================================
        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        // =========================================================
        // 4. MUTATION TESTING
        // =========================================================
        stage('Mutation Tests - PIT') {
            steps {
                sh 'mvn org.pitest:pitest-maven:mutationCoverage'
            }
        }

        // =========================================================
        // 5. SONARQUBE / SAST
        // =========================================================
        stage('SonarQube - SAST') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'sonar-token',
                        variable: 'SONAR_TOKEN'
                    )
                ]) {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar \
                            -Dsonar.projectKey=numeric-application \
                            -Dsonar.host.url=http://localhost:9000/ \
                            -Dsonar.login="$SONAR_TOKEN"
                    '''
                }
            }
        }

        // =========================================================
        // 6. FILE SYSTEM / DEPENDENCY / OPA SCANS
        // =========================================================
        stage('TRIVY FS / OWASP / OPA Scans') {
            parallel {

                stage('Trivy FS Scan') {
                    steps {
                        sh '''
                            echo "=== Trivy File System Scan ==="
                            trivy fs . > trivyfs.txt
                        '''
                    }
                }

                stage('OWASP Dependency Check') {
                    steps {
                        dependencyCheck(
                            additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit',
                            odcInstallation: 'DC'
                        )

                        dependencyCheckPublisher(
                            pattern: '**/dependency-check-report.xml'
                        )
                    }
                }

                stage('OPA Conftest') {
                    steps {
                        sh '''
                            echo "=== OPA Conftest Scan ==="

                            docker run --rm \
                                -v "$(pwd):/project" \
                                openpolicyagent/conftest \
                                test \
                                --policy opa-k8s-security.rego \
                                k8s_deployment_service.yaml
                        '''
                    }
                }
            }
        }

        // =========================================================
        // 7. DOCKER BUILD & PUSH
        // =========================================================
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

                        echo "=== Docker Build ==="
                        echo "Image: $IMAGE_NAME"

                        docker build -t "$IMAGE_NAME" .

                        echo "=== Docker Push ==="
                        docker push "$IMAGE_NAME"

                        docker logout
                    '''
                }
            }
        }

        // =========================================================
        // 8. IMAGE / KUBERNETES SECURITY SCANS
        // =========================================================
        stage('Security Scans - Image / Kubernetes') {
            parallel {

                stage('Trivy Image Scan') {
                    steps {
                        sh '''
                            echo "=== Trivy Image Scan ==="

                            trivy image "$IMAGE_NAME" > trivyimage.txt
                        '''
                    }
                }

                stage('Trivy Kubernetes Scan') {
                    steps {
                        sh '''
                            echo "=== Trivy Kubernetes Scan ==="

                            chmod +x trivy-k8s-scan.sh
                            bash ./trivy-k8s-scan.sh
                        '''
                    }
                }

                stage('KubeSec Scan') {
                    steps {
                        sh '''
                            echo "=== KubeSec Scan ==="

                            chmod +x kube-scan.sh
                            bash ./kube-scan.sh
                        '''
                    }
                }
            }
        }

        // =========================================================
        // 9. EKS AUTHENTICATION
        // =========================================================
        stage('EKS Authentication') {
            steps {
                sh '''
                    echo "=== Updating EKS kubeconfig ==="

                    aws eks update-kubeconfig \
                        --name "$CLUSTER_NAME" \
                        --region "$AWS_DEFAULT_REGION"

                    echo "=== AWS Identity ==="
                    aws sts get-caller-identity

                    echo "=== Test EKS Connectivity ==="
                    kubectl get nodes

                    echo "=== Test Kubernetes Authorization ==="
                    kubectl auth can-i get pods --all-namespaces
                '''
            }
        }

        // =========================================================
        // 10. UPDATE IMAGE & DEPLOY
        // =========================================================
        stage('Deploy to EKS - Dev') {
            steps {
                sh '''
                    echo "=== Updating Kubernetes Image ==="

                    sed -i \
                        "s#image: replace#image: $IMAGE_NAME#g" \
                        k8s_deployment_service.yaml

                    echo "=== Kubernetes Image ==="
                    grep "image:" k8s_deployment_service.yaml

                    echo "=== Deploying to EKS ==="

                    kubectl apply \
                        -f k8s_deployment_service.yaml

                    echo "=== Deployment Status ==="

                    kubectl get deployments
                    kubectl get pods
                '''
            }
        }
    

    //=============================================================
    //integration test
    //=============================================================

   stage('Integration Tests - DEV') {
    steps {
        script {
            try {
                echo "=== Running Integration Tests ==="

                sh '''
                    chmod +x integration-test.sh
                    bash integration-test.sh
                '''

                echo "=== Integration Tests Passed ==="

            } catch (e) {

                echo "=== Integration Tests FAILED ==="
                echo "Rolling back deployment..."

                sh """
                    kubectl rollout undo deployment/${deploymentName} \
                        -n default

                    kubectl rollout status deployment/${deploymentName} \
                        -n default \
                        --timeout=120s
                """

                throw e
            }
        }
    }
    }
                

    // =============================================================
    // POST ACTIONS
    // =============================================================
    
}
post {

        always {

            junit(
                testResults: 'target/surefire-reports/*.xml',
                allowEmptyResults: true
            )

            jacoco(
                execPattern: 'target/jacoco.exec'
            )

            pitmutation(
                mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            )

            dependencyCheckPublisher(
                pattern: 'target/dependency-check-report.xml'
            )
        }

        success {
            echo '========================================'
            echo '   DEVSECOPS PIPELINE SUCCESS'
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo '   DEVSECOPS PIPELINE FAILED'
            echo '========================================'
        }
    }
}
