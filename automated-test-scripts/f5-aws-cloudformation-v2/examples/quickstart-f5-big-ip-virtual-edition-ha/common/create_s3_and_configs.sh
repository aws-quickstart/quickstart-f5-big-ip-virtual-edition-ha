#  expectValue = 'AUTO_PASSED'
#  scriptTimeout = 2
#  replayEnabled = true
#  replayTimeout = 5

mkdir -p /tmp/<DEWPOINT JOB ID>/declarations
bucket_name=`echo dd-<DEWPOINT JOB ID>|cut -c -60|tr '[:upper:]' '[:lower:]'| sed 's:-*$::'`

if [[ "<LICENSE TYPE>" == "byol" ]]; then
    regKey01='<AUTOFILL EVAL LICENSE KEY>'
    regKey02='<AUTOFILL EVAL LICENSE KEY 2>'
fi


echo "copy declarations and update secret"
cp -avr $PWD/declarations /tmp/<DEWPOINT JOB ID>/

secret_arn=$(aws secretsmanager list-secrets --region <REGION> --filters Key=name,Values=<DEWPOINT JOB ID>-secret | jq -r .SecretList[0].ARN)
# Update runtime init with correct secret
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01-with-app.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02-with-app.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01-with-app.yaml
/usr/bin/yq e ".runtime_parameters.[0].secretProvider.secretId = \"<DEWPOINT JOB ID>-secret\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02-with-app.yaml

# Disable AutoPhoneHome
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02-with-app.yaml

/usr/bin/yq e ".extension_services.service_operations.[2].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01.yaml
/usr/bin/yq e ".extension_services.service_operations.[2].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02.yaml
/usr/bin/yq e ".extension_services.service_operations.[3].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance01-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[3].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-payg-instance02-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[2].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01.yaml
/usr/bin/yq e ".extension_services.service_operations.[2].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02.yaml
/usr/bin/yq e ".extension_services.service_operations.[3].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01-with-app.yaml
/usr/bin/yq e ".extension_services.service_operations.[3].value.Common.My_System.autoPhonehome = false" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02-with-app.yaml

if [[ "<LICENSE TYPE>" == "byol" ]]; then
# Add RegKey for BYOLs
    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey01\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01.yaml
    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey02\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02.yaml

    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey01\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance01-with-app.yaml
    /usr/bin/yq e ".extension_services.service_operations.[0].value.Common.My_License.regKey = \"$regKey02\"" -i /tmp/<DEWPOINT JOB ID>/declarations/runtime-init-conf-2nic-byol-instance02-with-app.yaml
fi

# Update taskcat test configs with correct runtime url
/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.bigIpRuntimeInitConfig01 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-payg-instance01.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat1.yml
/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.bigIpRuntimeInitConfig02 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-payg-instance02.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat1.yml
/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.secretArn = \"${secret_arn}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat1.yml

/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.bigIpRuntimeInitConfig01 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-payg-instance01-with-app.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat2.yml
/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.bigIpRuntimeInitConfig02 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-payg-instance02-with-app.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat2.yml
/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.secretArn = \"${secret_arn}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat2.yml

/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.bigIpRuntimeInitConfig01 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-byol-instance01.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat3.yml
/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.bigIpRuntimeInitConfig02 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-byol-instance02.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat3.yml
/usr/bin/yq e ".tests.f5ve-ha-defaults.parameters.secretArn = \"${secret_arn}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat3.yml


/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.bigIpRuntimeInitConfig01 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-byol-instance01-with-app.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat4.yml
/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.bigIpRuntimeInitConfig02 = \"https://${bucket_name}.s3.amazonaws.com/runtime-init-conf-2nic-byol-instance02-with-app.yaml\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat4.yml
/usr/bin/yq e ".tests.f5ve-ha-prod.parameters.secretArn = \"${secret_arn}\"" -i $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat4.yml


echo "taskcat1"
cat $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat1.yml
echo "taskcat2"
cat $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat2.yml
echo "taskcat3"
cat $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat3.yml
echo "taskcat4"
cat $PWD/automated-test-scripts/data/f5-aws-cloudformation-v2/examples/quickstart-f5-big-ip-virtual-edition-ha/taskcat4.yml


# r=$(date +%s | sha256sum | base64 | head -c 32)

aws s3 mb --region <REGION> s3://"$bucket_name"
aws s3api put-bucket-tagging --bucket $bucket_name  --tagging 'TagSet=[{Key=delete,Value=True},{Key=creator,Value=dewdrop}]'
#aws s3 cp /tmp/<TEMPLATE NAME> s3://"$bucket_name"
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