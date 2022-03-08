#  expectValue = "SUCCESS"
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 10 


if [[ "<PROVISION_WEB_APP>" == 'false' ]]; then
    echo "SUCCESS"
else
    stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
    echo "stack_name $stack_name"

    workload_stack_name=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="workLoadStack") | .OutputValue')
    echo "workload_stack_name: $workload_stack_name"

    bigip2_stack_name=$(aws cloudformation describe-stacks --stack-name $workload_stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigipInstance02") | .OutputValue')
    echo "bigip2_stack_name: $bigip2_stack_name"

    bigip2_instanceid=$(aws cloudformation describe-stacks --stack-name $bigip2_stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="bigIpInstanceId") | .OutputValue')
    echo "bigip2_instanceid: $bigip2_instanceid"

    application_public_ip=$(aws ec2 describe-instances --region <REGION> --instance-ids $bigip2_instanceid | jq -r '.Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[] |select (.Primary=='false') | .Association.PublicIp')
    echo "application_public_ip: $application_public_ip"

    httpsResponse=$(curl -sk https://$application_public_ip)
    httpResponse=$(curl -sk http://$application_public_ip)

    if echo ${httpsResponse} | grep -q "Demo" && echo ${httpResponse} | grep -q "Demo"; then
        echo "SUCCESS"
    fi
fi