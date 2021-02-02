##
# Container to run the suite of tests defined
#
# This file uses Layer caching, please consider using that going forward
##
FROM python:3.7-alpine

RUN apk add --no-cache bash && \
    apk add --no-cache py-pip && \
    apk add --no-cache --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev make curl g++

RUN apk add --no-cache grep openssh-client jq sshpass

COPY requirements.txt /quickstart-f5-big-ip-virtual-edition-ha/requirements.txt


# Install requirements
RUN pip install -U pip
RUN pip install -r /quickstart-f5-big-ip-virtual-edition-ha/requirements.txt
RUN pip install taskcat

# Set run cmd
CMD [ "/bin/bash" ]

