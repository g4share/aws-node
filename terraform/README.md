# Deploy EC2 Instance using Terraform

### Generate the SSH Key Pair
1. Open Terminal on Local Machine and execute the command
   ```console
   ssh-keygen -t ed25519 -f ~/.ssh/aws-virginia.pem
   ```
2. Secure the Private Key
   ```console
   chmod 400 ~/.ssh/aws-virginia.pem
   ```

### Prerequisite 
- Access Key - **IAM / Security credentials / AWS IAM credentials / Access keys**
- aws_config.json - Copy the **aws_config-template.json** file to **aws_config.json** and populate it with your data.


### Commands
1. Switches the current working path to the terraform folder. 
   ```console
    cd terraform
    ```

2. Initializes a Terraform working directory by preparing it for further commands. It needs to be run before executing other commands like apply or plan and anytime the configuration or provider plugins change.
    ```console
    terraform init
    ```

3. Creates an execution plan, showing what actions Terraform will take to change the infrastructure to match the configuration. It's used for reviewing changes before applying them, ensuring control and visibility over what will be modified or created.
    ```console
    terraform plan
    ```
4. Applies the Terraform execution plan without interactive approval, automatically approving the changes.
    ```console 
    terraform apply -auto-approve
    ```

5. Remove all defined resources
    ```console 
   terraform destroy
    ```