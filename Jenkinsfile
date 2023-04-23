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
                    def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    echo "Commit hash: ${commitHash}"
                    sh "sudo docker login -u ${dockerHubUser} -p ${dockerPass}"
                    sh "sudo docker build -t ${appName}:${commitHash} ."
                    sh "sudo docker tag ${appName}:${commitHash} ${dockerHubUser}/${appName}:${commitHash}"
                    sh "sudo docker push ${dockerHubUser}/${appName}:${commitHash}"
                    sh "sudo docker rmi -f ${appName}:${commitHash}"
                }
            }
        }
        stage("Deploy into Kubernetes cluster"){
            steps {
                script {
                    sh "kubectl get nodes"
                    sh "kubectl apply -f ./kubernetes/deployment.yaml"
                }
            }
        }
    }
}
