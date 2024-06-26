pipeline {
    agent any

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch to build')
        credentials(name: 'dockerhub', description: 'DockerHub credentials')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('SCM Checkout') {
            steps {
                script {
                    git branch: "${params.BRANCH_NAME}", url: 'https://github.com/rudiori8/vault.git', credentialsId: 'personal-git'
                    sh 'ls -l'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    docker.withRegistry('', "${params.dockerhub}") {
                        def image = docker.build("rudiori/sonar-test:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonarqube scanner'
            }
            steps {
                withSonarQubeEnv('sonarqube server') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage('Run Container and List Files') {
            steps {
                script {
                    docker.image("rudiori/sonar-test:${env.BUILD_ID}").inside {
                        sh 'ls -l'
                    }
                }
            }
        }
    }
}
