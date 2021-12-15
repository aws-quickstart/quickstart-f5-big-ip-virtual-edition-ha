#  expectValue = "SUCCESS"
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 120

stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
response=$(aws cloudformation describe-stacks --region <REGION> --stack-name $stack_name 2>&1)

# verify delete
if echo $response | grep 'does not exist'; then
  echo "SUCCESS"
else
  echo "FAILED"
fi
