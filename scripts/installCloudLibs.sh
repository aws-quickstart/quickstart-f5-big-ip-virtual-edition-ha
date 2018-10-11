#!/bin/bash
echo about to execute
checks=0
while [ $checks -lt 120 ]; do echo checking mcpd
    tmsh -a show sys mcp-state field-fmt | grep -q running
    if [ $? == 0 ]; then
        echo mcpd ready
        break
    fi
    echo mcpd not ready yet
    let checks=checks+1
    sleep 10
done
echo loading verifyHash script
if ! tmsh load sys config merge file /config/verifyHash; then
    echo cannot validate signature of /config/verifyHash
    exit
fi
echo loaded verifyHash
declare -a filesToVerify=("/config/cloud/f5-cloud-libs.tar.gz" "/config/cloud/f5-cloud-libs-aws.tar.gz" "/config/cloud/aws/f5.cloud_logger.v1.0.0.tmpl")
for fileToVerify in "${filesToVerify[@]}"
do
    echo verifying "$fileToVerify"
    if ! tmsh run cli script verifyHash "$fileToVerify"; then
        echo "$fileToVerify" is not valid
        exit 1
    fi
    echo verified "$fileToVerify"
done
mkdir -p /config/cloud/aws/node_modules/@f5devcentral
echo expanding f5-cloud-libs.tar.gz
tar xvfz /config/cloud/f5-cloud-libs.tar.gz -C /config/cloud/aws/node_modules/@f5devcentral
echo installing dependencies
tar xvfz /config/cloud/f5-cloud-libs-aws.tar.gz -C /config/cloud/aws/node_modules/@f5devcentral
echo cloud libs install complete
touch /config/cloud/cloudLibsReady
