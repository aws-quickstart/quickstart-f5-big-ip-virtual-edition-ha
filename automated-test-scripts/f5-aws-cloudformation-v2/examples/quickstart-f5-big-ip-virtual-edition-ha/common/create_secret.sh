#  expectValue = "ARN"
#  scriptTimeout = 10
#  replayEnabled = false
#  replayTimeout = 0

aws secretsmanager create-secret --name <DEWPOINT JOB ID>-secret --secret-string '<SECRET VALUE>' --region <REGION> | jq -r .
