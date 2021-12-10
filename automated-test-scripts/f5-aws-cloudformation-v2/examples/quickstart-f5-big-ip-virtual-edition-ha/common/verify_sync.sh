#  expectValue = "SUCCESS"
#  scriptTimeout = 3
#  replayEnabled = true
#  replayTimeout = 5


FLAG='FAIL'
PASSWORD='<SECRET VALUE>'

stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
bastion=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bastionHost") | .OutputValue')
bigip1_stackname=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigipInstance01") | .OutputValue')
bigip1_instance_id=$(aws cloudformation describe-stacks --stack-name  ${bigip1_stackname} --region <REGION> | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="bigIpInstanceId")| .OutputValue')
bigip2_stackname=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigipInstance02") | .OutputValue')
bigip2_instance_id=$(aws cloudformation describe-stacks --stack-name  ${bigip2_stackname} --region <REGION> | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="bigIpInstanceId")| .OutputValue')
echo "BIGIP1 Instance Id: $bigip1_instance_id"
echo "BIGIP2 Instance Id: $bigip2_instance_id"

bigip1_private_ip=$(aws ec2 describe-instances --region  <REGION> --instance-ids $bigip1_instance_id | jq -r .Reservations[0].Instances[0].PrivateIpAddress)
echo "BIGIP1 PRIVATE IP: $bigip1_private_ip"
bigip2_private_ip=$(aws ec2 describe-instances --region  <REGION> --instance-ids $bigip2_instance_id | jq -r .Reservations[0].Instances[0].PrivateIpAddress)
echo "BIGIP2 PRIVATE IP: $bigip2_private_ip"


BIGIP1_SSH_RESPONSE=$(sshpass -p ${PASSWORD} ssh -o "StrictHostKeyChecking no" -o ProxyCommand="ssh -o 'StrictHostKeyChecking no' -i /etc/ssl/private/dewpt_private.pem -W %h:%p ec2-user@$bastion" admin@${bigip1_private_ip} "tmsh show cm sync-status")
echo "BIGIP1_RESPONSE: ${BIGIP1_SSH_RESPONSE}"
BIGIP2_SSH_RESPONSE=$(sshpass -p ${PASSWORD} ssh -o "StrictHostKeyChecking no" -o ProxyCommand="ssh -o 'StrictHostKeyChecking no' -i /etc/ssl/private/dewpt_private.pem -W %h:%p ec2-user@$bastion" admin@${bigip2_private_ip} "tmsh show cm sync-status")
echo "BIGIP2_RESPONSE: ${BIGIP2_SSH_RESPONSE}"


# evaluate responses
if echo ${BIGIP1_SSH_RESPONSE} | grep -q "high-availability" && echo ${BIGIP2_SSH_RESPONSE} | grep -q "high-availability" && echo ${BIGIP1_RESPONSE} | grep -q "All devices in the device group are in sync" && echo ${BIGIP2_RESPONSE} | grep -q "All devices in the device group are in sync"; then
    FLAG='SUCCESS'
fi

echo $FLAG