## Terraform

### Terraform state file

####  terraform init

#### terraform plan -var-file='../terraform.tfvars' 
####  terraform apply -var-file='../terraform.tfvars' 

Destroy with the commnd

####  terraform destroy -var-file='../terraform.tfvars'

In Four_module dynamically pass how many number of instances you want to update

#### terraform plan -var-file='../terraform.tfvars' -var instance_count=4

#### terraform apply -var-file='../terraform.tfvars' -var instance_count=4

#### terraform destroy -var-file='../terraform.tfvars' -var instance_count=4


#### terraform apply -state="/development/dev.state" -var="environment_name=development"


#### terraform plan -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"

#### terraform apply -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"

#### terraform destroy -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"


#### terraform plan -var-file="../../terraform.tfvars" -var-file="./UAT/uat.tfvars" -state="./UAT/uat.state"

#### terraform apply -var-file="../../terraform.tfvars" -var-file="./UAT/uat.tfvars" -state="./UAT/uat.state"

#### terraform destroy -var-file="../../terraform.tfvars" -var-file="./UAT/uat.tfvars" -state="./UAT/uat.state"



######## $ terraform get                                                                                                                                                                                                                                                                                   [10:49:26]
######## - module.vpc
######## - module.bucket



#### terraform plan -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"

#### terraform apply -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"

#### terraform destroy -var-file="../../terraform.tfvars" -var-file="./Development/development.tfvars" -state="./Development/dev.state"
