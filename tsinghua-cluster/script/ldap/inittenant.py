#!/usr/bin/python

# keystoneclient was supposed to be installed before running the script.
from keystoneclient.v2_0 import client

token = "openstack_identity_bootstrap_token"
endpoint = "http://10.1.0.82:35357/v2.0"
block_users = [' compass', 'nova', 'neutron', 'cinder', 'glance']
member_name = '_member_'
t_name = []
member = []

keystone = client.Client(token=token, endpoint=endpoint)

tenants = keystone.tenants.list()
users = keystone.users.list()
roles = keystone.roles.list()

for tenant in tenants:
    t_name.append(tenant.name)

for role in roles:
    if role.name == member_name:
        member = role

for user in users:
    if user.name in block_users:
        continue
    else:
        if user.name not in t_name:
            tenant = keystone.tenants.create( tenant_name = user.name, \
                     description = "Tenant for the user %s" % (user.name), \
                     enabled = True)
            keystone.roles.add_user_role( user, member, tenant )
            print "Adding the tenant %s and grant the role %s to the user %s" % ( tenant.name, member.name, user.name )
