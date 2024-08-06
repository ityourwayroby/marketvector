```markdown
# Jenkins and EKS Setup Guide

## Step 1: Set Up Jenkins Server

1. **Create a Jenkins Server**:
   - Attach an IAM role with administrative permissions to the instance.
   - Use the following `userdata` script to install all necessary packages:

   ```bash
   #!/bin/bash
   # Update packages and install required software

   # Install Docker and configure permissions
   sudo yum update -y
   sudo yum install docker -y
   docker --version
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo chmod 770 /var/run/docker.sock

   # Install Terraform
   sudo wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip
   sudo unzip terraform_1.3.7_linux_amd64.zip
   sudo mv terraform /usr/local/bin
   terraform -v

   # Install Git
   sudo yum install git -y
   git --version

   # Install AWS CLI
   sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   sudo unzip awscliv2.zip
   sudo ./aws/install
   aws --version

   # Install Jenkins
   # Check documentation: https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
   sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
   sudo yum upgrade
   sudo yum install java-17-amazon-corretto -y
   sudo yum install jenkins -y
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   sudo usermod -aG docker jenkins

   # Install eksctl
   curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
   sudo mv /tmp/eksctl /usr/local/bin

   # Install kubectl
   curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
   chmod +x ./kubectl
   mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
   echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
   mkdir -p /home/jenkins/.kube
   cp /root/.kube/config /home/jenkins/.kube/config
   chown jenkins:jenkins /home/jenkins/.kube/config
   sudo mv ./kubectl /usr/local/bin/kubectl
   ```

## Step 2: Create Your EKS Cluster

Run the following command to create your EKS cluster:

```bash
eksctl create cluster --name demo-eks --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --managed --nodes 2
```

## Step 3: Clone the Repository

Clone the repository that contains the necessary configuration files:

```bash
git clone https://github.com/ityourwayroby/marketvector.git
```

## Step 4: Configure Jenkins

1. **Edit Configuration Files**:
   - Modify the `Jenkinsfile` and the YAML files in the `kubernetes` folder as needed.
   - Push the changes to your GitHub repository.
   - **Note**: Verify that your image repositories (ECR or Docker Hub) contain the necessary images.

## Step 5: Create a Namespace in Kubernetes

Create a namespace in your EKS cluster that matches the one specified in your YAML files.

## Step 6: Set Up Jenkins Job

1. **Access Jenkins UI**:
   - Navigate to the Jenkins user interface.
2. **Create a Job**:
   - Configure a new Jenkins job to point to your `Jenkinsfile` located in the `kubernetes` folder.

## Step 7: Run the Jenkins Job

Execute the Jenkins job you created to deploy your application.

## Step 8: Retrieve Load Balancer DNS

1. **Check Pipeline Output**:
   - The final stage of the pipeline will display the services in the required namespace. Look for the load balancer DNS name in the console output.

2. **Access Your Application**:
   - Use the load balancer DNS name to access your application.

## Cleanup: Destroy Your EKS Cluster

To delete the EKS cluster when no longer needed, run:

```bash
eksctl delete cluster --name demo-eks --region us-east-1
```
```

This version of the `README.md` provides clear, step-by-step instructions with proper formatting and comments. It ensures that each step is easy to follow and understand.
