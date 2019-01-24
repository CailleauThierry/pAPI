<# 
Get-Job.ps1 v 0.0.0.1 on 11/19/2018
From: Thierry Cailleau  pAPI 1.3 installation includes Keycloak for OAuth2 Authetication. Documentation available under:
Carbonite Server Backup API - Monitoring v1.3 - Installation Guide.pdf
#>
#Requires -Version 5
$url = 'https://sys3:8081/auth/realms/carbonite-monitoring/protocol/openid-connect/token'
$headers = @{"Content-Type" = "application/x-www-form-urlencoded";"cache-control"="no-cache"}
$body = "client_id=AdminUser&grant_type=client_credentials&client_secret=5f29c52d-4a61-47b0-8721-1508e8adc0d9&undefined="
$reply = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
Write-Output $reply.'access_token'


<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Try\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Try\pAPI\Token.ps1



StatusCode        : 200
StatusDescription : OK
Content           : {"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0N3haRUZoYmpfMUFhUkMtOG9ydl9GM3RZVUhtNlpOdmFhNWNCOGI3NEwwIn0.eyJqdGkiO
                    iI1ZjUyZTk1NC1kMzQ4LTQ2NDMtODEzYS1mYmRkMzBjNDJlZDEiLCJleHAiOjE...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Content-Length: 2801
                    Content-Type: application/json
                    Date: Fri, 09 Nov 2018 23:10:13 GMT
                    Set-Cookie: KC_RESTART=; Version=1; Expires=Thu, 01-Jan-1970 00:00:1...
Forms             : {}
Headers           : {[Connection, keep-alive], [Content-Length, 2801], [Content-Type, application/json], [Date, Fri, 09 Nov 2018 23:10:13 GMT]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 2801



PS C:\Users\Administrator\Documents\WindowsPowerShell\Try\pAPI> 
#>