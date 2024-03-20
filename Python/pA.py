# pA.py based on the script shared by Jean-François SARDON ARRAZ to be made public on this github repository on Monday March 04, 2024
# API queries to collect information from the Carbonite platform API (pAPI)
# Documentation API :
# US: https://api.serverbackup.carbonite.com/monitoring/swaggerui/index
# EU: https://csb-api.carbonite.eu/monitoring/swaggerui/index

# How to extract the .pem certificate chain for pAPI from https://api.serverbackup.carbonite.com if in the US or https://csb-api.carbonite.eu if in Europe?
# Use Firefox to navigate to
# From the US: https://api.serverbackup.carbonite.com:8081/auth/realms/carbonitemonitoring/protocol/openid-connect/token and click on the Lock
# From the EU: https://csb-api.carbonite.eu:8081/auth/realms/Carbonite-Monitoring/protocol/openid-connect/token and click on the Lock
# Select "Connection Secure"
# Select "More information"
# Select "View Certificate"
# Click on "PEM Chain"> This will download a file called "csb-api.carbonite.eu.pem". You can then copy it to C:\temp\ for example

import json
import requests
import sys
import pandas as pd


client_Id = '<yourClientID>' # example: client_Id = "client_Id" or client_Id = "myportalloginemail@company.com"
client_Secret = '<yourSecret>' # example: client_Secret = '47fe88b7-a4cc-4bb0-8411-f4d15773c180'
pAPIBaseURL = 'https://csb-api.carbonite.eu' #  or if in the US: pAPIBaseURL = 'https://api.serverbackup.carbonite.com'

# function to get the token
def get_carbonite_token(client_id, client_secret, grant_type):
   url = pAPIBaseURL + ':8081/auth/realms/Carbonite-Monitoring/protocol/openid-connect/token'
   headers = {"Content-Type": "application/x-www-form-urlencoded"}
   body = {"grant_type": grant_type,
           "client_id": client_id,
           "client_secret": client_secret}
   response = requests.post(url, headers=headers, data=body, verify='C:\Temp\csb-api.carbonite.eu.pem')  # verify=<path to pem> needed to make the connection secure. We used CA certificate from Sertigo
   return str(response.json()["access_token"])


# function to get the data
def get_data(client_id, client_secret, token, grant_type, data):
   url = pAPIBaseURL + '/monitoring/' + data  # the url to get the data
   header = {"Authorization": "Bearer " + token, "Accept": "application/json;api-version=1"}
   param = {"client_id": client_id, "client_secret": client_secret, "grant_type": grant_type}

   response = requests.get(url, headers=header, params=param, verify='C:\Temp\csb-api.carbonite.eu.pem')  # verify=<path to pem> needed to make the connection secure. We used CA certificate from Sertigo
   if response.status_code != 200:
       return response.status_code, response.json(), response.headers
   return response.json()


# Variables
token = get_carbonite_token(client_Id, client_Secret, "client_credentials")
grant_type = "client_credentials"
jobs = get_data(client_Id, client_Secret, token, grant_type, "jobs")

df_jobs = pd.DataFrame()

df_agents = pd.DataFrame(get_data(client_Id, client_Secret, token, grant_type, "agents"))
df_agents = pd.json_normalize(df_agents['value'])

df_companies = pd.DataFrame(get_data(client_Id, client_Secret, token, grant_type, "companies"))
df_companies = pd.json_normalize(df_companies['value'])

# print(get_data(client_Id, client_Secret, token, grant_type,"vaults"))
# df_vaults = pd.DataFrame(get_data(client_Id, client_Secret, token, grant_type,"vaults"))
# df_vaults = pd.json_normalize(df_vaults['value'])


# Main
for objet in jobs['value']:
   compteur_enabled = 0
   # Job_Id = objet["id"]
   Agent_Id = objet["agentId"]
   JobName = objet["name"]
   Type = objet["type"]
   LastAttemptedBackup_status = objet["lastAttemptedBackupStatus"]
   LastAttemptedBackup = objet["lastAttemptedBackupTimeUtc"]
   LastCompletedBackup = objet["lastCompletedBackupTimeUtc"]
   vaultComputerId = objet["vaultComputerId"]
   isDeleted = objet["isDeleted"]
   usedPoolSize = 0
   physicalPoolSize = 0

   temp_info_agents = df_agents.query(f"id == '{Agent_Id}'")[['hostName', 'companyId']]
   hostName = temp_info_agents['hostName'].iloc[0]
   Client_Id = temp_info_agents['companyId'].iloc[0]

   temp_info_companies = df_companies.query(f"id == '{Client_Id}'")[['name']]
   Client = temp_info_companies['name'].iloc[0]

   # Checking the Vault exists
   if (objet['jobInfoInVaults'] == []):
       customerShortName = "no Vault"
   else:
       # Vault_Id = objet['jobInfoInVaults'][0]['vaultId']
       customerShortName = objet['jobInfoInVaults'][0]['customerShortName']
       usedPoolSize = objet['jobInfoInVaults'][0]['usedPoolSize']
       physicalPoolSize = objet['jobInfoInVaults'][0]['physicalPoolSize']
       if usedPoolSize is not None:
           usedPoolSize = int(usedPoolSize / (1024 ** 3))
       if physicalPoolSize is not None:
           physicalPoolSize = int(physicalPoolSize / (1024 ** 3))

       # temp_info_vaults = df_vaults.query(f"id == '{Vault_Id}'")

       # Nested information. Creation of a dataframe
       # vault_nodes_info = temp_info_vaults['vaultNodesInfo'].iloc[0]
       # df_vault_nodes_info = pd.json_normalize(vault_nodes_info)
       # vaultNodesInfo = temp_info_vaults['vaultNodesInfo']['hostname'].iloc[0]
       # vaultName = df_vault_nodes_info['hostname']
       # print(vaultName)
       # sys.exit()

   # Counting enabled schedules
   if len(objet['schedules']) > 0:
       for schedule in objet['schedules']:
           if (schedule['enabled']):
               compteur_enabled += 1

       # Calculated the percentage of enabled schedules versus the total.
       pourcentage = (compteur_enabled / len(objet['schedules'])) * 100

       # Generating the "schedule" variable based on the percentage
       if (pourcentage == 100):
           schedule = "enabled"
       elif (pourcentage == 0):
           schedule = "disabled"
       else:
           schedule = "partial"
   else:
       schedule = "no schedule"

   # Creating a dictionary for each job sorted in a dataframe table
   jobs = {
       "Client": Client,
       "HostName": hostName,
       "JobName": JobName,
       "Type": Type,
       "LastAtmpBkpStatus": LastAttemptedBackup_status,
       "LastAttemptedBkp": LastAttemptedBackup,
       "LastCompleteBkp": LastCompletedBackup,
       "isDeleted": isDeleted,
       "Schedule": schedule,
       "ClientShortName": customerShortName,
       "usedPoolSizeGB": usedPoolSize,
       "PhysicalPoolSizeGB": physicalPoolSize
   }

   df_jobs = pd.concat([df_jobs, pd.DataFrame([jobs])], ignore_index=True)

