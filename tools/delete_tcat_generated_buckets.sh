#!/usr/bin/env bash

# Intended to delete/clean-up auto-generated s3 buckets

arr=$(aws s3api list-buckets --query "Buckets[].Name" | jq -c '.[]')

for i in ${arr[@]}
do
   temp="${i%\"}"
   bucketName="${temp#\"}"
   if [[ $bucketName == "tcat"** ]]; then
        echo ">>>> Deleting s3 bucket: $i"
        sleep 3
        aws s3 rb s3://$bucketName --force
   fi
done



