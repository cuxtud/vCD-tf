import requests
from urllib import urlencode
import json
import string
import secrets


class MorpheusTenantManager:
    def __init__(self, morpheus):
        self.tenant = morpheus['customOptions']['tenant']
        self.group = morpheus['customOptions']['groupName']
        self.bearer_token = morpheus['morpheus']['apiAccessToken']
        self.host = morpheus['morpheus']['applianceHost']
        self.morph_headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.bearer_token}"
        }
        self.user_password = self._generate_password()  # Generate password on init

    def _generate_password(self, length=12):
        """Generate a secure random password"""
        letters = string.ascii_letters
        digits = string.digits
        special_chars = "!@#$%^&*()_+-=[]{}|"
        
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
                "role": {"id": 2},
                "currency": "EUR"
            }
        }
        body = json.dumps(b)
        response = requests.post(url, headers=self.morph_headers, data=body, verify=False)
        data = response.json()
        return data['account']['id']

    def create_subtenant_admin_user(self, tenant_id):
        print("Creating subtenant user")
        url = f"https://{self.host}/api/accounts/{tenant_id}/users"
        print("Url : " + url)
        print(f"Generated password: {self.user_password}")  # Optional: for debugging
        b = {
            "user": {
                "username": "testuser",
                "email": "testuser@morpheusdata.com",
                "firstName": "Test",
                "lastName": "User",
                "password": self.user_password,
                "roles": [{"id": 74}]
            }
        }
        body = json.dumps(b)
        response = requests.post(url, headers=self.morph_headers, data=body, verify=False)
        return response.json()

    def get_access_token(self, tenant_id):
        header = {"Content-Type": "application/x-www-form-urlencoded; charset=utf-8"}
        url = f"https://{self.host}/oauth/token?grant_type=password&scope=write&client_id=morph-api"
        user = f"{tenant_id}\\testuser"
        b = {
            'username': user, 
            'password': self.user_password
        }
        body = urlencode(b)
        response = requests.post(url, headers=header, data=body, verify=False)
        data = response.json()
        return data['access_token']

    def create_cypher(self, access_token):
        url = f"https://{self.host}/api/cypher/v1/secret/paas?type=string&ttl=0"
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {access_token}"
        }
        body = json.dumps({"value": self.user_password})  # Store the user password instead of access token
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
        print(data['groups'])

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
        return response.json()

class Main:
    def __init__(self, morpheus):
        self.tenant_manager = MorpheusTenantManager(morpheus)
        self.group_manager = GroupManager(morpheus['morpheus']['applianceHost'])
        self.group_name = morpheus['customOptions']['groupName']
        
    def execute(self):
        try:
            # Create tenant and get ID
            tenant_id = self.tenant_manager.create_tenant()
            
            # Create subtenant admin user
            self.tenant_manager.create_subtenant_admin_user(tenant_id)
            
            # Create cypher with user password
            self.tenant_manager.create_cypher(self.tenant_manager.bearer_token)
            
            # Get access token
            access_token = self.tenant_manager.get_access_token(tenant_id)
            
            # Handle groups
            self.group_manager.delete_existing_groups(access_token)
            self.group_manager.create_group(access_token, self.group_name)
            
            return True
            
        except Exception as e:
            print(f"Error during execution: {str(e)}")
            return False

if __name__ == "__main__":
    main = Main(morpheus)
    main.execute() 