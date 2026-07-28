pipeline {

    agent any

    environment {

        AWS_DEFAULT_REGION = "ap-south-1"

        IMAGE_NAME = "welcomepradeep/devops-website"

        IMAGE_TAG = "${BUILD_NUMBER}"

    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'main',
                url: 'https://github.com/welcomepradeep/DevOps-CICD.git'

            }

        }

        stage('Terraform Init') {

            steps {

                dir('terraform') {

                    sh 'terraform init'

                }

            }

        }

        stage('Terraform Validate') {

            steps {

                dir('terraform') {

                    sh 'terraform validate'

                }

            }

        }

        stage('Terraform Plan') {

            steps {

                dir('terraform') {

                    sh 'terraform plan'

                }

            }

        }

        stage('Terraform Apply') {

            steps {

                dir('terraform') {

                    sh 'terraform apply -auto-approve'

                }

            }

        }

        stage('Wait For EC2') {

            steps {

                sleep(time:60,unit:"SECONDS")

            }

        }

        stage('Run Ansible') {

            steps {

                dir('ansible') {

                    sh 'ansible-playbook site.yml'

                }

            }

        }

        stage('Docker Build') {

            steps {

                dir('app') {

                    sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'

                }

            }

        }

        stage('Docker Login') {

            steps {

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {

                    sh '''
                    echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                    '''

                }

            }

        }

        stage('Push Docker Image') {

            steps {

                sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'

            }

        }

        stage('Deploy Application') {

            steps {

                sshagent(['ec2-ssh-key']) {

                    sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@WEB_SERVER_IP \
                    "docker pull ${IMAGE_NAME}:${IMAGE_TAG}"

                    ssh -o StrictHostKeyChecking=no ec2-user@WEB_SERVER_IP \
                    "docker stop devops-web || true"

                    ssh -o StrictHostKeyChecking=no ec2-user@WEB_SERVER_IP \
                    "docker rm devops-web || true"

                    ssh -o StrictHostKeyChecking=no ec2-user@WEB_SERVER_IP \
                    "docker run -d --restart always \
                    --name devops-web \
                    -p 80:80 \
                    ${IMAGE_NAME}:${IMAGE_TAG}"
                    '''
                }

            }

        }

        stage('Health Check') {

            steps {

                sh './scripts/health-check.sh'

            }

        }

    }

    post {

        success {

            echo "Pipeline Completed Successfully"

        }

        failure {

            echo "Pipeline Failed"

        }

    }

}
