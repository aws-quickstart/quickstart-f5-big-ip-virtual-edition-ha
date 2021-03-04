#  expectValue = "PASS"
#  scriptTimeout = 10
#  replayEnabled = false
#  replayTimeout = 0
stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
aws cloudformation delete-stack --region <REGION> --stack-name $stack_name
echo "PASS"