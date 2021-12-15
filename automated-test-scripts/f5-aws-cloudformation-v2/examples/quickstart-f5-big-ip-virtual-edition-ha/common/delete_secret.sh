#  expectValue = "ARN"
#  scriptTimeout = 10
#  replayEnabled = false
#  replayTimeout = 0

aws secretsmanager delete-secret --secret-id <DEWPOINT JOB ID>-secret --region <REGION> | jq -r .