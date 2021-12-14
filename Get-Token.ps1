<# 
Get-Token.ps1 v 0.0.0.2 on 04/25/2018
From: Thierry Cailleau  pAPI 1.5 installation includes Keycloak for OAuth2 Authentication. Documentation available under:
Carbonite Server Backup API Client v1.0 - User Guide.pdf
#>
#Requires -Version 5
$url = 'https://papi16.test.local:8081/auth/realms/carbonite-monitoring/protocol/openid-connect/token'
$headers = @{"Content-Type" = "application/x-www-form-urlencoded";"cache-control"="no-cache"}
$body = "client_id=APIadmin&grant_type=client_credentials&client_secret=f2a18478-70dd-4d67-bea6-b9ddee03b180&undefined="
$reply = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
Write-Output $reply.'access_token'


<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1
eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJEMW9iZnhfVW85NUtVM0d4bjNxaWtfWlduMWQ2Z2ZHN2NnTVZIWW41MHhNIn0.eyJqdGkiOiI0MWM2MmIyNC0xYTRhLTRlMzgtYjMwOC1iYmRkYTkwY2U0MTQiLCJleHAiOjE2Mzk1MDc1ODUsIm5iZiI6MCwiaWF0IjoxNjM5NTA3Mjg1LCJpc3MiOiJodHRwczovL3BhcGkxNi50ZXN0LmxvY2FsOjgwODEvYXV0aC9yZWFsbXMvQ2FyYm9uaXRlLU1vbml0b3JpbmciLCJhdWQiOiJBUElhZG1pbiIsInN1YiI6ImQyMWQ1YTFjLWY5NDAtNDQxZS04MTFiLWJkNGJiOGIyMGVjZSIsInR5cCI6IkJlYXJlciIsImF6cCI6IkFQSWFkbWluIiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiMDYxNmE4OTUtZDgyOS00OTczLWJlODUtNzY3ZTY2YTkyOGM4IiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6W10sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7IkFQSWFkbWluIjp7InJvbGVzIjpbInVtYV9wcm90ZWN0aW9uIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJhdWQiOiJ1cm46Y2FyYjpzYjphcGk6bW9uaXRvcmluZyIsImNsaWVudEhvc3QiOiIxOTIuMTY4LjE3OC4xMDEiLCJjbGllbnRJZCI6IkFQSWFkbWluIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWFwaWFkbWluIiwiY2FyYjpzYjphcGk6bW9uaXRvcmluZzphY2Nlc3NfdHlwZSI6ImFkbWluIiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNjguMTc4LjEwMSIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWFwaWFkbWluQHBsYWNlaG9sZGVyLm9yZyJ9.gQvw4Gzgb_LjYM7OOZkXCw-3HlpjX5vQrcpVlNSyxK8trn2SpTy1Iv_Pmlsl9dP0s8SRzb7WozxsIHFVOjhfcAJG7PV4G71Vm6v28pOwX27EqvYEB9om6m3Wh0kAXyGTvqUCFZz16ZVe1YJqZvjHgPVJ7yaOxIVhdkWKYkdCCek54dbX1CW_k_bNEcj2m8kJMzGt93Z9Tj62tY_Iq5bSViwzHHfLmvUV__QeLz1XtQN9gjEHIoEYALYYJqqAtllWdt-qQJoMN1qrkJA1xh-y8ZG_CAAmRqFY8fx-I1xcvlronQcjOEkqUOSkURz80EiaIMLjjL5yaggYc-xVJTqa8w
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI>
#>