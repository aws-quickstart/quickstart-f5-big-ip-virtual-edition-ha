# quickstart-f5-big-ip-virtual-edition-ha


## High Availability pair of F5 BIG-IP Virtual Editions (VEs) on the AWS Cloud


This Quick Start deploys BIG-IP Virtual Editions (VE), an application delivery and security services platform from F5 Networks, on the Amazon Web Services (AWS) Cloud in about 30 minutes.  

BIG-IP VE provides speed, availability, and security for business-critical applications and networks. It enables intelligent L4-L7 load balancing and traffic management, robust network and web application firewalls, simplified application access, Domain Name System (DNS) services, and much more.

This Quick Start deploys a high availability pair of BIG-IP VE instances provisioned with Local Traffic Manager (LTM), which performs uniform resource identifier (URI) routing, Secure Sockets Layer (SSL) encryption, and automatic discovery of automatically scaled web applications. The Quick Start uses AWS CloudFormation templates to build the AWS infrastructure and to deploy BIG-IP VE.

The Quick Start offers two deployment options:

- Deploying BIG-IP VE into a new virtual private cloud (VPC) on AWS
- Deploying BIG-IP VE into an existing VPC on AWS

You can also use the AWS CloudFormation templates as a starting point for your own implementation.

For architectural details, best practices, step-by-step instructions, and customization options, see 
[clouddocs.f5.com](https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/userguide/aws.html).
