## AWS ECS Deployment Automation

This project automates the deployment of a static website on AWS ECS using Jenkins for CI/CD. It includes Docker for containerization and Terraform for infrastructure provisioning.

## Overview

- **Jenkins**: CI/CD server running on EC2.
- **Docker**: For containerization of web application.
- **Terraform**: For provisioning infrastructure.
- **AWS Services**: ECR (for Docker images), S3 (for Terraform state), DynamoDB (for state locking), and ECS (for container orchestration).

## Prerequisites and set up

1. **Jenkins Server**:
   - EC2 instance with Jenkins.
   - Installed: Docker, Terraform, Git, and AWS CLI.

   ```bash
   # Update packages and install required software

   # Installing docker and adding jenkins user to docker group
   sudo yum update -y
   sudo yum install docker -y
   docker --version
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo chmod 770 /var/run/docker.sock

   # Installing terraform
   sudo wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip
   sudo unzip terraform_1.3.7_linux_amd64.zip
   sudo mv terraform /usr/local/bin
   terraform -v

   # Installing git
   sudo yum install git -y
   git --version

   # Installing aws cli
   sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   sudo unzip awscliv2.zip
   sudo ./aws/install
   aws --version
   
   # Install Jenkins- Check documentation: https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
   sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
   sudo yum upgrade
   sudo yum install java-17-amazon-corretto -y
   sudo yum install jenkins -y
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   sudo usermod -aG docker jenkins
   ```

2. **AWS Setup**:

   - **Create ECR Repository for Docker Images**
   - **Create S3 Bucket for Terraform State Files**
   - **Create DynamoDB Table for Terraform State Locking**

   - **Create IAM Role with Necessary Permissions Attached to the Jenkins Server**:
     1. Sign in to the AWS Management Console and open IAM 
     2. In the navigation pane, choose **Roles**.
     3. Choose **Create role**.
     4. In the **Create role** page, select **AWS service** and choose **EC2**.
     5. Attach the following policies:
        - **AmazonEC2FullAccess**
        - **AmazonS3FullAccess**
        - **AmazonDynamoDBFullAccess**
        - **AmazonECS_FullAccess**
        - **AmazonECRFullAccess**
        - **AWSCloudFormationFullAccess**
        - **AmazonVPCFullAccess** 
     6. For **Role name**, enter `jenkins-role`.
     7. Choose **Create role**.
     8. Navigate to your jenkins EC2 instance.
     9. Choose **Actions**, then **Security**, and then **Modify IAM role**.
     10. Select the IAM role (`jenkins-role`) and attach it to the instance.

3. **GitHub Repository**:
   - Contains Terraform scripts, ECS task and service definitions, application code, and Jenkinsfiles.

   ```bash
   # Navigate to the directory where you want to clone the repository
   # Clone the repository
   git clone https://github.com/essiendaniel2013/marketvector.git
   ```
   - Make all necessary crendentials and parameters changes in the terraform codes, pipeline lists and the Jenkinsfiles
   - Atfer push them to you repository
     
## Deployment Process

1. **Configure Seed Job**:
   - Use the seed job in Jenkins to create two pipelines:
     - **infrastructure-provision pipeline**: Sets up ECS cluster, CloudWatch, and related resources.
     - **continuous-integration-continuous-deployment pipeline**: Handles Docker image building, ECR push, ECS task definition registration, and ECS service creation and updates.

2. **Run infrastructure-provision pipeline**:
   - Triggers terraform to provision the required AWS infrastructure.

3. **Run continuous-integration-continuous-deployment pipeline**:
   - Builds and pushes the Docker image to ECR.
   - Updates ECS task definition and service.
   - Deploys the application and verifies via the load balancer’s DNS name.
  
## Webhook Configuration

- Set up a GitHub webhook to trigger Jenkins pipelines on code updates.
   - In GitHub repository settings, add webhook with Jenkins URL
   - Example: http://jenkins-server-ip:8080/github-webhook/

## Troubleshooting

- **Jenkins Issues**: Check Jenkins logs and AWS credentials.
- **AWS Deployment Issues**: Verify resources in AWS Console and check CloudWatch logs.
