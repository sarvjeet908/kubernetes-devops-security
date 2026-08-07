pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true" // we want to skiptest     second time checking    3rd      4th time   5th 
              archive 'target/*.jar' //so that they can be downloaded later 
            }
        }   
    }
}
