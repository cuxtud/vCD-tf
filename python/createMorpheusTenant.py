import requests
from urllib.parse import urlencode
import json
import string
import secrets
import base64
from morpheuscypher import Cypher
requests.packages.urllib3.disable_warnings()
c = Cypher(morpheus=morpheus,ssl_verify=False)


class MorpheusTenantManager:
    def __init__(self, morpheus):
        self.tenant = morpheus['customOptions']['subTenant']
        self.group = morpheus['customOptions']['vDC_name']
        self.bearer_token = morpheus['morpheus']['apiAccessToken']
        self.host = morpheus['morpheus']['applianceHost']
        self.morph_headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.bearer_token}"
        }
        self.user_password = self._generate_password()
        self.tenant_user = morpheus['customOptions']['vCD_org'] + "-admin"
        self.tenant_pass = morpheus['customOptions']['org_admin_password']  

    def _generate_password(self, length=12):
        letters = string.ascii_letters
        digits = string.digits
        special_chars = "@-_$"
        
        password = [
            secrets.choice(letters.lower()),    
            secrets.choice(letters.upper()),     
            secrets.choice(digits),             
            secrets.choice(special_chars)        
        ]
        
        all_chars = letters + digits + special_chars
        password.extend(secrets.choice(all_chars) for _ in range(length - 4))
        
        secrets.SystemRandom().shuffle(password)
        
        return ''.join(password)

    def create_tenant(self):
        url = f"https://{self.host}/api/accounts"
        b = {
            "account": {
                "name": self.tenant,
                "description": "Created via API",
                "role": {"id": 9},
                "currency": "EUR"
            }
        }
        body = json.dumps(b)
        response = requests.post(url, headers=self.morph_headers, data=body, verify=False)
        data = response.json()
        if not data['success'] == True:
            print(f"Failed to create subtenant with url {url} and body {b}.")
            print(f"API response: {data}")
            exit()
        else:
            print(f"Subtenant {self.tenant} successfully created. Subtenant id {data['account']['id']}.")
        return data['account']['id']

    def create_subtenant_admin_user(self, tenant_id):
        print(f"Creating subtenant user in tenant {tenant_id}.")
        url = f"https://{self.host}/api/accounts/{tenant_id}/users"
        # print("Url : " + url)
        print(f"Generated password: {self.user_password} for user testuser with in subtenant with id {tenant_id}.") 
        b = {
            "user": {
                "username": self.tenant_user,
                "email":  self.tenant_user + "@morpheusdata.com",
                "firstName": "Admin",
                "lastName": "User",
                "password": self.tenant_pass,
                "roles": [{"id": 6}]
            }
        }
        body = json.dumps(b)
        response = requests.post(url, headers=self.morph_headers, data=body, verify=False)
        data = response.json()
        if not data['success'] == True:
            print(f"Failed to create subtenant admin user with url {url} and body {b}.")
            print(f"API response: {data}")
            exit()
        else:
            print(f"Subtenant Admin user: testuser successfully created with password: {self.user_password}.")
            #print(f"API response: {data}")
        return response.json()

    def get_access_token(self, tenant_id):
        print(f"Get access token for testuser in tenant with id {tenant_id}.")
        header = {"Content-Type": "application/x-www-form-urlencoded; charset=utf-8"}
        url = f"https://{self.host}/oauth/token?grant_type=password&scope=write&client_id=morph-api"
        # print(f"URL to get access token: {url}")
        user = f"{tenant_id}\\"+ self.tenant_user
        b = {
            'username': user, 
            'password': self.tenant_pass
        }
        print(f" Body to get access token for tenant user - {b}")
        body = urlencode(b)
        response = requests.post(url, headers=header, data=body, verify=False)
        data = response.json()
        # print(f"Debug: API response of access token before If condition: {data}")
        if not data['access_token']:
            print(f"Failed to get access token for the subtenant user {user} with api call to url {url} using method post with body {b}.")
            print(f"API response for getaccess token for subtenant user {data}")
            exit()
        else:
            print(f"API token acquired for subtenant admin user.")
        return data['access_token']

    def create_cypher(self, access_token):
        url = f"https://{self.host}/api/cypher/v1/secret/testuserpass?type=string&ttl=0"
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {access_token}"
        }
        body = json.dumps({"value": self.user_password})  
        # print(f" Body to create cypher with the testuser pass - {body}")
        response = requests.put(url, headers=headers, verify=False)
        return response.json()

    

class GroupManager:
    def __init__(self, host):
        self.host = host
        
    def get_headers(self, access_token):
        return {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {access_token}"
        }
        
    def delete_existing_groups(self, access_token):
        url = f"https://{self.host}/api/groups"
        headers = self.get_headers(access_token)
        response = requests.get(url, headers=headers, verify=False)
        data = response.json()
        # print(data['groups'])

        for group in data['groups']:
            if 'id' in group:
                value = json.loads(str(group['id']))
                delete_url = f"https://{self.host}/api/groups/{value}"
                response = requests.delete(delete_url, headers=headers, verify=False)
    
    def create_group(self, access_token, group_name):
        url = f"https://{self.host}/api/groups"
        headers = self.get_headers(access_token)
        b = {
            "group": {
                "name": group_name,
                "code": None,
                "location": None
            }
        }
        body = json.dumps(b)
        response = requests.post(url, headers=headers, data=body, verify=False)
        group_data = response.json()
        # print (f"Create Group Response data: {group_data}")
        if not group_data['success'] == True:
            print (f"Failed to create group with name {group_name} in sub-tenant.")
        else:
            print (f"Group {group_data['group']['name']} created successfully in sub-tenant.")
        return group_data['group']['id']

