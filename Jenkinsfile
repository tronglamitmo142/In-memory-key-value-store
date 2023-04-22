def appName = "in-memory-key-value-service"
def gitUrl = "https://github.com/tronglamitmo142/In-memory-key-value-store"
def branch = "main"
def dockerHubUser = "lamnt67"

pipeline {
    agent {
        node {
            label "34.216.62.137" 
        }
    }
    environment {
        def dockerPass = credentials("docker_password")
        def githubCredentials = credentials("github_credentials")
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout([$class: 'GitSCM',
                    branches: [[name: "${branch}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [], gitTool: 'jgitapache', 
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: "${githubCredentials}",
                        url: "${gitUrl}"]]
                ])
            }
        }
        stage('Deploy Docker image into Docker Hub'){
            steps {
                script {
                    def dockerfileChanged = sh(returnStatus: true, script: 'git diff HEAD^ HEAD --Dockerfile') != 0
                    if (dockerfileChanged) {
                        echo "Create new Dockerfile images"
                        def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                        echo "Commit hash: ${commitHash}"
                        sh "whoami"
                        sh "sudo usermod -aG docker $USER"
                        sh "newgrp docker"
                        sh "docker login -u ${dockerHubUser} -p ${dockerPass}"
                        sh "docker build -t ${appName}:${commitHash} ."
                        sh "docker push ${appName}:${commitHash}"
                    }
                }
            }
        }
    }
}
