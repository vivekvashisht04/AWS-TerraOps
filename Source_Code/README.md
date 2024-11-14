# AWS TerraOps Project - Source Code

This directory contains all the Terraform configuration files, scripts, and code used in the **AWS TerraOps** project. These files define the infrastructure setup, configuration details, and automation scripts necessary to deploy and manage the cloud environment as documented in the project.

### Terraform Configuration Files
Each Terraform file is organized to define specific aspects of the AWS infrastructure, facilitating easy reference and reuse:

- **main.tf**: The primary file that initializes the infrastructure setup and manages dependencies between different modules.
- **variables.tf**: Defines all the variables used across the Terraform configurations, ensuring reusability and ease of customization.
- **network.tf**: Sets up the Virtual Private Cloud (VPC), subnets, route tables, and Internet Gateway to establish the foundational networking layer.
- **alb.tf**: Configures the Application Load Balancer (ALB), including listener rules and target groups to manage traffic distribution.
- **ec2_autoscaling.tf**: Manages EC2 instances and Auto Scaling Groups, enabling scalability based on the demand for resources.
- **cloudwatch_alarms.tf**: Defines CloudWatch alarms to monitor critical metrics and integrates with SNS for alert notifications.
- **route53.tf**: Configures Route 53 for DNS management, including failover routing to ensure high availability.
- **s3_bucket.tf**: Sets up S3 bucket(s) for storage, primarily for Terraform state storage.
- **iam_roles.tf**: Defines IAM roles, policies, and permissions required for secure access control across AWS resources.

Each file is designed to handle specific components of the AWS infrastructure, allowing for modularity and clarity in deployment and maintenance. These configurations collectively enable the deployment of a scalable, resilient, and automated cloud environment as detailed in the AWS TerraOps project.
