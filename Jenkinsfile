pipeline {
    agent any

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch to build')
        credentials(name: 'dockerhub', description: 'DockerHub credentials')
        booleanParam(name: 'RUN_STAGES', defaultValue: false, description: 'running the stage')
        booleanParam(name: 'SCAN', defaultValue: false, description: 'sonarQ scan')
        booleanParam(name: 'DELETE_CONTAINER', defaultValue: false, description: 'Delete container after running')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('SCM Checkout') {
            when {
                expression { return !params.RUN_STAGES }
            }
            steps {
                script {
                    git branch: "${params.BRANCH_NAME}", url: 'https://github.com/rudiori8/vault.git', credentialsId: 'personal-git'
                    sh 'ls -l'
                }
            }
        }

        stage('Docker Build') {
            when {
                expression { return !params.RUN_STAGES }
            }
            steps {
                script {
                    docker.withRegistry('', "${params.dockerhub}") {
                        def image = docker.build("rudiori/sonar-test:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            when {
                expression { return !params.SCAN }
            }
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
            when {
                expression { return !params.RUN_STAGES }
            }
            steps {
                script {
                    docker.image("rudiori/sonar-test:${env.BUILD_ID}").inside {
                        sh 'ls -l'
                    }
                }
            }
        }

        stage('Delete Container') {
            when {
                expression { return params.DELETE_CONTAINER }
            }
            steps {
                script {
                    def containerIds = sh(script: "docker ps -a -q --filter ancestor=rudiori/sonar-test:${env.BUILD_ID}", returnStdout: true)?.trim()
                    if (containerIds) {
                        sh "docker rm -f ${containerIds}"
                    } else {
                        echo "No containers found to remove."
                    }
                }
            }
        }
    }
}
