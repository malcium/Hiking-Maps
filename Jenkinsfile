pipeline {
    agent { label 'master' }
    stages {
        stage('build') {
            steps {
                sh 'xcodebuild -project "Hiking Maps.xcodeproj" -target "Hiking Maps" -configuration "Debug"'
            }
        }
    }
}