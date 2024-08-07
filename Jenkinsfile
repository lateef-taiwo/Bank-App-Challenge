pipeline {
    agent any
    
    environmet {
        NODE_ENV = 'development'
        HOME = "$env.WORKSPACE"
    }

    stages {
        stage('Checkout GitHub Repository'){
            steps{
                // Checkout code from the GitHub Repository
                git url: 'https://github.com/lateef-taiwo/Bank-App-Challenge.git', branch: 'main'

            }
        }
        stage('Install Node and NPM'){
            steps{
                // install node if its not present already
                sh 'sudo apt apdate -y'
                sh 'sudo apt install nodejs npm -y'
                
            }
        }
        stage('Install npm'){
            steps{
                // Install Depencies
            sh 'npm install'
        }
        }
        stage ('Run the Application in Development mode'){
            steps{
                // Start the Development serve
                sh 'npm start'
            }
        }
    }
}