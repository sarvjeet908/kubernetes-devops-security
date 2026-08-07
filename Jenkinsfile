pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true" // we want to skip test
              archive 'target/*.jar' //so that they can be downloaded later 
            }
        }   
    }
}
