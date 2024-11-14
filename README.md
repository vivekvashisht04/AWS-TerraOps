# AWS TerraOps

## Project Workflow

<div align="center">
    <img src="https://github.com/user-attachments/assets/sample-diagram" alt="AWS TerraOps Architecture Diagram">
</div>

## Project Overview
Welcome to **AWS TerraOps**, a scalable and automated infrastructure deployment project leveraging AWS and Terraform. This project demonstrates the ability to deploy and manage infrastructure components with automated scaling and high availability. It includes failover testing, automated instance configuration, and resource management across multiple AWS regions for enhanced resilience.

## Features
- **Automated Infrastructure Deployment:** Use Terraform to deploy and configure EC2 instances, Load Balancers, and VPCs across regions.
- **Auto Scaling and Load Balancing:** Configure Auto Scaling Groups and Application Load Balancers to ensure application availability and performance.
- **Multi-Region Failover:** Implement Route 53 health checks for seamless failover between primary and secondary regions.
- **Nginx Server Automation:** Automatically install and configure Nginx on EC2 instances using user_data scripts.
- **Centralized Monitoring:** Integrate CloudWatch for monitoring resource health and performance.


## AWS Services Used
- **Amazon Virtual Private Cloud (VPC):** For creating isolated network environments.
- **AWS EC2 Instances:** To deploy virtual machines for application hosting.
- **Auto Scaling Groups:** To automatically adjust the number of EC2 instances based on demand.
- **Application Load Balancer (ALB):** To distribute incoming traffic across multiple instances.
- **Amazon Route 53:** For DNS management and multi-region failover routing.
- **CloudWatch:** For centralized logging, monitoring, and alerting of AWS resources.
- **S3 Bucket:** To store Terraform state files and other project assets.
- **IAM Roles and Policies:** For secure access control and permissions management.

## Steps I Did:

### 1) Initial Setup

I started by installing and configuring Terraform and AWS CLI on my local machine.

- **Terraform Installation**: Verified Terraform was installed by running `terraform -version`. Created a **Binaries** folder in `C:\`, placed the Terraform executable there, and updated the system PATH for easy access.
- **AWS CLI Configuration**: Installed AWS CLI, verified with `aws --version`, and configured credentials by creating an IAM user with **AdministratorAccess**. Generated an access key and used `aws configure` to set up AWS credentials.

For **version control**, I initialized Git by creating a `.gitignore` file with exclusions for sensitive files and committed the initial setup. Created a `dev` branch and linked it to the remote GitHub repository.

To manage Terraform state, I created an S3 bucket named **aws-tf-backend-vw-bucket** and configured it as a backend in `main.tf`. This centralized Terraform state and enabled secure state management.

After completing the setup, I ran `terraform init`, `terraform plan`, and `terraform apply` to confirm the S3 bucket creation and backend configuration. Verified the `terraform.tfstate` file appeared as expected in the S3 bucket.

![Initial Setup Diagram](https://github.com/user-attachments/assets/initial-setup-diagram.png)




  
