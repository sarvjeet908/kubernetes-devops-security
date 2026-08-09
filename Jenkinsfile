pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true" // we want to skiptest     second time checking    3rd      4th time   5th 
              archive 'target/*.jar' //so that they can be downloaded later sarvjeet
            }
        }   
      stage('unit test') {
            steps {
              sh "mvn test" // we want to skiptest     second time checking    3rd      4th time   5th 
            }
            post {
            always {
               junit 'target/surefire-reports/*.xml'
               jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }

      stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker-hub', toolName: 'docker'){   //what is this toolName: 'docker'  //this is the name of the docker installation in jenkins
                       sh "printenv"
                       sh "docker build -t sarvjeet908/udemy:5 ."
                       sh "docker push sarvjeet908/udemy:5"
                    }
                }
            }
        }

      stage ("Deploy to eks  dev environment"){
            steps{
                script{
                    sh "kubectl delete -f k8s/"
                }
            }
        }  
    }

    //it took days two fix one issue with creds but fixed it finally///jjjjjj
}
