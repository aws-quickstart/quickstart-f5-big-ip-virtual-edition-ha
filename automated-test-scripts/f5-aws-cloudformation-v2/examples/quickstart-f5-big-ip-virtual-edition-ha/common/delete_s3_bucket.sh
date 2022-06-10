#  expectValue = "PASS"
#  scriptTimeout = 10
#  replayEnabled = false
#  replayTimeout = 0

echo "Start checking s3 buckets for deletion. Searching for taskcat jobs."
aws s3 ls | grep tcat >> s3_buckets.temp
# determine bucket tag value
tcat_id=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2 | cut -d"-" -f12)
echo $tcat_id
while read -a line; do
    check_tag=$(aws s3api get-bucket-tagging --bucket ${line[2]} | jq -r '.TagSet[] | select(.Key=="taskcat-id") | .Value')
    if [[ "$tcat_id" == "$check_tag" ]]; then
        echo "Deleting ${line[2]} , tag value matched tcat id: $check_tag"
        region=$(aws s3api get-bucket-location --bucket ${line[2]} | jq -r .LocationConstraint)
        if [[ -z $region ]]; then
            aws s3 rb s3://${line[2]} --region $region --force
        else aws s3 rb s3://${line[2]} --force
        fi
    else
        echo "Not deleting ${line[2]} , tag value did not match tacat id: $check_tag"
    fi
done <  s3_buckets.temp

# echo "Delete CFE bucket created for deployment"
# stack_name=$(cat taskcat_outputs/tC* | grep  -m1 StackName: | cut -d":" -f2)
# cfe_bucket=$(aws cloudformation describe-stacks --stack-name $stack_name --region <REGION> | jq -r '.Stacks[].Outputs[] | select (.OutputKey=="cfeS3Bucket") | .OutputValue')
# echo "Deleting $cfe_bucket"
# region=$(aws s3api get-bucket-location --bucket $cfe_bucket  | jq -r .LocationConstraint)
# if [[ -z $region ]]; then
#     aws s3 rb s3://${cfe_bucket} --region $region --force
# else aws s3 rb s3://${cfe_bucket} --force
# fi

echo "Delete declarations bucket created for deployment"
declaration_bucket_name=`echo dd-<DEWPOINT JOB ID>|cut -c -60|tr '[:upper:]' '[:lower:]'| sed 's:-*$::'`
echo "Deleting $declaration_bucket_name"
region=$(aws s3api get-bucket-location --bucket $declaration_bucket_name  | jq -r .LocationConstraint)
if [[ -z $region ]]; then
    aws s3 rb s3://${declaration_bucket_name} --region $region --force
else aws s3 rb s3://${declaration_bucket_name} --force
fi
echo "PASS"
