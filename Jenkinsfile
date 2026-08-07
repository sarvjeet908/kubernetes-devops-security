pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true" // we want to skiptest     second time checking
              archive 'target/*.jar' //so that they can be downloaded later 
            }
        }   
    }
}
