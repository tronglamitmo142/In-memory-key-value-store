def appName = "in-memory-key-value-service"
def gitUrl = "https://github.com/tronglamitmo142/In-memory-key-value-store"
def branch = "main"
def dockerHubUser = "lamnt67"

pipeline {
    agent {
        node {
            label "52.40.148.134" 
        }
    }
    environment {
        def dockerPass = credentials("docker_password")
        def githubCredentials = credentials("github_credentials")
        def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
        def containerImage = "${dockerHubUser}/${appName}:${commitHash}"
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
                    echo "Create new Dockerfile images"
                    sh "sudo docker login -u ${dockerHubUser} -p ${dockerPass}"
                    sh "sudo docker build -t ${containerImage} ."
                    // sh "sudo docker tag ${containerImage} ${containerImage}"
                    sh "sudo docker push ${containerImage}"
                    sh "sudo docker rmi -f ${containerImage}"
                }
            }
        }
        stage("Deploy into Kubernetes cluster"){
            steps {
                script {
                    sh "kubectl apply -f ./kubernetes/deployment.yaml"
                    sh "kubectl set image deployment/key-value-deployment key-value-app=${containerImage}"
                    sh "kubectl apply -f ./kubernetes/ingress.yaml"
                }
            }
        }
    }
}
