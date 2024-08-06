Step 1 : Create your jenkins server, make sure to attach an IAM Role with admin permissions and run this as userdata to install all packages :

#!/bin/bash
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

# Install eksctl : 
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install kubectl :
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
mkdir -p /home/jenkins/.kube
cp /root/.kube/config /home/jenkins/.kube/config
chown jenkins:jenkins /home/jenkins/.kube/config
sudo mv ./kubectl /usr/local/bin/kubectl

step 2 : Run the below commands to create your eks cluster : 

eksctl create cluster --name demo-eks --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --managed --nodes 2


Step 3 : Clone the repository : https://github.com/ityourwayroby/marketvector.git

step 4: Edit the Jenkinsfile and yaml files in kubernetes folder accordingly and push to your github repository.
NOTE : Make sure to check your images repositories (ECR or Dockerhub) to make sure your images exist

Step 5 : Create your desired namespace in your cluster and should match your yaml files

Step 6 : Access your jenkins user interface and create a job to point it to your jenkinsfile in the kubernetes folder.

step 7 : Run your job

step 8 : The last stage of the pipeline runs a command to get the services in the required namespace so you can get the loadbalancer DNS nsmae from the console output

Access your application with the loadbalancer DNS Name.

To destroy your cluster, run command below : 

eksctl delete cluster --name demo-eks --region us-east-1
