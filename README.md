
# AWS Quickstart

## Instructions:

This quickstart template deploys a full demo application stack, including an Auto Scale Group of BIG-IPs sitting in front of two application Auto Scale Groups ( to demonstrate advanced L7 functionality, including URI routing in a typical micro services use case and/or Blue and Green deployment strategy). The BIG-IP configuration contains one virtual server and two pools (all configured via [Application Services Extension](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/3/) - BIG-IP's declarative API similar to Cloudformation). The virtual service is leveraging a URI routing policy and service discovery (which queries for Tags on NICs or Instances to populate the addresses of pool members).

### Deploy master.template

Once deployed *(eta ~ 25 Minutes)* and master.template reports "COMPLETE", to test traffic, navigate to master template's "Outputs" tab and find output for "appUrl".  Click or copy the URL in browser.

ex.
https://f5demo-f5demo-BigipExtLb-450d5f6b2c77bead.elb.us-west-2.amazonaws.com


### To test the Application:

The virtual service is using a self-signed certificate so click through any browser warnings (see your browser documentation for details). You will land on the home page (blue) which is pointed at the pool for the first Auto scale Group. Click on the "API" tab, and you be routed via the URI routing policy to the pool for the second Auto Scale Group (green). 


#### To Explore to BIG-IP itself via Bastion Host

1) Obtain BASTION-HOST's PUBLIC IP address:

    You can first find the output in the master template for "bastionAutoscaleGroup":

    ex. 
    Quickstart-BastionStack-12D20R0QMSN1K-bastionAutoscaleGroup-1RYMR17LSMLUI

    Go to EC2 Console "Auto Scaling Groups" Page and search for the bastion autoscale group. Click on the Auto Scale Group's  "Instances" tab and click on the instance OR go through ECE "Instances" tab directly, and find an instance named "Bastion Host Instance: quickstart"

    Locate the "IPv4 Public IP" in the "Description" Tab.

2) Now obtain the BIG-IP's PRIVATE IP address: 

    Go to the master template's "Output" tab and find output for "bigipAutoscaleGroup":

    ex.
    Quickstart-BIGIPStack-49SKKJZM53FM-bigipAutoscaleGroup-FIIMUG9KXYEC

    Go to EC2 Console's Auto Scale Group's Tab and search for that Auto Scale Group. Go to that Auto Scale Group's "Instances" Tab, and click on the instance (or instance with "Scale-In protection enabled") if more instances were launched. Note the IP in "Private IPs" field in the "Description" Tab.

To Log in the CLI:

Ex. From desktop client/shell, create an SSH tunnel:

```
ssh -i [keyname-passed-to-template.pem] -o ProxyCommand='ssh -i [keyname-passed-to-template.pem] -W %h:%p ubuntu@[BASTION-HOST-PUBLIC-IP]' admin@[BIG-IP-HOST-PRIVATE-IP]
```
replacing variables in brackets.

ex.
```
ssh -i mykey.pem -o ProxyCommand='ssh -i ~/.ssh/mykey.pem -W %h:%p ubuntu@34.221.147.237' admin@172.16.11.112
```

To Log in the GUI:

```
ssh -i [keyname-passed-to-template.pem] ubuntu@[BASTION-HOST-PUBLIC-IP] -L 8443:[BIG-IP-HOST-PRIVATE-IP]:8443
```

You should now be open a browser to the BIG-IP from your desktop:

https://localhost:8443

Click past the Self-Signed Certificate warning and log in with: 
username: **quickstart**
password: **[instance-id]** *(use the instance-id of the first instance launched i.e. instance with Scale-In protection enabled)*


#### EVALUATE URI ROUTING POLICY

In the AppUrl, click on the "API" tab. Noticed it turns green. Requests are being directed to a second pool (in this case, its the green pool but in practice, it would be another service).  You can see this via inspecting statistics:

CLI: 
```
admin@(ip-10-0-11-112)(cfg-sync In Sync)(Active)(/Common)(tmos)# cd /tenant/https_virtual
admin@(ip-10-0-11-112)(cfg-sync In Sync)(Active)(/tenant/https_virtual)(tmos)# show ltm pool
```

GUI:

Local Traffic -> Pools -> Statistics

Go to upper right corner of BIG-IP's UI to the "Partition" dropdown and select "tenant"


You can also inpect the URI Policy Rules executing:

CLI:
```
admin@(ip-10-0-11-112)(cfg-sync In Sync)(Active)(/tenant/https_virtual)(tmos)# show ltm policy forward_policy
```

GUI:
Local Traffic -> Policies -> Statistics -> "uri-routing-policy" -> "Details" -> View


#### EVALUATE BLUE GREEN

You can test manually updating a pool to look a different tag for by updating the Application Service. This requires access the BIG-IP's API port (8443):

From a bash shell, either the bastion host or BIG-IP's:
```
admin@(ip-10-0-11-112)(cfg-sync In Sync)(Active)(/tenant/https_virtual)(tmos)# bash
```
, assuming you have access via tunnel above:

```
#
bigip_username=quickstart
bigip_password=i-0f520d309010d4bd5
bigip_host=10.0.11.112 (or localhost if using tunnel)
bigip_port=8443

curl -sk -u ${bigip_username}:${bigip_password} -H "Content-type: application/json" https://localhost:8443/mgmt/shared/appsvcs/declare | python -m json.tool > virtual_service_defintion.json
```

Edit virtual_service_defintion.json to change the value for fields:
```
   "tagKey": "f5demoapp",
   "tagValue": "f5-demo-app-0.0.1",
```
ex. from 
**"f5-demo-app-0.0.1"** 
to 
**"f5-demo-app-0.0.2"**

So that both pool objects are now pointing at the second Auto Scale Group (with tag "f5demoapp: f5-demo-app-0.0.2").

Update the Virtual Service:
```
curl -sk -u ${bigip_username}:${bigip_password} -H "Content-type: application/json"  -sk  -X POST -d @virtual_service_defintion.json https://${bigip_host}:${bigip_port}/mgmt/shared/appsvcs/declare | python -m json.tool
```

No go back to your AppURL and notice everything is going to green pool. 


#### More Information

For more information, see:

BIG-IP in AWS:
https://clouddocs.f5.com/cloud/public/v1/aws_index.html
https://github.com/f5networks/f5-aws-cloudformation

Application Services
https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/3/
