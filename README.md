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


### 2) VPC Creation and Networking

In this phase, I created a `network.tf` file to set up networking resources.

Using references from Terraform Registry and AWS Documentation, I defined the following:

- **VPC**: Created a main VPC with CIDR block `10.0.0.0/16` and tagged as **MainVPC**.
- **Subnets**: Set up a **PublicSubnet1** (`10.0.1.0/24`) with public IP mapping in `us-east-1a`, and a **PrivateSubnet1** (`10.0.2.0/24`) without public IPs.
- **Internet Gateway (IGW)**: Added an Internet Gateway tagged as **MainIGW** for internet access.
- **Public Route Table**: Configured a public route table for **PublicSubnet1** with a default route to the Internet Gateway.

After defining the configurations, I ran `terraform init`, `terraform plan`, and then `terraform apply`. I verified the resources in the AWS Console to ensure they were set up as planned.

![VPC and Networking Diagram](https://github.com/user-attachments/assets/vpc-networking-diagram.png)


### 3) EC2 Instances and Auto Scaling

In this phase, I created an `ec2_autoscaling.tf` file for EC2 and Auto Scaling setup.

Following Terraform Registry and AWS Documentation, I defined the following:

- **Security Group**: Created `AppSecurityGroup` with inbound rules to allow SSH (from my IP only) and HTTP (from anywhere).
- **Launch Template**: Set up a launch template using Amazon Linux 2 AMI, with user data to install and start Nginx.
- **Auto Scaling Group (ASG)**: Configured ASG with a desired capacity of 2 instances and scaling policies to adjust capacity up or down based on demand.

After defining these, I ran `terraform init`, `terraform plan`, and `terraform apply`. I verified the setup by connecting to an EC2 instance and confirming Nginx was running. The ASG and instances were confirmed to be created as expected in the AWS Console.

![EC2 and Auto Scaling Diagram](https://github.com/user-attachments/assets/ec2-autoscaling-diagram.png)


### 4) IAM Roles and S3 Integration

In this phase, I configured IAM roles for EC2 instances to grant permissions to access S3 buckets.

- **IAM Role for EC2**: Created an IAM role named **ec2-role** with a trust policy allowing EC2 to assume this role. Attached the **AmazonS3ReadOnlyAccess** policy to provide read-only S3 access.
- **IAM Instance Profile**: Defined an instance profile named **ec2-instance-profile** and attached it to the EC2 instances via the launch template.
- **S3 Buckets**: Created two S3 buckets:
  - **TerraformStateBucket** for Terraform state storage, with restricted public access.
  - **BackupBucket** for storing backups, also with restricted public access.

I ran `terraform init`, `terraform plan`, and `terraform apply`, then verified on the AWS Console. The IAM role and instance profile were attached to the EC2 instances, and both S3 buckets were successfully created with the expected configurations.

![IAM and S3 Integration Diagram](https://github.com/user-attachments/assets/iam-s3-integration-diagram.png)


### 5) Multi-Region Deployment and Failover

In this phase, I expanded the infrastructure to support multi-region deployment with failover between **us-east-1** and **us-west-2**.

- **Provider Configuration**: Updated the `main.tf` to include `provider "aws"` with an alias for **us-west-2** to manage resources in both regions.

- **Networking Setup**: Updated `network.tf` to:
  - Add a second public subnet (**PublicSubnet2**) in **us-east-1** (for ALB distribution).
  - Configure a new VPC, public and private subnets, an Internet Gateway, and route tables in **us-west-2**.

- **Application Load Balancers (ALBs)**: Created ALBs for each region in `alb.tf`:
  - **Primary ALB** in **us-east-1** with a listener and target group.
  - **Secondary ALB** in **us-west-2** with a similar setup for redundancy.

- **Auto Scaling Groups**: Updated `ec2_autoscaling.tf`:
  - Modified **us-east-1 ASG** to distribute across two public subnets and attach to the primary ALB target group.
  - Created a new **us-west-2 ASG** with similar settings, attaching it to the secondary ALB target group.

- **Route 53**: Defined a hosted zone and failover routing in `route53.tf`:
  - Added **Primary** and **Secondary** records for each ALB with failover routing policies.
  - Configured health checks to monitor ALB health in both regions, enabling automatic failover.

After configuring the files, I ran `terraform init`, `terraform plan`, and `terraform apply`. All resources were verified in the AWS Console, confirming multi-region setup with active failover capability between **us-east-1** and **us-west-2**.

![Multi-Region Deployment Diagram](https://github.com/user-attachments/assets/multi-region-deployment-diagram.png)


### 6) Monitoring and Alerts with CloudWatch

In this phase, I configured monitoring and alerts using CloudWatch and SNS.

- **IAM Policy Update**: Added the `CloudWatchAgentServerPolicy` to the EC2 IAM role in `iam_roles.tf` to allow instances to send metrics to CloudWatch.

- **CloudWatch Agent Installation**: Updated the EC2 instance user data in `ec2_autoscaling.tf` to install and configure the CloudWatch Agent on startup, collecting metrics like memory and disk utilization.

- **CloudWatch Alarms**: Created `cloudwatch_alarms.tf` with the following alarms:
  - **High CPU Utilization**: Triggers when CPU exceeds 80%.
  - **High Memory Utilization**: Triggers when memory usage exceeds 80%.
  - **High Disk Utilization**: Triggers when disk usage exceeds 80%.

- **SNS Notifications**: Set up SNS topics in both regions for alert notifications and subscribed my email for instant alerts.

After defining these resources, I ran `terraform init`, `terraform plan`, and `terraform apply`, then verified the configurations in the AWS Console. I received SNS subscription confirmation emails, which I successfully confirmed.

![CloudWatch Monitoring Setup Diagram](https://github.com/user-attachments/assets/cloudwatch-monitoring-diagram.png)


### 7) Parameterization and Validation

In this phase, I enhanced the flexibility of the Terraform configurations by introducing variables and validation to simplify configuration updates and enforce input criteria.

- **Variables Definition**: Created `variables.tf` with variables for key parameters such as AWS regions, instance types, S3 bucket names, ALB names, Route 53 domain, and SNS notification email. Each variable includes default values and validation to ensure valid input.

- **Configuration Updates**: Updated configuration files to use variables:
  - `alb.tf`: Replaced hardcoded ALB and Target Group names with variable references.
  - `cloudwatch_alarms.tf`: Substituted email endpoint in SNS with a variable.
  - `ec2_autoscaling.tf`: Updated instance types and Auto Scaling configuration with variable values.
  - `network.tf`: Parameterized subnet and availability zones using AWS region variables.
  - `route53.tf`: Set domain and record configurations using variables.
  - `s3_bucket.tf`: Utilized variables for S3 bucket names, including backup and Terraform state.

After these changes, I ran `terraform init`, `terraform plan`, and `terraform apply` to verify the configurations. No changes were detected, confirming the successful application of parameterization.

![Parameterization Diagram](https://github.com/user-attachments/assets/parameterization-diagram.png)


### 8) Testing

1) **Application Load Balancer (ALB) Testing**

For ALB testing, I connected to each instance in both regions and customized the Nginx welcome pages to display unique instance identifiers, making it easy to identify which instance was handling each request.

- **us-east-1 Instances**:
  - First instance:
    ```bash
    echo "Welcome to nginx! Served by instance ID: i-0aad6808354626dab (us-east-1) INSTANCE 1" | sudo tee /usr/share/nginx/html/index.html
    curl http://localhost
    curl http://44.201.4.236
    ```
  - Second instance:
    ```bash
    echo "Welcome to nginx! Served by instance ID: i-0003f08c9125643ef (us-east-1) INSTANCE 2" | sudo tee /usr/share/nginx/html/index.html
    curl http://localhost
    curl http://18.207.173.25
    ```

- **us-west-2 Instances**:
  - First instance:
    ```bash
    echo "Welcome to nginx! Served by instance ID: i-0848e26fb476e924b (us-west-2) INSTANCE 1" | sudo tee /usr/share/nginx/html/index.html
    curl http://localhost
    curl http://18.236.133.124
    ```
  - Second instance:
    ```bash
    echo "Welcome to nginx! Served by instance ID: i-070b3c508dbbb30d5 (us-west-2) INSTANCE 2" | sudo tee /usr/share/nginx/html/index.html
    curl http://localhost
    curl http://34.213.180.233
    ```

With these custom pages in place, I tested both ALBs by retrieving the DNS names:

- **Primary ALB (us-east-1)**: `primary-alb-1361659550.us-east-1.elb.amazonaws.com`
- **Secondary ALB (us-west-2)**: `secondary-alb-1857056899.us-west-2.elb.amazonaws.com`

I ran the following commands in CMD to test each ALB multiple times, verifying that requests were balanced across instances in each region:

```bash
curl http://primary-alb-1361659550.us-east-1.elb.amazonaws.com
curl http://secondary-alb-1857056899.us-west-2.elb.amazonaws.com
```
The responses showed that the traffic was being distributed across the two instances in each region.

Browser Testing: To further verify, I accessed each ALB URL in my local browser and refreshed the page multiple times. I observed the instances alternating, indicating successful load balancing across all configured instances.

This completed the ALB testing phase successfully.










  
