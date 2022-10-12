#  expectValue = 'AUTO_PASSED'
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 5

mkdir -p /tmp/<DEWPOINT JOB ID>/declarations
bucket_name=`echo dd-<DEWPOINT JOB ID>|cut -c -60|tr '[:upper:]' '[:lower:]'| sed 's:-*$::'`
src_ip=$(curl ifconfig.me)/32

if [[ "<LICENSE TYPE>" == "byol" ]]; then
    regKey01='<AUTOFILL EVAL LICENSE KEY>'
    regKey02='<AUTOFILL EVAL LICENSE KEY 2>'
fi

echo "copy declarations and update secret/key pair"
cp -avr $PWD/declarations /tmp/<DEWPOINT JOB ID>/

secret_arn=''
ssh_key=''
if [[ "<CREATE NEW SECRET>" == 'false' ]]; then
    secret_arn=$(aws secretsmanager list-secrets --region <REGION> --filters Key=name,Values=<DEWPOINT JOB ID>-secret | jq -r .SecretList[0].ARN)
fi
if [[ "<CREATE NEW KEY PAIR>" == 'false' ]]; then
    ssh_key='dewpt'
fi

# Set CFE tag
/usr/bin/yq e ".extension_services.service_operations.[1].value.externalStorage.scopingTags.f5_cloud_failover_label = \"<DEWPOINT JOB ID>\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 01>
/usr/bin/yq e ".extension_services.service_operations.[1].value.externalStorage.scopingTags.f5_cloud_failover_label = \"<DEWPOINT JOB ID>\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 02>
/usr/bin/yq e ".extension_services.service_operations.[1].value.failoverAddresses.scopingTags.f5_cloud_failover_label = \"<DEWPOINT JOB ID>\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 01>
/usr/bin/yq e ".extension_services.service_operations.[1].value.failoverAddresses.scopingTags.f5_cloud_failover_label = \"<DEWPOINT JOB ID>\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 02>

if [[ "<LICENSE TYPE>" == "byol" ]]; then
# Add RegKey for BYOLs
    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey01\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 01>
    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey02\"" -i /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 02>
fi

# Update taskcat test configs with correct runtime url
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.bigIpRuntimeInitConfig01 = \"https://${bucket_name}.s3.amazonaws.com/<RUNTIME CONFIG FILE 01>\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.bigIpRuntimeInitConfig02 = \"https://${bucket_name}.s3.amazonaws.com/<RUNTIME CONFIG FILE 02>\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.keyPairName = \"${ssh_key}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.secretArn = \"${secret_arn}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.cfeTag = \"<DEWPOINT JOB ID>\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.remoteAccessCIDR = \"${src_ip}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.restrictedSrcAddressApp = \"${src_ip}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>
/usr/bin/yq e ".tests.f5ve-ha-<STACK TYPE>.parameters.restrictedSrcAddressMgmt = \"${src_ip}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>

echo "RUNTIME CONFIG: <RUNTIME CONFIG FILE 01>"
cat /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 01>
echo "RUNTIME CONFIG: <RUNTIME CONFIG FILE 02>"
cat /tmp/<DEWPOINT JOB ID>/declarations/<RUNTIME CONFIG FILE 02>
echo "TASKCAT CONFIG: <CONFIG FILE>"
cat $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/<CONFIG FILE>

aws s3 mb --region <REGION> s3://"$bucket_name"
aws s3api put-bucket-tagging --bucket $bucket_name  --tagging 'TagSet=[{Key=delete,Value=True},{Key=creator,Value=dewdrop}]'
OUTPUT=$(aws s3 cp --region <REGION> --recursive /tmp/<DEWPOINT JOB ID>/declarations s3://"$bucket_name" --recursive --acl public-read 2>&1)
echo '------'
echo "OUTPUT = $OUTPUT"
echo "BIGIQ_OUTPUT = $BIGIQ_OUTPUT"
echo '------'

if grep -q failed <<< "$OUTPUT" ; then
    echo AUTO_FAILED
elif grep -q failed <<< "$BIGIQ_OUTPUT" ; then
    echo AUTO_FAILED
else
	echo AUTO_PASSED
fi