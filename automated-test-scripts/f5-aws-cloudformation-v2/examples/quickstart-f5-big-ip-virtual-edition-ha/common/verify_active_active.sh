#  expectValue = "SUCCESS"
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 20

FLAG='FAIL'

stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
echo "stack_name: ${stack_name}"

private_key='/etc/ssl/private/dewpt_private.pem'
if [[ "<CREATE NEW KEY PAIR>" == 'true' ]]; then
    # created by verify_login.sh
    private_key='/etc/ssl/private/new_key.pem'
fi
echo "Private key: ${private_key}"

PASSWORD='<SECRET VALUE>'
if [[ "<CREATE NEW SECRET>" == 'true' ]]; then
    unique_string=$(aws cloudformation describe-stacks --stack-name ${stack_name} --region <REGION> | jq -r '.Stacks[].Parameters[]| select (.ParameterKey=="uniqueString") | .ParameterValue')
    secret_name=${unique_string}-bigIpSecret
    secret_arn=$(aws secretsmanager list-secrets --region <REGION> --filters Key=name,Values=${secret_name} | jq -r .SecretList[0].ARN)
    PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${secret_arn} | jq -r .SecretString)
fi
echo "PASSWORD: ${PASSWORD}"

bastion=$(aws cloudformation describe-stacks --stack-name ${stack_name} --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bastionHost") | .OutputValue')
bigip1_stackname=$(aws cloudformation describe-stacks --stack-name ${stack_name} --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigipInstance01") | .OutputValue')
bigip1_instance_id=$(aws cloudformation describe-stacks --stack-name  ${bigip1_stackname} --region <REGION> | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="bigIpInstanceId")| .OutputValue')
bigip2_stackname=$(aws cloudformation describe-stacks --stack-name ${stack_name} --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigipInstance02") | .OutputValue')
bigip2_instance_id=$(aws cloudformation describe-stacks --stack-name  ${bigip2_stackname} --region <REGION> | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="bigIpInstanceId")| .OutputValue')
echo "BIGIP1 Instance Id: $bigip1_instance_id"
echo "BIGIP2 Instance Id: $bigip2_instance_id"

bigip1_private_ip=$(aws ec2 describe-instances --region  <REGION> --instance-ids $bigip1_instance_id | jq -r .Reservations[0].Instances[0].PrivateIpAddress)
echo "BIGIP1 PRIVATE IP: $bigip1_private_ip"
bigip2_private_ip=$(aws ec2 describe-instances --region  <REGION> --instance-ids $bigip2_instance_id | jq -r .Reservations[0].Instances[0].PrivateIpAddress)
echo "BIGIP2 PRIVATE IP: $bigip2_private_ip"

state=$(sshpass -p ${PASSWORD} ssh -o "StrictHostKeyChecking no" -o ProxyCommand="ssh -o 'StrictHostKeyChecking no' -i ${private_key} -W %h:%p ec2-user@$bastion" admin@${bigip1_private_ip} "tmsh show sys failover")
state2=$(sshpass -p ${PASSWORD} ssh -o "StrictHostKeyChecking no" -o ProxyCommand="ssh -o 'StrictHostKeyChecking no' -i ${private_key} -W %h:%p ec2-user@$bastion" admin@${bigip2_private_ip} "tmsh show sys failover")

echo "State: $state"
echo "State2: $state2"

# evaluate result
if echo $state | grep 'active' && echo $state2 | grep 'active'; then
    echo "SUCCESS"
fi
