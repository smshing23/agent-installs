#!/bin/bash

####################################################################################################
#                                 Liongard Agent Install Script                                    #
####################################################################################################

# Use this script to install the Liongard Agent. This script allows the setting of improtant
# environment variables before invoking the installer.

####################################################################################################
#                                          Variables                                               #
####################################################################################################

# Enter the corresponding values for the following variables:
#
# INSTANCE_URL (required):The instance URL of your liongard instance. Should be in the format
#   <instance>.app.liongard.com (ex: us1.app.liongard.com)
# ACCESS_KEY_ID (required): The access key ID generated in the platform for agent installs
# ACCESS_KEY_SECRET (required): The access key secret generated in the platform for agent installs
# NAME (optional): The name you would like to give to the agent. If one is not provided, then the
#   agent's name will default to the hostname
# ENVIRONMENT (optional): The name of the environment you would like the agent to be assigned to.
#   This must match the environment name in the platform exactly. If one is not provided, then the
#   agent will be registered without an environment assignment.

INSTANCE_URL=
ACCESS_KEY_ID=
ACCESS_KEY_SECRET=
NAME=
ENVIRONMENT=

####################################################################################################
#                                     Installation Logic                                           #
####################################################################################################

# The script from this point onwards is responsible for setting environment variables before
# invoking the installer to install the LiongardAgent.pkg file. After the installation, the script
# will unset these environment variables. DO NOT MODIFY the script beyond this point. If the
# installation is not working, please contact Liongard support.

if [ -n "$INSTANCE_URL" ]
then
  echo "${INSTANCE_URL}" > /tmp/liongard_instance_url
fi

if [ -n "$ACCESS_KEY_ID" ]
then
  echo "${ACCESS_KEY_ID}" > /tmp/liongard_access_key_id
fi

if [ -n "$ACCESS_KEY_SECRET" ]
then
  echo "${ACCESS_KEY_SECRET}" > /tmp/liongard_access_key_secret
fi

if [ -n "$NAME" ]
then
  echo "${NAME}" > /tmp/liongard_name
fi

if [ -n "$ENVIRONMENT" ]
then
  echo "${ENVIRONMENT}" > /tmp/liongard_environment
fi

installer -pkg Liongard-lts.pkg -target /