class VCDManager:
    def __init__(self,morpheus):
        self.user = morpheus['customOptions']['vCD_org'] + "-admin" + "@" + morpheus['customOptions']['vCD_org']
        self.user_pass = morpheus['customOptions']['org_admin_password']
    
    def get_headers(self):
        return {
            "Content-Type": "application/json",
            "Accept": "application/*;version=38.0",
            "Authorization": f"Basic {base64.b64encode(f'{self.user}:{self.user_pass}'.encode()).decode()}"
        }
    
    def getToken(self, vcd_host):
        #Get OrgId and Vdc ID from vcloud director using api's
        url = f"https://{vcd_host}/cloudapi/1.0.0/sessions/"
        headers = self.get_headers()
        response = requests.post(url, headers=headers, verify=False)
        response_headers = response.headers
        vcd_token = response_headers['x-vmware-vcloud-access-token']
        if not vcd_token:
            print("Failed to fetch vcd token.")
        return vcd_token
    
    def get_vdc_id(self,vcd_host,vcd_token):
        url=f"https://{vcd_host}/cloudapi/1.0.0/vdcs"
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/*;version=38.0",
            "Authorization": f"Bearer {vcd_token}"
        }
        response = requests.get(url, headers=headers, verify=False)
        data = response.json()
        vdc_id = data['values'][0]['id'].split(':')[-1]
        if not vdc_id:
            print("Failed to get vdc id")
        org_id = data['values'][0]['org']['id']
        if not org_id:
            print("Failed to get org id")
        return vdc_id, org_id

class CloudManager:
    def __init__(self, morpheus):
        self.host = morpheus['morpheus']['applianceHost']
        self.zone_name = morpheus['customOptions']['vDC_name']
        self.zone_user = morpheus['customOptions']['vCD_org'] + "-admin" + "@" + morpheus['customOptions']['vCD_org']
        self.zone_pass = morpheus['customOptions']['org_admin_password']
        
    def get_headers(self, access_token):
        return {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {access_token}"
        }
    
    def create_cloud(self, access_token, group_id, vcd_host, vdc_id, org_id):
        url = f"https://{self.host}/api/zones"
        # print (f"Create Cloud API URL: {url}")
        headers = self.get_headers(access_token)
        # print (f"Create Cloud Headers: {headers}")
        b = {
            "zone": {
                "name": self.zone_name,
                "description": None,
                "groupId": group_id,
                "zoneType": {
                    "code": "vcd"
                },
                "config": {
                    "certificateProvider": "internal",
                    "apiUrl": f"https://{vcd_host}",
                    "username": self.zone_user,
                    "password": self.zone_pass,
                    "orgId": org_id,
                    "vdcId": vdc_id
                },
                "code": self.zone_name,
                "labels": [
                    morpheus['customOptions']['vCD_org']
                ],
                "location": "NL",
                "visibility": "private",
                "enabled": "on",
                "autoRecoverPowerState": "off"
            }
        }
        body = json.dumps(b)
        #print (f"Create cloud API Body: {body}")
        response = requests.post(url, headers=headers, data=body, verify=False)
        data = response.json()
        #print (f"Create Cloud API Response: {data}")
        if not data['success'] == True:
            raise Exception("Create Cloud Request failed: " + response.text)
        else:
            print (f"Cloud {data['zone']['name']} created successfully in sub tenant {data['zone']['owner']['name']}.")
        return response.json()

class Main:
    def __init__(self, morpheus):
        self.tenant_manager = MorpheusTenantManager(morpheus)
        self.group_manager = GroupManager(morpheus['morpheus']['applianceHost'])
        self.vcd_manager = VCDManager(morpheus)
        self.cloud_manager = CloudManager(morpheus)
        self.group_name = morpheus['customOptions']['vCD_org']
        self.vcd_host = str(c.get("secret/vcd_host"))
        
    def execute(self):
            tenant_id = self.tenant_manager.create_tenant()
            self.tenant_manager.create_subtenant_admin_user(tenant_id)
            access_token = self.tenant_manager.get_access_token(tenant_id)
            self.tenant_manager.create_cypher(self.tenant_manager.bearer_token)
            self.group_manager.delete_existing_groups(access_token)
            group_id = self.group_manager.create_group(access_token, self.group_name)
            vcdtoken = self.vcd_manager.getToken(self.vcd_host)
            vdc_id, org_id = self.vcd_manager.get_vdc_id(self.vcd_host,vcdtoken)
            self.cloud_manager.create_cloud(access_token, group_id, self.vcd_host, vdc_id, org_id) 

if __name__ == "__main__":
    main = Main(morpheus)
    main.execute() 