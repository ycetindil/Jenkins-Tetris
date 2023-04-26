pipeline {
    agent any

    environment {
        PIPELINE_NAME = "tetris"
        TF_FOLDER     = "infra-tf"
    }

    stages {
        stage('Login to Azure') {
            steps {
                echo 'Logging into Azure'
                sh 'az login --identity'
            }
        }

        stage('Create infrastructure for the App') {
            steps {
                dir("/var/lib/jenkins/workspace/${PIPELINE_NAME}/${TF_FOLDER}") {
                    echo 'Creating Infrastructure for the App'
                    sh 'terraform init'
                    sh 'terraform apply --auto-approve'
                }
            }
        }

        stage('Login to ACR') {
            steps {
                dir("/var/lib/jenkins/workspace/${PIPELINE_NAME}/${TF_FOLDER}") {
                    echo 'Injecting Terraform outputs'
                    script {
                        env.ACR_NAME = sh(script: 'terraform output -raw acr_name', returnStdout:true).trim()
                        env.ACR_PASSWORD = sh(script: 'terraform output -raw acr_password', returnStdout:true).trim()
                    }
                }
                echo 'Logging into ACR'
                sh "docker login -u ${ACR_NAME} -p ${ACR_PASSWORD} ${ACR_NAME}.azurecr.io"
            }
        }

        stage('Build Docker image') {
            steps {
                echo 'Building Docker image'
                sh "docker build -t ${ACR_NAME}.azurecr.io/tetris ."
            }
        }

        stage('Push Docker image to ACR') {
            steps {
                echo 'Pushing Docker image to ACR'
                sh "docker push ${ACR_NAME}.azurecr.io/tetris"
            }
        }

        stage('Deploy web app') {
            steps {
                dir("/var/lib/jenkins/workspace/${PIPELINE_NAME}/${TF_FOLDER}") {
                    echo 'Injecting Terraform outputs'
                    script {
                        env.RG_NAME = sh(script: 'terraform output -raw rg_name', returnStdout:true).trim()
                        env.WEB_APP_NAME = sh(script: 'terraform output -raw web_app_name', returnStdout:true).trim()
                    }
                }
                echo 'Configuring the web app'
                sh "az webapp config container set --name ${ACR_NAME} --resource-group ${RG_NAME} --docker-custom-image-name ${ACR_NAME}.azurecr.io/tetris:latest --docker-registry-server-url https://${ACR_NAME}.azurecr.io --docker-registry-server-user ${ACR_NAME} --docker-registry-server-password ${ACR_PASSWORD}"
            }
        }

        stage('Destroy the Infrastructure') {
            steps {
                timeout(time:5, unit:'DAYS'){
                    input message:'Do you want to destroy the infrastructure?'
                }
                dir("/var/lib/jenkins/workspace/${PIPELINE_NAME}/${TF_FOLDER}") {
                    sh 'terraform destroy --auto-approve'
                }
            }
        }
    }
}