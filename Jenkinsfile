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
    }

//////////////////////////////////////////////////////
// Checkout
//////////////////////////////////////////////////////
stages {
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

        writeFile file: 'ansible/inventory.ini', text: """
[jenkins]
${env.JENKINS_IP} ansible_user=ec2-user

[web]
${env.WEB_IP} ansible_user=ec2-user
"""
    }
}
//////////////////////////////////////////////////////
// Wait for SSH
//////////////////////////////////////////////////////
stage('Wait For SSH') {
    steps {
        withCredentials([
            sshUserPrivateKey(
                credentialsId: 'aws-key',
                keyFileVariable: 'SSH_KEY',
                usernameVariable: 'SSH_USER'
            )
        ]) {
            script {
                def hosts = [env.JENKINS_IP, env.WEB_IP]
                for (host in hosts) {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            def status = sh(
                                script: """
                                    chmod 400 "$SSH_KEY"
                                    ssh \
                                      -i "$SSH_KEY" \
                                      -o BatchMode=yes \
                                      -o StrictHostKeyChecking=no \
                                      -o UserKnownHostsFile=/dev/null \
                                      -o ConnectTimeout=10 \
                                      ${SSH_USER}@${host} "echo READY"
                                """,
                                returnStatus: true
                            )
                            if (status == 0) {
                                echo "${host} is reachable."
                                return true
                            }
                            echo "Waiting for ${host}..."
                            sleep 15
                            return false
                        }
                    }
                }
            }
        }
    }
}
//////////////////////////////////////////////////////
// Test Ansible Connectivity
//////////////////////////////////////////////////////
stage('Ansible Ping') {
    steps {
        sshagent(credentials: ['aws-key']) {
            dir("${ANSIBLE_DIR}") {
                sh 'ansible all -i inventory.ini -m ping'
            }
        }
    }
}
//////////////////////////////////////////////////////
// Configure Servers
//////////////////////////////////////////////////////
stage('Run Ansible') {
    steps {
        sshagent(credentials: ['aws-key']) {
            dir("${ANSIBLE_DIR}") {
                sh 'ansible-playbook -i inventory.ini site.yml'
            }
        }
    }
}

stage('Verify Jenkins Docker Access') {
    steps {
        sh '''
            echo "===== HOST ====="
            hostname

            echo "===== USER ====="
            whoami

            echo "===== ID ====="
            id

            echo "===== DOCKER GROUP ====="
            getent group docker || true

            echo "===== DOCKER SOCKET ====="
            ls -l /var/run/docker.sock

            echo "===== DOCKER ====="
            docker version

            echo "===== DOCKER PS ====="
            docker ps
        '''
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
        sshagent(credentials: ['aws-key']) {
            sh """
ssh \
-o StrictHostKeyChecking=no \
ec2-user@${env.WEB_IP} '
docker pull ${DOCKER_IMAGE}:latest
docker stop web || true
docker rm web || true
docker run -d \
--restart unless-stopped \
--name web \
-p 80:80 \
${DOCKER_IMAGE}:latest
'
"""
        }
    }
}
//////////////////////////////////////////////////////
// Health Check
//////////////////////////////////////////////////////
stage('Health Check') {
    steps {
        sh '''
for i in {1..20}
do
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${WEB_IP})
if [ "$STATUS" = "200" ]; then
    echo "Application is healthy"
    exit 0
fi
echo "Waiting for application..."
sleep 15
done
echo "Health check failed"
exit 1
'''
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