datetime_cols = ['LastAttemptedBkp', 'LastCompleteBkp']
for col in datetime_cols:
   df_jobs[col] = pd.to_datetime(df_jobs[col], utc=True, errors='coerce').dt.tz_convert('Europe/Paris').dt.strftime(
       '%Y-%m-%d %H:%M:%S')
df_jobs.to_csv('c:/temp/carbonite_srv.csv')


# PS C:\Users\tcailleau\AppData\Local\Programs\Python\Python311\Scripts> .\pip3.11.exe install requests
# Collecting requests
#   Downloading requests-2.31.0-py3-none-any.whl (62 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 62.6/62.6 kB 3.5 MB/s eta 0:00:00
# Collecting charset-normalizer<4,>=2
#   Downloading charset_normalizer-3.3.2-cp311-cp311-win_amd64.whl (99 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 99.9/99.9 kB 6.0 MB/s eta 0:00:00
# Collecting idna<4,>=2.5
#   Downloading idna-3.6-py3-none-any.whl (61 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 61.6/61.6 kB 3.2 MB/s eta 0:00:00
# Collecting urllib3<3,>=1.21.1
#   Downloading urllib3-2.2.1-py3-none-any.whl (121 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 121.1/121.1 kB ? eta 0:00:00
# Collecting certifi>=2017.4.17
#   Downloading certifi-2024.2.2-py3-none-any.whl (163 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 163.8/163.8 kB ? eta 0:00:00
# Installing collected packages: urllib3, idna, charset-normalizer, certifi, requests
# Successfully installed certifi-2024.2.2 charset-normalizer-3.3.2 idna-3.6 requests-2.31.0 urllib3-2.2.1

# [notice] A new release of pip available: 22.3.1 -> 24.0
# [notice] To update, run: python.exe -m pip install --upgrade pip
# PS C:\Users\tcailleau\AppData\Local\Programs\Python\Python311\Scripts> .\pip3.11.exe install pandas
# Collecting pandas
#   Downloading pandas-2.2.1-cp311-cp311-win_amd64.whl (11.6 MB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 11.6/11.6 MB 46.7 MB/s eta 0:00:00
# Collecting numpy<2,>=1.23.2
#   Downloading numpy-1.26.4-cp311-cp311-win_amd64.whl (15.8 MB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 15.8/15.8 MB 27.3 MB/s eta 0:00:00
# Requirement already satisfied: python-dateutil>=2.8.2 in c:\users\tcailleau\appdata\roaming\python\python311\site-packages (from pandas) (2.8.2)
# Collecting pytz>=2020.1
#   Downloading pytz-2024.1-py2.py3-none-any.whl (505 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 505.5/505.5 kB ? eta 0:00:00
# Collecting tzdata>=2022.7
#   Downloading tzdata-2024.1-py2.py3-none-any.whl (345 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 345.4/345.4 kB 20.9 MB/s eta 0:00:00
# Requirement already satisfied: six>=1.5 in c:\users\tcailleau\appdata\roaming\python\python311\site-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
# Installing collected packages: pytz, tzdata, numpy, pandas
# Successfully installed numpy-1.26.4 pandas-2.2.1 pytz-2024.1 tzdata-2024.1

# [notice] A new release of pip available: 22.3.1 -> 24.0
# [notice] To update, run: python.exe -m pip install --upgrade pip
# PS C:\Users\Administrator\AppData\Local\Programs\Python\Python312> python.exe c:/Users/tcailleau/Documents/WindowsPowerShell/Scripts/ForMeOnly/External/pAPI/pA.py
# PS C:\Users\Administrator\AppData\Local\Programs\Python\Python312>


# This will create a c:/temp/carbonite_srv.csv


