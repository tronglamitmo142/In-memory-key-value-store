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
        stage('SAST Scan') {
            steps {
                script {
                    echo "Scan source code with Semgrep"
                    sh "/home/ubuntu/.local/bin/semgrep scan --config=auto -o SAST_report.txt"
                }
            }
        }
        stage('Create Dockerfile'){
            steps {
                script {
                    echo "Create new Dockerfile images"
                    sh "sudo docker build -t ${containerImage} ."
                }
            }
        }
        stage('Image scanning'){
            steps {
                script {
                    sh "Scan Dockerfile with trivy"
                    sh "trivy image --scanners vuln --format json --output image_scanning ${containerImage}"
                }
            }
        }
        stage('Push Dockerfile into Dockerhub'){
            steps {
                script {
                    sh "sudo docker login -u ${dockerHubUser} -p ${dockerPass}"
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
    post {
        success {
            def TOKEN = credentials("telegram_bot_token")
            def CHAT_ID = credentials("telegram_bot_chat_id")
            sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID}
                -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : OK *Published* = YES'
                """)
        }
    }
}
