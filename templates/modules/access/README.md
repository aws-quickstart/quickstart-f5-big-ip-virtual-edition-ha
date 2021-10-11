# Deploying Access Template

[![Releases](https://img.shields.io/github/release/f5networks/f5-aws-cloudformation-v2.svg)](https://github.com/f5networks/f5-aws-cloudformation-v2/releases)
[![Issues](https://img.shields.io/github/issues/f5networks/f5-aws-cloudformation-v2.svg)](https://github.com/f5networks/f5-aws-cloudformation-v2/issues)




## Contents

- [Deploying Access Template](#deploying-access-template)
  - [Contents](#contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Resources Provisioning](#resources-provisioning)
    - [Template Input Parameters](#template-input-parameters)
    - [Template Outputs](#template-outputs)
  - [Resource Creation Flow Chart](#resource-creation-flow-chart)



## Introduction

This solution uses an AWS Cloud Formation template to launch a stack for provisioning Access related items. This template can be deployed as a standalone; however the main intention is to use as a module for provisioning Access related resources:

  - AWS IAM Role
  - AWS IAM Instance Profile
  
## Prerequisites

  - None. This template does not require provisioning of additional resources.
  
  
## Resources Provisioning

  * [AWS IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html):
    - Creates IAM roles for standalone, failover and autoscale solutions
  * [AWS IAM Instance Profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)
    - Instance profile is associated with IAM Role and assigned to EC2 instance used for hosting BIGIP system
    
### Template Input Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| solutionType| No | Defines solution type to select provision correct IAM role |
| s3Bucket | No | Provides BIG-IP S3 Bucket name used for failover solution |
| createBigIqRoles | No | Value of true creates IAM roles required to revoke license assignments from BIG-IQ |
| bigIqSecretArn | No | The ARN of the AWS secret containing the password used during BIG-IP licensing via BIG-IQ |
| application | No | Name of the Application Tag |
| environment | No | Name of the Environment Tag |
| group | No | Name of the Group Tag |
| owner | No | Name of the Application Tag |
| costcenter | No | Name of the Cost Center Tag |


### Template Outputs

| Name | Description | Required Resource | Type |
| --- | --- | --- | --- |
| StackName | bigip-standalone nested stack name | bigip-standalone template deployment | String |
| BigipInstanceProfile | BIGIP instance profile with applied IAM policy  | IAM Instance Profile and IAM Instance Role | string |
| LambdaAccessRole | IAM policy for BIG-IQ lambda function  | Lambda IAM role | string |
| CopyZipsRole | IAM policy for CopyZips lambda function | CopyZips IAM role | string |
| BigIqNotificationRole | IAM policy for BIG-IQ Lifecycle Hook notifications | BIG-IQ notification IAM role | string |

## Resource Creation Flow Chart


![Resource Creation Flow Chart](../../../images/aws-access-module.png)






``