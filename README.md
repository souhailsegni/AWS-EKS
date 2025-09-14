
---
# 🚀 AWS EKS Cluster Deployment using Terraform

This project provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster using **Terraform**.
It includes:
- A **VPC** with public and private subnets.
- **Managed EKS Control Plane**.
- **EKS Node Group** with EC2 worker nodes.
- Configuration of `kubectl` for cluster access.
- IAM mappings to allow users and nodes to access the Kubernetes API.

## Prerequisites
- **Terraform**: Ensure you have Terraform installed. You can download it from [terraform.io](https://www.terraform.io/downloads.html).
- **AWS CLI**: Install and configure the AWS CLI with appropriate credentials. Instructions can be
    found [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- **kubectl**: Install `kubectl` to interact with your Kubernetes cluster. Instructions are available
    [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- **AWS Account**: You need an AWS account with permissions to create the necessary resources.

## Getting Started
 1. **Clone the Repository**:
    ```bash
    git clone https://github.com/souhailsegni/AWS-EKS.git
    cd AWS-EKS
    ```
2. **Configure Variables**: Update the `variables.tf` file to set your desired configurations such as region, cluster name, node group settings, etc.

3. **Initialize Terraform**: Run the following command to initialize the Terraform configuration:
    ```bash
    terraform init
    ```
4. **Plan the Deployment**: Execute the following command to see the resources that will be created:

    ```bash
    terraform plan
    ```
5. **Apply the Configuration**: Run the following command to create the resources:
    ```bash
    terraform apply
    ```
    Confirm the action by typing `yes` when prompted.

6. **Configure kubectl**: After the resources are created, configure `kubctl` to interact with your EKS cluster:
    ```bash
    aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
    ```
    Replace `<your-region>` and `<your-cluster-name>` with your actual AWS region and EKS cluster name.

7. **Verify the Cluster**: Check the nodes in your cluster using:
    ```bash
    kubectl get nodes
    ```
    You should see the nodes in the `Ready` state.
8. **add the mapuser to the aws-auth configmap**:
```bash
kubectl edit -n kube-system configmap/aws-auth
```
Add the following lines to the `mapUsers` section:
```yaml
  mapUsers: |
    - userarn: arn:aws:iam::<account_id>:user/<username>
      username: <username>
      groups:
        - system:masters
```
Replace `<account_id>` with your AWS account ID and `<username>` with the IAM username you
want to grant admin access to the EKS cluster.
to get your account id run:
```bash
aws sts get-caller-identity --query Account --output text
```
to get you username run:
```bash
aws iam list-users --query 'Users[?UserName!=`null`].UserName' --output text
```
after this apply the changes using the command:
```bash
kubectl apply -f aws-auth.yaml
```
9. **Test Access**: Verify that the user has access by running:
```bash
kubectl get nodes
```


**Finally you should see the nodes in the `Ready` state.**

**Check your console to see the created resources.**


## Cleanup
To delete all the resources created by this Terraform configuration, run:
```bash
terraform destroy
```
Confirm the action by typing `yes` when prompted.
This will remove all the AWS resources provisioned for the EKS cluster.

