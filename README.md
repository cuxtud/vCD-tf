# Create Org
## VCD Organization and VDC Terraform Configuration

This Terraform configuration creates and manages a VMware Cloud Director (VCD) organization, its Virtual Data Center (VDC), and associated IP spaces.

## Prerequisites

- Terraform installed (version 0.12 or higher)
- Access to VMware Cloud Director
- Proper credentials and permissions configured

## Resources Created

### Organization (vcd_org)
- Name: Accepted as input in the service catalog
- Configured with:
  - VM quotas
  - vApp lease settings
  - Account lockout policies
  - Template lease settings
  - Add Admin user with Org admin role. 
  - Admin password is an input from the morpheus catalog form.

### Virtual Data Center (vcd_org_vdc)
- Name: Accepted as input in the service catalog
- Allocation Model: AllocationVApp
- Configured with:
  - Compute capacity (CPU and Memory)
  - Storage profile
  - Network quotas
  - VM quotas
  - admin user with org admin role
  - add a default network with allocation of prefix 10.0.0.0/24 with gw 10.0.0.1.


### IP Space (vcd_ip_space)
- Configured with multiple IP prefixes:
  - 192.168.100.0/26 - 50 prefixes
  - 172.18.0.0/26 - 250 prefixes
  - 10.2.0.0/26 - 250 prefixes
  - 192.168.50.0/25 - 50 prefixes
  - 172.17.0.0/25 - 250 prefixes
  - 10.1.0.0/25 - 250 prefixes
  - 192.168.0.0/24 - 50 prefixes
  - 172.16.0.0/24 - 250 prefixes
  - 10.0.0.0/24 - 250 prefixes
- Allocates all the above prefixes to the new org

### T1 Edge Gateway (vcd_nsxt_edgegateway)
- Name: orgname edge gateway
- SNAT rule with public ip allocated from public IP space.

## Morpheus 
### Subtenant 
  - Name: Same name as vCD Org
  - Account: Same admin user and password as the vCD Admin user
  - Cleans up any inherited default clouds and groups
  - Add a group 
  - Add a cloud of type vcd
- The above is done via the python script in python directory.

## Usage

1. Add this repo to morpheus as a git integration
2. Create a spec template of type terraform in library -> templates and refer the repo. The path should be ```./createOrg```
3. Create an instance type and add a layout of type terraform to the instance type.
4. Refer the sepc template in the layout
5. Create a tf profile in the vmware vcenter cloud type
6. vars with sensitive data and default values to be added to the tf profile
7. Edit the layout and scope the tf profile which gets added to cypher
8. Add a python task with the working path of the python script.
9. Add a provisioning workflow and add the task in the post provisioning phase
10. Try a test deploy using Instances -> Add.
11. Create a form with all the inputs to be requested from the user catalog.
12. Create a catalog of type instance and use the form for input type
13. Map the morpheus vars to the tf vars input expected from the user
14. Make sure the catalog is accessible to the correct user role as this would be part of tenant onboarding.

