pipeline {

    agent any

    environment {

        AWS_DEFAULT_REGION = "ap-south-1"

        TF_DIR = "terraform"

        ANSIBLE_DIR = "ansible"

        APP_DIR = "app"

        DOCKER_IMAGE = "pradeepnayak07/devops-cicd"

        DOCKER_TAG = "${BUILD_NUMBER}"

    }

    options {

        timestamps()

        ansiColor('xterm')

    }

    stages {

        //////////////////////////////////////////////////////
        // Checkout
        //////////////////////////////////////////////////////

        stage('Checkout Source') {

            steps {

                git branch: 'main',
                url: 'https://github.com/welcomepradeep/DevOps-CICD.git'

            }

        }

        //////////////////////////////////////////////////////
        // Terraform Init
        //////////////////////////////////////////////////////

        stage('Terraform Init') {

            steps {

                dir("${TF_DIR}") {

                    sh 'terraform init'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Terraform Validate
        //////////////////////////////////////////////////////

        stage('Terraform Validate') {

            steps {

                dir("${TF_DIR}") {

                    sh 'terraform validate'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Terraform Plan
        //////////////////////////////////////////////////////

        stage('Terraform Plan') {

            steps {

                dir("${TF_DIR}") {

                    sh 'terraform plan -out=tfplan'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Terraform Apply
        //////////////////////////////////////////////////////

        stage('Terraform Apply') {

            steps {

                dir("${TF_DIR}") {

                    sh 'terraform apply -auto-approve tfplan'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Generate Inventory
        //////////////////////////////////////////////////////

        stage('Generate Inventory') {

            steps {

                dir("${TF_DIR}") {

                    script {

                        env.JENKINS_IP = sh(
                                script: 'terraform output -raw jenkins_public_ip',
                                returnStdout: true
                        ).trim()

                        env.WEB_IP = sh(
                                script: 'terraform output -raw web_public_ip',
                                returnStdout: true
                        ).trim()

                    }

                }

                sh """

cat > ansible/inventory.ini <<EOF

[jenkins]

${JENKINS_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/rhelkey2.pem

[web]

${WEB_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/rhelkey2.pem

EOF

"""

            }

        }

        //////////////////////////////////////////////////////
        // Wait for SSH
        //////////////////////////////////////////////////////

        stage('Wait For SSH') {

            steps {

                sh '''

for ip in ${JENKINS_IP} ${WEB_IP}

do

echo "Waiting for $ip..."

until ssh -o StrictHostKeyChecking=no \
-i /var/lib/jenkins/.ssh/rhelkey2.pem \
ec2-user@$ip "echo READY"

do

sleep 10

done

done

'''

            }

        }

        //////////////////////////////////////////////////////
        // Test Ansible Connectivity
        //////////////////////////////////////////////////////

        stage('Ansible Ping') {

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh 'ansible all -i inventory.ini -m ping'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Configure Servers
        //////////////////////////////////////////////////////

        stage('Run Ansible') {

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh 'ansible-playbook -i inventory.ini site.yml'

                }

            }

        }

        //////////////////////////////////////////////////////
        // Docker Build
        //////////////////////////////////////////////////////

        stage('Docker Build') {

            steps {

                dir("${APP_DIR}") {

                    sh """

docker build \
-t ${DOCKER_IMAGE}:${DOCKER_TAG} .

"""

                }

            }

        }

        //////////////////////////////////////////////////////
        // Docker Login
        //////////////////////////////////////////////////////

        stage('Docker Login') {

            steps {

                withCredentials([

                    usernamePassword(

                    credentialsId: 'dockerhub',

                    usernameVariable: 'DOCKER_USER',

                    passwordVariable: 'DOCKER_PASS'

                    )

                ]) {

                    sh '''

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

'''

                }

            }

        }

        //////////////////////////////////////////////////////
        // Push Image
        //////////////////////////////////////////////////////

        stage('Push Docker Image') {

            steps {

                sh """

docker push ${DOCKER_IMAGE}:${DOCKER_TAG}

docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest

docker push ${DOCKER_IMAGE}:latest

"""

            }

        }

        //////////////////////////////////////////////////////
        // Deploy
        //////////////////////////////////////////////////////

        stage('Deploy Application') {

            steps {

                sh """

ssh \
-o StrictHostKeyChecking=no \
-i /var/lib/jenkins/.ssh/rhelkey2.pem \
ec2-user@${WEB_IP} '

docker pull ${DOCKER_IMAGE}:latest

docker stop web || true

docker rm web || true

docker run -d \
--name web \
-p 80:80 \
${DOCKER_IMAGE}:latest

'

"""

            }

        }

        //////////////////////////////////////////////////////
        // Health Check
        //////////////////////////////////////////////////////

        stage('Health Check') {

            steps {

                sh """

sleep 20

curl -I http://${WEB_IP}

"""

            }

        }

    }

    //////////////////////////////////////////////////////
    // Post
    //////////////////////////////////////////////////////

    post {

        success {

            echo "=================================="

            echo "Pipeline Completed Successfully"

            echo "=================================="

            echo "Jenkins : http://${JENKINS_IP}:8080"

            echo "Website : http://${WEB_IP}"

        }

        failure {

            echo "Pipeline Failed"

        }

        always {

            cleanWs()

        }

    }

}
