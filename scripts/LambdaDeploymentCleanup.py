#!/usr/bin/python

from __future__ import print_function
import os
import sys
import time
import botocore
import boto3
import cfnresponse
import json
import logging

log = logging.getLogger()
log.setLevel(logging.INFO)

def handler(event, context):
    print('Received event: %s' % json.dumps(event,indent=2))
    try:
      region      = event['ResourceProperties']['region']
      bucket_name = event['ResourceProperties']['bucketName']
      asg_name    = event['ResourceProperties']['autoscalingGroupName']

      if event['RequestType'] == 'Create' or event['RequestType'] == 'Update':
        # Tell CFT custom resource was successfully created and handled 
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, None )
      elif event['RequestType'] == 'Delete':
        # Create EC2 client
        try:
          s3_client = boto3.client('s3', region_name=region ) # Create Autoscale client
        except botocore.exceptions.ClientError as e:
          print(str(e))
          sys.exit("Exiting...")

        try:
          asg_client = boto3.client('autoscaling', region_name=region ) # Create Autoscale client
        except botocore.exceptions.ClientError as e:
          print(str(e))
          sys.exit("Exiting...")

        s3 = boto3.resource('s3')
        ec2 = boto3.resource('ec2')
        instances = []
        asg = ""

        # Delete items in S3 Bucket so CFT can delete it
        bucket = s3.Bucket(bucket_name)
        if bucket.objects.all().delete():
          bucket.delete()
        else:
          cfnresponse.send(event, context, cfnresponse.FAILED, {}, None)

        # Removing Scale-In protection from Master 
        for instance in asg_client.describe_auto_scaling_instances()['AutoScalingInstances']:
          if asg_name == instance['AutoScalingGroupName']:
            instances.append( instance['InstanceId'])
            asg = instance['AutoScalingGroupName']
        if instances:
          print('Auto Scale: Removing Scale-In protection from Master: %s' % (str(instances)))
          asg_client.set_instance_protection(
              InstanceIds = instances,
              AutoScalingGroupName=asg,
              ProtectedFromScaleIn=False
          )
        # Sucessfully handled event
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, None)
      else:
        cfnresponse.send(event, context, cfnresponse.FAILED, {}, None)

    except Exception as e:
        print('Exception in handling the request, %s' % (str(e)))
        cfnresponse.send(event, context, cfnresponse.FAILED, {}, None)