# Create Resource Group(s) for HUB
az deployment sub create \
    --location northeurope \
    --template-file Hub/subscription/resource-groups/resource-groups.bicep \
    --parameters Hub/subscription/resource-groups/param/DEMO.parameters.json

# Deploy VWAN
az deployment group create \
    --resource-group HUB \
    --template-file Hub/network/network-vwan/network-vwan.bicep \
    --parameters Hub/network/network-vwan/param/DEMO.parameters.json

# Deploy IP Groups
az deployment group create \
    --resource-group HUB \
    --template-file Hub/network/network-ipgroups/network-ipgroups.bicep \
    --parameters Hub/network/network-ipgroups/param/DEMO.parameters.json

# Deploy Firewall
az deployment group create \
    --resource-group HUB \
    --template-file Hub/network/network-firewall/network-firewall.bicep \
    --parameters Hub/network/network-firewall/param/DEMO.parameters.json

# Create Resource Group(s) for Spokes
az deployment sub create \
    --location northeurope \
    --template-file Spokes/subscription/resource-groups/resource-groups.bicep \
    --parameters Spokes/subscription/resource-groups/param/DEMO.parameters.json

# Deploy Bastion
az deployment group create \
    --resource-group Bastion_Spoke \
    --template-file Hub/network/network-bastion/network-bastion.bicep \
    --parameters Hub/network/network-bastion/param/DEMO.parameters.json

# Deploy Vnets
az deployment group create \
    --resource-group Spokes \
    --template-file Spokes/network/network-vnets/network-vnets.bicep \
    --parameters Spokes/network/network-vnets/param/DEMO.parameters.json


# Peer Vnets to the Vhub
az deployment group create \
    --resource-group HUB \
    --template-file Hub/network/network-peerings/network-peerings.bicep \
    --parameters Hub/network/network-peerings/param/DEMO.parameters.json


