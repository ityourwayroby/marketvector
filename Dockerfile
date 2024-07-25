# Use the official Jenkins inbound agent base image
FROM jenkins/inbound-agent:latest

# Set the user to root to install software packages
USER root

# Update the package list and install necessary packages
RUN apt-get update && apt-get install -y \
    # Install system utilities
    curl \
    wget \
    zip \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    # Install development tools
    build-essential \
    git \
    jq \
    htop \
    # Install Python
    python3 \
    python3-pip \
    python3-venv \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip \
    && unzip terraform_1.4.6_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.4.6_linux_amd64.zip

# Install eksctl
RUN curl -s --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o /tmp/eksctl.tar.gz \
    && tar xz -C /tmp -f /tmp/eksctl.tar.gz \
    && mv /tmp/eksctl /usr/local/bin/ \
    && rm /tmp/eksctl.tar.gz

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install additional Node.js versions using nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm alias default node

# Set up a Python virtual environment and install additional Python packages
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools \
    && /opt/venv/bin/pip install \
    requests \
    boto3 \
    ansible

# Install Golang
RUN wget https://golang.org/dl/go1.19.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz \
    && rm go1.19.3.linux-amd64.tar.gz \
    && echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile \
    && mkdir -p /go/bin \
    && echo "export GOPATH=/go" >> /etc/profile \
    && echo "export PATH=$PATH:/go/bin" >> /etc/profile

# Switch back to the Jenkins user
USER jenkins

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="/usr/local/go/bin:$PATH:/opt/venv/bin"

# Expose default Jenkins agent port
EXPOSE 50000

# Set entrypoint to run Jenkins agent
ENTRYPOINT ["jenkins-agent"]

# Define default command to start Jenkins agent
CMD [""]

# Optional: Add additional scripts or configuration files
# COPY scripts/ /usr/local/bin/
