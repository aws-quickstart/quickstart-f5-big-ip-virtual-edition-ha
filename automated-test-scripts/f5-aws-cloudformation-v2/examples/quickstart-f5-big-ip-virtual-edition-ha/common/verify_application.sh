#  expectValue = "SUCCESS"
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 10


if [[ <PROVISION_WEB_APP> == 'false' ]]; then
    echo "SUCCESS"
else
    stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
    application_public_ip=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="applicationPublicIp") | .OutputValue')

    echo "Application Public IP: $application_public_ip"
    httpsResponse=$(curl -sk https://$application_public_ip)
    httpResponse=$(curl -sk http://$application_public_ip)

    if echo ${httpsResponse} | grep -q "Demo" && echo ${httpResponse} | grep -q "Demo"; then
        echo "SUCCESS"
    fi
fi