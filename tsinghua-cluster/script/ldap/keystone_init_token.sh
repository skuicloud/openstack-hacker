#!/bin/bash

export SERVICE_TOKEN=openstack_identity_bootstrap_token
export SERVICE_ENDPOINT="http://10.1.0.82:35357/v2.0"

keystone user-list
