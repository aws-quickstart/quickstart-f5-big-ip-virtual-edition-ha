#  expectValue = "SUCCESS"
#  scriptTimeout = 10
#  replayEnabled = false
#  replayTimeout = 0
#  expectFailValue = "FAILED"

stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
bastion=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bastionHost") | .OutputValue')
dag_stack_name=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="dag") | .OutputValue')
security_group=$(aws cloudformation describe-stacks --stack-name $dag_stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigIpExternalSecurityGroup") | .OutputValue')

echo "Security Group ID: $security_group"
echo "Revoking Ingress rule for 1026 port on internal interface. This is done to make Active-Active"

response=$(aws ec2 revoke-security-group-ingress --region <REGION> --group-id $security_group --protocol udp --port 1026 --source-group $security_group)

if echo $response | grep 'error'; then
    echo "FAILED"
else
    echo "SUCCESS"
fi