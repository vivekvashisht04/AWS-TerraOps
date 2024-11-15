# AWS TerraOps

## Project Architecture Diagram

<div align="center">
    <img src="https://github.com/user-attachments/assets/e2aa0f06-bc55-419e-90d9-e8b6f5dc7e74" alt="AWS TerraOps Architecture Diagram">
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

![Initial Setup (i)](https://github.com/user-attachments/assets/eb5c7e8f-9cd0-41c0-8bc8-93b4afad2e30)
![Initial Setup (vi)](https://github.com/user-attachments/assets/02fdc050-a6ee-429d-aaed-18ae02d6c13f)
![Initial Setup (xvii)](https://github.com/user-attachments/assets/14b9df22-db61-4d8a-b3fa-54807afc0b19)
![Initial Setup (xxiii)](https://github.com/user-attachments/assets/0bb6b6f1-c67e-4042-85f7-1fed013a568b)



### 2) VPC Creation and Networking

In this phase, I created a `network.tf` file to set up networking resources.

Using references from Terraform Registry and AWS Documentation, I defined the following:

- **VPC**: Created a main VPC with CIDR block `10.0.0.0/16` and tagged as **MainVPC**.
- **Subnets**: Set up a **PublicSubnet1** (`10.0.1.0/24`) with public IP mapping in `us-east-1a`, and a **PrivateSubnet1** (`10.0.2.0/24`) without public IPs.
- **Internet Gateway (IGW)**: Added an Internet Gateway tagged as **MainIGW** for internet access.
- **Public Route Table**: Configured a public route table for **PublicSubnet1** with a default route to the Internet Gateway.

After defining the configurations, I ran `terraform init`, `terraform plan`, and then `terraform apply`. I verified the resources in the AWS Console to ensure they were set up as planned.

![VPC Creation and Networking (iii)](https://github.com/user-attachments/assets/f5ef7d80-19c2-4ccd-bab1-310b4cb8fabc)
![VPC Creation and Networking (vi)](https://github.com/user-attachments/assets/9b20bfcb-6311-4663-a0fd-980599ccc3f7)
![VPC Creation and Networking (xiii)](https://github.com/user-attachments/assets/5d689308-9e5c-4ac9-8691-d5b3437591c2)
![VPC Creation and Networking (xiv)](https://github.com/user-attachments/assets/eb7b9a69-5e98-44af-b704-bdebc34b18a9)



### 3) EC2 Instances and Auto Scaling

In this phase, I created an `ec2_autoscaling.tf` file for EC2 and Auto Scaling setup.

Following Terraform Registry and AWS Documentation, I defined the following:

- **Security Group**: Created `AppSecurityGroup` with inbound rules to allow SSH (from my IP only) and HTTP (from anywhere).
- **Launch Template**: Set up a launch template using Amazon Linux 2 AMI, with user data to install and start Nginx.
- **Auto Scaling Group (ASG)**: Configured ASG with a desired capacity of 2 instances and scaling policies to adjust capacity up or down based on demand.

After defining these, I ran `terraform init`, `terraform plan`, and `terraform apply`. I verified the setup by connecting to an EC2 instance and confirming Nginx was running. The ASG and instances were confirmed to be created as expected in the AWS Console.

![EC2 Instances and Auto Scaling (xii)](https://github.com/user-attachments/assets/aa58ede1-dff6-4b56-a070-f239b9adbcc9)
![EC2 Instances and Auto Scaling (xix)](https://github.com/user-attachments/assets/5d1b0aba-8dbb-49aa-bec3-bc79c6ff8d61)
![EC2 Instances and Auto Scaling (xvii)](https://github.com/user-attachments/assets/b5c3ddb1-d44d-4dbb-bd0e-49c8eb1d4989)
![EC2 Instances and Auto Scaling (xxxiv)](https://github.com/user-attachments/assets/8230b856-0191-4d4f-94a0-b7274772130b)
![EC2 Instances and Auto Scaling (xxxv)](https://github.com/user-attachments/assets/9c256a3c-2b7f-40da-b44e-efe8b2142ddc)



### 4) IAM Roles and S3 Integration

In this phase, I configured IAM roles for EC2 instances to grant permissions to access S3 buckets.

- **IAM Role for EC2**: Created an IAM role named **ec2-role** with a trust policy allowing EC2 to assume this role. Attached the **AmazonS3ReadOnlyAccess** policy to provide read-only S3 access.
- **IAM Instance Profile**: Defined an instance profile named **ec2-instance-profile** and attached it to the EC2 instances via the launch template.
- **S3 Buckets**: Created two S3 buckets:
  - **TerraformStateBucket** for Terraform state storage, with restricted public access.
  - **BackupBucket** for storing backups, also with restricted public access.

I ran `terraform init`, `terraform plan`, and `terraform apply`, then verified on the AWS Console. The IAM role and instance profile were attached to the EC2 instances, and both S3 buckets were successfully created with the expected configurations.

![IAM Roles and S3 Integration (xiii)](https://github.com/user-attachments/assets/fea3799c-06f5-4d9e-8613-d9b6e09ecf76)
![IAM Roles and S3 Integration (xiv)](https://github.com/user-attachments/assets/25f657c7-79ce-4dbf-8e37-c7187ab6fef5)
![IAM Roles and S3 Integration (xvii)](https://github.com/user-attachments/assets/e607c640-6674-40b8-99d0-9f5131d0cd49)



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

![Multi-Region Deployment and Failover (xxviii)](https://github.com/user-attachments/assets/c9e6eff7-50e8-409b-a54d-9ab50e48cbf6)
![Multi-Region Deployment and Failover (xxi)](https://github.com/user-attachments/assets/b0d5379e-b8e4-4f2b-9fba-e73975be2727)
![Multi-Region Deployment and Failover (xxxvii)](https://github.com/user-attachments/assets/712fee81-212a-4be9-b131-ec941891e749)



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

![Monitoring and Alerts with CloudWatch (xv)](https://github.com/user-attachments/assets/ca13cbde-4292-4f24-b401-f8f69ce4d266)
![Monitoring and Alerts with CloudWatch (xvi)](https://github.com/user-attachments/assets/14995685-240f-47a3-82ab-d2d1c527a6ff)
![Monitoring and Alerts with CloudWatch (xvii)](https://github.com/user-attachments/assets/5f4ad658-0412-4d68-a630-bb55a5db3cfc)
![Monitoring and Alerts with CloudWatch (xxv)](https://github.com/user-attachments/assets/47796f70-273a-4819-b626-6c365abe33eb)
![Monitoring and Alerts with CloudWatch (xxvi)](https://github.com/user-attachments/assets/f1761215-788f-49a6-97b4-2dd899f8224d)
![Monitoring and Alerts with CloudWatch (xxvii)](https://github.com/user-attachments/assets/36b63925-52b0-4166-9e40-5338abec7684)



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

![Parameterization and Validation (i)](https://github.com/user-attachments/assets/2cda9129-c2cc-4675-be1e-587c98803ec5)
![Parameterization and Validation (xv)](https://github.com/user-attachments/assets/2e091463-33cc-47f2-ba82-683cce6fafe2)



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


![Application Load Balancer (ALB) Testing (vii)](https://github.com/user-attachments/assets/0abf7d0f-c451-4ed2-ba4f-e39abc00126a)
![Application Load Balancer (ALB) Testing (viii)](https://github.com/user-attachments/assets/d7287573-cd2d-4562-b0d8-00a6aa0e7956)



2) **Route 53 Failover Testing**


In this phase, I tested Route 53 failover functionality by setting up a private Route 53 hosted zone and conducting a failover simulation.

Using references from Terraform Registry and AWS Documentation, I defined the following:

- **Route 53 Private Hosted Zone**: Configured `myinfra.local` as a private hosted zone, associated with both `MainVPC` in `us-east-1` and `WestVPC` in `us-west-2`.
- **Failover Records**: Created primary and secondary failover A records for **app.myinfra.local** to route traffic to the primary and secondary ALBs in each region.
- **Health Checks**: Configured Route 53 health checks for both the primary (us-east-1) and secondary (us-west-2) ALBs to enable automatic failover.

After defining the configurations, I ran `terraform destroy` on existing Route 53 resources, followed by `terraform apply`, and verified the private hosted zone, failover records, and health checks in the AWS Console.

**Failover Simulation**:

1. **Initial Test**: Connected to an EC2 instance in `us-west-2` and ran `curl http://app.myinfra.local`. Results showed responses from instances in **us-east-1**, confirming traffic was routed to the primary region.

2. **Failover Test**:
   - Disabled scaling policies in the `AppASGInstance` Auto Scaling Group in `us-east-1` and detached instances.
   - Updated desired capacity to 0 and stopped both instances in `us-east-1`.
   - Re-ran `curl http://app.myinfra.local` from `us-west-2`, which now returned responses from **us-west-2** instances, verifying successful failover.

3. **Primary Restoration**: Restarted instances in `us-east-1`, re-ran `curl` commands, and verified that traffic reverted to the primary region.

This completed and validated the Route 53 failover testing.

![Route 53 Failover Testing (v)](https://github.com/user-attachments/assets/0bc4d536-7350-4dc8-9478-c13753511968)
![Route 53 Failover Testing (viii)](https://github.com/user-attachments/assets/e131da45-50fa-4202-9438-bbcf1565801d)
![Route 53 Failover Testing (xvi)](https://github.com/user-attachments/assets/58b61d1d-6265-45e2-a9db-706b4f905ab6)
![Route 53 Failover Testing (xix)](https://github.com/user-attachments/assets/ac353b33-38d5-4345-b8c6-ff330d501f55)



3) **Auto Scaling Group (ASG) Validation**


In this testing phase, I validated the Auto Scaling Group (ASG) by configuring CPU utilization alarms to trigger scale-up and scale-down actions.

Using references from Terraform Registry and AWS Documentation, I defined the following:

- **Scale-Up CPU Utilization Alarm**: Configured to trigger if CPU utilization exceeds 80% for 2 evaluation periods, initiating a scale-up policy.
- **Scale-Down CPU Utilization Alarm**: Configured to trigger if CPU utilization drops below 30% for 2 evaluation periods, initiating a scale-down policy.

#### Step 1: Modify CloudWatch Alarms for Testing
First, I removed existing high CPU utilization alarms and replaced them with specific scale-up and scale-down alarms:
- **Scale-Up CPU Utilization Alarm**: Configured for both `us-east-1` and `us-west-2` to scale up instances when CPU utilization is above 80%.
- **Scale-Down CPU Utilization Alarm**: Configured for both `us-east-1` and `us-west-2` to scale down instances when CPU utilization is below 30%.

After defining the configurations, I ran `terraform apply`, successfully updating the ASG configuration in AWS Console.

#### Step 2: Trigger Scale-Up Action
To simulate high CPU utilization and trigger the scale-up alarm, I connected to an EC2 instance in `us-east-1` and ran the following command to stress the server:

```bash
ab -n 5000000 -c 500 http://primary-alb-1361659550.us-east-1.elb.amazonaws.com/
```

As requests processed, the ScaleUpCPUUtilizationAlarm in CloudWatch exceeded the threshold, triggering a new instance creation. I verified this log entry in AppASGInstance:

"Launching a new EC2 instance due to alarm ScaleUpCPUUtilizationAlarm. Desired capacity increased from 1 to 2."

A new EC2 instance was successfully launched in response to the scale-up alarm.

Step 3: Trigger Scale-Down Action
Next, I stopped the stress test, allowing CPU utilization to drop below 30%, activating the ScaleDownCPUUtilizationAlarm. This triggered a scale-down action in AppASGInstance, as reflected in the log:

"Terminating EC2 instance due to alarm ScaleDownCPUUtilizationAlarm. Desired capacity decreased from 2 to 1."

The newly created instance was successfully terminated, completing the scale-down test.

![Auto Scaling Group (ASG) Validation (ii)](https://github.com/user-attachments/assets/a6d1441b-219c-481d-ba73-f8d88810e394)
![Auto Scaling Group (ASG) Validation (iii)](https://github.com/user-attachments/assets/d8ca9364-3262-4ce9-ac62-a5357288cdfd)
![Auto Scaling Group (ASG) Validation (viii)](https://github.com/user-attachments/assets/f01f619d-93f2-4d2c-baf5-00300d5d83df)
![Auto Scaling Group (ASG) Validation (x)](https://github.com/user-attachments/assets/4dc782a8-5828-4933-9303-3a60b68296bf)
![Auto Scaling Group (ASG) Validation (xv)](https://github.com/user-attachments/assets/e4617b6a-6a0e-40c6-9b35-b5852a409ffc)
![Auto Scaling Group (ASG) Validation (xx)](https://github.com/user-attachments/assets/98fd456f-dfec-46cd-86c2-5b36f3fc4a16)



4) **CloudWatch Alarms and Notifications Testing**


In this phase, I validated the CloudWatch alarm notification functionality by testing the **ScaleUpCPUUtilizationAlarm** and verifying email notifications were received through SNS.

#### Step 1: Install Stress Tool

First, I connected to an EC2 instance in the us-east-1 (N. Virginia) region and installed the `stress` tool for CPU load testing:

```bash
sudo yum install stress -y
```

#### Step 2: Trigger the Scale-Up Alarm

To simulate high CPU usage, I ran the following command to create CPU stress:

```bash
stress --cpu 2
```

While this command was running, I monitored the ScaleUpCPUUtilizationAlarm in the AWS CloudWatch Console. As expected, the CPU utilization rose above 80%, reaching 99.1%, which triggered the alarm.

#### Step 3: Verify Notification Email

After the alarm was triggered, I checked my email configured in the SNS topic and successfully received the following notification:

From: AWS Notifications no-reply@sns.amazonaws.com
Subject: CloudWatch Alarm Notification
Message:
You are receiving this email because your Amazon CloudWatch Alarm "ScaleUpCPUUtilizationAlarm" in the US East (N. Virginia) region has entered the ALARM state.
Alarm Details:

Name: ScaleUpCPUUtilizationAlarm
Threshold Crossed: 2 datapoints [99.2%, 98.8%] exceeded the threshold of 80%
Timestamp: Sunday 03 November 2024, 16:41:01 UTC
State Change: OK -> ALARM
The successful receipt of this email confirmed that CloudWatch SNS notifications are functioning as expected.

This completed the testing for CloudWatch alarms and notifications.


![CloudWatch Alarms and Notifications Testing (iv)](https://github.com/user-attachments/assets/7ff8acc2-0da0-423e-81fc-5c724e7216de)
![CloudWatch Alarms and Notifications Testing (v)](https://github.com/user-attachments/assets/09aea099-9687-4d6d-a11e-18f62d7258a5)



### 9) Cleanup

In this final phase, the objective was to decommission all AWS resources created for the project using `terraform destroy` to avoid incurring unnecessary costs. I ensured that all resources across regions, including S3 buckets, Route 53 records, and EC2 instances, were properly removed.

#### Step 1: View Destroy Plan

I began by running the following command to review the destruction plan:

```bash
terraform plan -destroy
```

This showed a total of 63 resources scheduled for deletion.

#### Step 2: Execute Destroy Command

Next, I executed the command to initiate the cleanup:

```bash
terraform destroy -auto-approve
```

#### Step 3: Resolve S3 Bucket Deletion Issue

During the process, I encountered an issue with the S3 bucket (aws-tf-backend-vv-bucket) which failed to delete due to the presence of stored files, including the terraform.tfstate file. To resolve this:

I accessed the aws-tf-backend-vv-bucket in the AWS S3 console.
Manually deleted the contents of the bucket.
After clearing the bucket, I re-ran the destroy command:

```bash
terraform destroy -auto-approve
```

#### Step 4: Verify Deletion

The command successfully deleted all resources. The final output confirmed:

"No changes. No objects need to be destroyed."

This marked the completion of the cleanup phase, with all project resources fully decommissioned.

![Cleanup (ii)](https://github.com/user-attachments/assets/649afbae-643b-4a99-a9ae-527a7b482c7b)



## Conclusion
The **AWS TerraOps** project successfully demonstrated expertise in infrastructure automation, high availability, and scalability using AWS services. By designing, deploying, and testing a multi-region infrastructure with auto-scaling, load balancing, and failover mechanisms, this project showcased comprehensive skills in AWS resource management, infrastructure-as-code (IaC) principles, and automated monitoring and alerting.

## Skills Demonstrated
- **Infrastructure Automation:** Automated the creation and management of AWS resources using Terraform, ensuring consistency and scalability.
- **High Availability and Scalability:** Implemented multi-region load balancing and auto-scaling to ensure resilience and fault tolerance.
- **Failover and Disaster Recovery:** Configured Route 53 with failover routing policies for seamless failover between primary and secondary regions.
- **Monitoring and Alerting:** Set up CloudWatch for real-time monitoring, custom alarms, and notifications for proactive infrastructure management.
- **Security Best Practices:** Utilized IAM roles and policies, VPC configurations, and S3 access restrictions to establish a secure infrastructure environment.

## Repository Contents
- **Manual:** A detailed manual documenting each phase of the project, including configurations, testing procedures, and troubleshooting steps.
- **Screenshots:** Visual documentation of key configurations and stages, providing a clear, step-by-step reference guide.
- **Source Code:** All Terraform configuration files and scripts used in this project, organized in the `Source_Code` folder.

## Contact
For any questions or further information, feel free to reach out to me on LinkedIn: [LinkedIn Profile](https://www.linkedin.com/in/vivek-vashisht04/)














  
