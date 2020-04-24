param
(
    [string]$RegistrationServiceAddress,
    [string]$ClientID,
    [string]$ClientSecret
)

function ObtainAccessToken(
[Parameter(Mandatory=$true)]
[string]$KeyCloakAddress
)
{
    $keyCloakHeaderParams = @{}
    $keyCloakHeaderParams.Add("Content-Type", "application/x-www-form-urlencoded")

    $keyCloakBodyParams = @{}
    $keyCloakBodyParams.Add("client_id", $ClientID)
    $keyCloakBodyParams.Add("client_secret", $ClientSecret)
    $keyCloakBodyParams.Add("grant_type", "client_credentials")

    $accessTokenResponse = Invoke-WebRequest -Uri $KeyCloakAddress -Method Post -Headers $keyCloakHeaderParams -Body $keyCloakBodyParams
    $accessTokenResponse = ConvertFrom-Json($accessTokenResponse)

    return $accessTokenResponse.access_token
}

function ObtainRegistrationToken()
{
    # Check to see if the XML Variables file exists
    $XMLFilePath = Join-Path $PSScriptRoot 'ORTVariables.xml'
    if (Test-Path $XMLFilePath)
    {
        $loadDictionary = Import-Clixml -Path $XMLFilePath

        if ([string]::IsNullOrEmpty($RegistrationServiceAddress))
        {
            $RegistrationServiceAddress = $loadDictionary.RegistrationServiceAddress
        }

        if ([string]::IsNullOrEmpty($ClientID))
        {
            $ClientID = $loadDictionary.ClientID
        }

        if ([string]::IsNullOrEmpty($ClientSecret))
        {
            $ClientSecret = $loadDictionary.ClientSecret
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # We need to turn off certificate validation in this script because sometimes the Registration Service and KeyCloak
    # are setup with self-signed certificates. I got this snippet of code from here:
    # https://social.technet.microsoft.com/Forums/windowsserver/en-US/79958c6e-4763-4bd7-8b23-2c8dc5457131/sample-code-required-for-invokerestmethod-using-https-and-basic-authorisation?forum=winserverpowershell
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    
    public class ValidateAllPolicy : ICertificatePolicy {
        public ValidateAllPolicy() {}
        public bool CheckValidationResult(
            ServicePoint sPoint, X509Certificate cert,
            WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = new-object ValidateAllPolicy 

    $FailedOnPreviousPass = $false
    while ($true)
    {    
        try
        {
            # Check to see if the RegistrationService parameters have been passed in. If not, prompt for them
            if ([string]::IsNullOrEmpty($RegistrationServiceAddress) -or $FailedOnPreviousPass)
            {
                $RegistrationServiceAddress = Read-Host -Prompt 'Registration Service address'
            }

            if ([string]::IsNullOrEmpty($ClientID) -or $FailedOnPreviousPass)
            {
                $ClientID = Read-Host -Prompt 'Client ID'
            }

            if ([string]::IsNullOrEmpty($ClientSecret) -or $FailedOnPreviousPass)
            {
                $ClientSecret = Read-Host -Prompt 'Client Secret'
            }
            $RegistrationServiceAddress = $RegistrationServiceAddress.TrimEnd('/')

            # Save the RegistrationServiceAddress variable value for later
            $OriginalRegistrationServiceAddress = $RegistrationServiceAddress

            # Construct the header for the requests we want to send to the Registration Service
            $headerParams = @{}
            $headerParams.Add('Content-Type', 'application/json;api-version=1')

            # Construct the body for the requests we want to send to the Registration Service
            $bodyParams = @{}
            $bodyParams.Add('Device', 'Vault')
            $bodyJson = ConvertTo-Json($bodyParams)
            
            # Attempt to connect to the Registration Service. If it throws, something's wrong with the address.
            # Pipe to Out-Null so it doesn't get sent to standard out.
            Invoke-WebRequest -Uri ($RegistrationServiceAddress + '/api/version') -Method GET -Headers $headerParams | Out-Null

            # Append the token endpoint to the Registration Service URI
            $RegistrationServiceAddress = $RegistrationServiceAddress + '/api/tokens'

            # Send a non-authorized token request to the Registration Service. It should throw, and we can extract
            # the KeyCloak token endpoint from the response
            try
            {
                Invoke-WebRequest -Uri $RegistrationServiceAddress -Method Post -Headers $headerParams -Body $bodyJson
            }
            catch [Exception]
            {
                if ($PSItem.Exception.Response.StatusCode -eq 'Unauthorized')
                {
                    $KeyCloakAddress = $PSItem.Exception.Response.Headers.GetValues("WWW-Authenticate")

                    # Remove the "Bearer realm =" bit from the address
                    $KeyCloakAddress = $KeyCloakAddress.Substring(13)

                    # Remove the '"' character from the beginning and end of the address
                    $KeyCloakAddress = $KeyCloakAddress.Trim('"')

                }
                else
                {
                    throw
                }
            }

            # Now that we have the KeyCloak address, we can get the access token
            $accessToken = ObtainAccessToken -KeyCloakAddress $KeyCloakAddress

            # Build the registration token request
            $headerParams.Add('Authorization', "Bearer $accessToken")

            # Send the registration token request and get back a response from the Registration Service
            $registrationTokenResponse = Invoke-WebRequest -Uri $RegistrationServiceAddress -Method POST -Headers $headerParams -Body $bodyJson
            if (!($registrationTokenResponse.Content.Contains('token')))
            {
                throw "The response from the Registration server <$RegistrationServiceAddress> does not contain a registration token"
            }

            # Extract the registration token and registration endpoint URI from the response
            $registrationTokenResponseBody = ConvertFrom-Json($registrationTokenResponse.Content)
            $registrationToken = $registrationTokenResponseBody.token
            $registrationEndpoint = $registrationTokenResponseBody.registrationUri
            Write-Host $registrationToken

            # Now that we've successfully obtained a registration token and endpoint, we should save the values the user entered in order to allow for reconnection later
            $saveDictionary = @{}
            $saveDictionary.Add("RegistrationServiceAddress", $OriginalRegistrationServiceAddress)
            $saveDictionary.Add("ClientID", $ClientID)
            $saveDictionary.Add("ClientSecret", $ClientSecret)
            Export-Clixml -InputObject $saveDictionary -Path "$PSScriptRoot\ORTVariables.xml"

            return 0
        }
        catch [Exception]
        {
            Write-Host "An error was encountered: $($PSItem.ToString())" -ForegroundColor Red
            $FailedOnPreviousPass = $true
        }
    }
}

# Do not run this script if it was dot sourced.
# This allows the caller to access these functions without executing the script.
if ($MyInvocation.InvocationName -ne '.')
{
  $ErrorActionPreference = 'Stop'
  
  exit ObtainRegistrationToken @PSBoundParameters
}

# SIG # Begin signature block
# MIIayQYJKoZIhvcNAQcCoIIaujCCGrYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCGrsjnjEL59o2O
# GDZHFjcTPqOmHGGJCCN22lEcdN1V9aCCFf4wggPuMIIDV6ADAgECAhB+k+v7fMZO
# WepLmnfUBvw7MA0GCSqGSIb3DQEBBQUAMIGLMQswCQYDVQQGEwJaQTEVMBMGA1UE
# CBMMV2VzdGVybiBDYXBlMRQwEgYDVQQHEwtEdXJiYW52aWxsZTEPMA0GA1UEChMG
# VGhhd3RlMR0wGwYDVQQLExRUaGF3dGUgQ2VydGlmaWNhdGlvbjEfMB0GA1UEAxMW
# VGhhd3RlIFRpbWVzdGFtcGluZyBDQTAeFw0xMjEyMjEwMDAwMDBaFw0yMDEyMzAy
# MzU5NTlaMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsayzSVRLlxwS
# CtgleZEiVypv3LgmxENza8K/LlBa+xTCdo5DASVDtKHiRfTot3vDdMwi17SUAAL3
# Te2/tLdEJGvNX0U70UTOQxJzF4KLabQry5kerHIbJk1xH7Ex3ftRYQJTpqr1SSwF
# eEWlL4nO55nn/oziVz89xpLcSvh7M+R5CvvwdYhBnP/FA1GZqtdsn5Nph2Upg4XC
# YBTEyMk7FNrAgfAfDXTekiKryvf7dHwn5vdKG3+nw54trorqpuaqJxZ9YfeYcRG8
# 4lChS+Vd+uUOpyyfqmUg09iW6Mh8pU5IRP8Z4kQHkgvXaISAXWp4ZEXNYEZ+VMET
# fMV58cnBcQIDAQABo4H6MIH3MB0GA1UdDgQWBBRfmvVuXMzMdJrU3X3vP9vsTIAu
# 3TAyBggrBgEFBQcBAQQmMCQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3NwLnRoYXd0
# ZS5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADA/BgNVHR8EODA2MDSgMqAwhi5odHRw
# Oi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlVGltZXN0YW1waW5nQ0EuY3JsMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIBBjAoBgNVHREEITAfpB0wGzEZ
# MBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMTANBgkqhkiG9w0BAQUFAAOBgQADCZuP
# ee9/WTCq72i1+uMJHbtPggZdN1+mUp8WjeockglEbvVt61h8MOj5aY0jcwsSb0ep
# rjkR+Cqxm7Aaw47rWZYArc4MTbLQMaYIXCp6/OJ6HVdMqGUY6XlAYiWWbsfHN2qD
# IQiOQerd2Vc/HXdJhyoWBl6mOGoiEqNRGYN+tjCCBCAwggMIoAMCAQICEDRO1Vcg
# 1e3sSfQvzjfbK20wDQYJKoZIhvcNAQEFBQAwgakxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwx0aGF3dGUsIEluYy4xKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2Vydmlj
# ZXMgRGl2aXNpb24xODA2BgNVBAsTLyhjKSAyMDA2IHRoYXd0ZSwgSW5jLiAtIEZv
# ciBhdXRob3JpemVkIHVzZSBvbmx5MR8wHQYDVQQDExZ0aGF3dGUgUHJpbWFyeSBS
# b290IENBMB4XDTA2MTExNzAwMDAwMFoXDTM2MDcxNjIzNTk1OVowgakxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwx0aGF3dGUsIEluYy4xKDAmBgNVBAsTH0NlcnRpZmlj
# YXRpb24gU2VydmljZXMgRGl2aXNpb24xODA2BgNVBAsTLyhjKSAyMDA2IHRoYXd0
# ZSwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MR8wHQYDVQQDExZ0aGF3
# dGUgUHJpbWFyeSBSb290IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEArKDw+4BZ1JzHpM+doVlzCRBFDA0sbmjxbFtIaElZN/wLMxnCd3/MEC2VNBzm
# 600JpxzSuMmXNgK3idQkXwbAzESUlI0CYm/rWt0RjSiaXISQEHoNvXRmL2o4oOLV
# VETrHQefB7pv7un9Tgsp9T6EoAHxnKv4HH6JpOih2HFlDaNRe+680iJgDblbnd+6
# /FFbC6+Ysuku6QToYofeK8jXTsFMZB7dz4dYukpPymgHHRydSsbVL5HMfHFyHMXA
# Z+sy/cmSXJTahcCbv1N9Kwn0jJ2RH5dqUsveCTakd9h7h1BE1T5uKWn7OUkmHgml
# gHtALevoJ4XJ/mH9fuZ8lx3VnQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4G
# A1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUe1tFz6/Oy3r9MZIaarbzRutXSFAwDQYJ
# KoZIhvcNAQEFBQADggEBAHkRwEuzkbb88Oln1A1uRb5V6JPSzgM/7dolsB1Xyx46
# dqBM7FB26GRyDKSp8biL1taHhLsy5UERwHfZs2Cd6xvV0W5ERKmmAexVYh13uFyO
# SEl8nDtXEaytczeOL3hckGhH2WBg5vwHPSIgF8T3FunE2HL5yHN83xYvFak+/Won
# tqHrWrqYH9XjTWQKnRPIYbr1ORyHuri9eyJ/9v6sQHnlrBBvPY8beXaLxDezIRiE
# 5TYA62Mgmbnp/jMEu0HIwQL5RGMgnoHOQtPWPyx202OcWd2PpuEOoC5B9y6VR8+8
# /TPz9gthfn6RK4FHwicw7qcQXTePXDkr5ATwe41WjGgwggSZMIIDgaADAgECAhBx
# oLc2ld2xr8I7K5oY7lTLMA0GCSqGSIb3DQEBCwUAMIGpMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMdGhhd3RlLCBJbmMuMSgwJgYDVQQLEx9DZXJ0aWZpY2F0aW9uIFNl
# cnZpY2VzIERpdmlzaW9uMTgwNgYDVQQLEy8oYykgMjAwNiB0aGF3dGUsIEluYy4g
# LSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTEfMB0GA1UEAxMWdGhhd3RlIFByaW1h
# cnkgUm9vdCBDQTAeFw0xMzEyMTAwMDAwMDBaFw0yMzEyMDkyMzU5NTlaMEwxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwx0aGF3dGUsIEluYy4xJjAkBgNVBAMTHXRoYXd0
# ZSBTSEEyNTYgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAm1UCTBcF6dBmw/wordPA/u/g6X7UHvaqG5FG/fUW7ZgHU/q6hxt9
# nh8BJ6u50mfKtxAlU/TjvpuQuO0jXELvZCVY5YgiGr71x671voqxERGTGiKpdGnB
# dLZoh6eDMPlk8bHjOD701sH8Ev5zVxc1V4rdUI0D+GbNynaDE8jXDnEd5GPJuhf4
# 0bnkiNIsKMghIA1BtwviL8KA5oh7U2zDRGOBf2hHjCsqz1v0jElhummF/WsAeAUm
# aRMwgDhO8VpVycVQ1qo4iUdDXP5Nc6VJxZNp/neWmq/zjA5XujPZDsZC0wN3xLs5
# rZH58/eWXDpkpu0nV8HoQPNT8r4pNP5f+QIDAQABo4IBFzCCARMwLwYIKwYBBQUH
# AQEEIzAhMB8GCCsGAQUFBzABhhNodHRwOi8vdDIuc3ltY2IuY29tMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwMgYDVR0fBCswKTAnoCWgI4YhaHR0cDovL3QxLnN5bWNiLmNv
# bS9UaGF3dGVQQ0EuY3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDAzAO
# BgNVHQ8BAf8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVN5bWFudGVj
# UEtJLTEtNTY4MB0GA1UdDgQWBBRXhptUuL6mKYrk9sLiExiJhc3ctzAfBgNVHSME
# GDAWgBR7W0XPr87Lev0xkhpqtvNG61dIUDANBgkqhkiG9w0BAQsFAAOCAQEAJDv1
# 16A2E8dD/vAJh2jRmDFuEuQ/Hh+We2tMHoeei8Vso7EMe1CS1YGcsY8sKbfu+ZEF
# uY5B8Sz20FktmOC56oABR0CVuD2dA715uzW2rZxMJ/ZnRRDJxbyHTlV70oe73dww
# 78bUbMyZNW0c4GDTzWiPKVlLiZYIRsmO/HVPxdwJzE4ni0TNB7ysBOC1M6WHn/Td
# cwyR6hKBb+N18B61k2xEF9U+l8m9ByxWdx+F3Ubov94sgZSj9+W3p8E3n3XKVXdN
# XjYpyoXYRUFyV3XAeVv6NBAGbWQgQrc6yB8dRmQCX8ZHvvDEOihU2vYeT5qiGUOk
# b0n4/F5CICiEi0cgbjCCBKAwggOIoAMCAQICEDL1MKx0EQ0zg5H4OCVfnAUwDQYJ
# KoZIhvcNAQELBQAwTDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDHRoYXd0ZSwgSW5j
# LjEmMCQGA1UEAxMddGhhd3RlIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EwHhcNMTYw
# NzExMDAwMDAwWhcNMTgwNzExMjM1OTU5WjBeMQswCQYDVQQGEwJVUzEWMBQGA1UE
# CAwNTWFzc2FjaHVzZXR0czEPMA0GA1UEBwwGQm9zdG9uMRIwEAYDVQQKDAlDYXJi
# b25pdGUxEjAQBgNVBAMMCUNhcmJvbml0ZTCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAL48fN6d3wYMuslUF9xDe5zqIvBulGIyve62BLV1pcF2LbbwGTym
# IDKXRsp0EN8kTXeiWp6EHSXt9SEii+wdVr40yjv3ZUn78d/eTsrUkox0+Ggt6jkO
# ClaqV1fdI7XKA621kU8XBAIPNqCufmGmJAm9mXzw3MOfYiKlV1CxdQj2qW83N5fw
# qx9dSmXJjm8sXctU8FRuaDQ6ohJtYOrrQULvRLCObQ78s0B+t+AuyFnxZoc87Hpe
# PZtKi5XmFRWqFisoFfToXElJsWBdyqiWoflMg4yG8E3vyV+zT51QzgdrcMecLMu5
# Ucq+QFoZ3EPwcu/lVtMtOXojm7IlTaEl3fMCAwEAAaOCAWowggFmMAkGA1UdEwQC
# MAAwHwYDVR0jBBgwFoAUV4abVLi+pimK5PbC4hMYiYXN3LcwHQYDVR0OBBYEFCi4
# c2r1BdIQ8bY5EZ8je//ZUfvbMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly90bC5z
# eW1jYi5jb20vdGwuY3JsMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBuBgNVHSAEZzBlMGMGBmeBDAEEATBZMCYGCCsGAQUFBwIBFhpodHRwczov
# L3d3dy50aGF3dGUuY29tL2NwczAvBggrBgEFBQcCAjAjDCFodHRwczovL3d3dy50
# aGF3dGUuY29tL3JlcG9zaXRvcnkwVwYIKwYBBQUHAQEESzBJMB8GCCsGAQUFBzAB
# hhNodHRwOi8vdGwuc3ltY2QuY29tMCYGCCsGAQUFBzAChhpodHRwOi8vdGwuc3lt
# Y2IuY29tL3RsLmNydDANBgkqhkiG9w0BAQsFAAOCAQEAVTyXFYCKv+mxeGpJL5B5
# y/ljQYOsnUHeLC7b8GSjsg97O/At2wLyV69JbCuLsoOJvi9VwslP4Ykyb2oUUsA4
# b3FfNngnIlk/KIaOl5zErcO97IIUj94/LQUX2OwLSqUgIT8wwyHLd6uXiU1vITc9
# Oh8Hbg9HKmhLNWBRfFLq2U3pWneBmpQ7/7g7gdApbls8Fm7f7I05/W9G39orq5j/
# AvRkIakgaIGGmwMfjycERwu5Dfp8TSuVnHiLdPLkOGkcwnPqtriUhIfgCicUkVJZ
# pJHRzE2nkC7//728NtEjtuYoXRajJ5+CSCoOV5NnYuNV8FuehGCCVr6k9zJOwnud
# /jCCBKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAwDQYJKoZIhvcNAQEFBQAw
# XjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAw
# LgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzIw
# HhcNMTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNVBAMTK1N5bWFudGVj
# IFRpbWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzQwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO/6HwYQpTk7CY260sD0rF
# bv+GPFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXuwitDwZ/YaLSOQE/uhTi5
# EcUj8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6ZWqidKFAOF+6W22E7RVEd
# zxJWC5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo0iKl0LoCeqF3k1tlw+4X
# dLxBhircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdljyEmdOsXF6jML0vGjG/SL
# vtmzV4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAocqrNAgMBAAGjggFXMIIB
# UzAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB
# /wQEAwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUHMAGGHmh0dHA6Ly90cy1v
# Y3NwLndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYraHR0cDovL3RzLWFpYS53
# cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNVHR8ENTAzMDGgL6Athito
# dHRwOi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIuY3JsMCgGA1Ud
# EQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0yMB0GA1UdDgQWBBRG
# xmmjDkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRfmvVuXMzMdJrU3X3vP9vs
# TIAu3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCPYjA3eKOEJwdvGLLeJdyg
# 1JQDqoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJZG0N5sNnDvcFpDVsfIkW
# xumy37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rxS8SIKZEOgNER/N1cdm5P
# Xg5FRkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivxf1sJPZtb4hbKE4FtAC44
# DagpjyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3wPbRRoXkzKy57udwgCRNx
# 62oZW8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S4MO8HNgEdTGCBCEwggQd
# AgEBMGAwTDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDHRoYXd0ZSwgSW5jLjEmMCQG
# A1UEAxMddGhhd3RlIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0ECEDL1MKx0EQ0zg5H4
# OCVfnAUwDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgVuZePkhzyKecrFbf8/2lgCjBU6aI
# 6YGt+Q0EhKC3RH8wDQYJKoZIhvcNAQEBBQAEggEAJ8gahEVPJB3zMx8rhFOv9v0w
# 7/+nvNO1nlqPZkYB4phqCrXAyII6xCU9Y+ps6nbUhM5/CWQcjp/U/IyCMqMgkt0h
# HtHJsfHYShhTe2zKQI1SCQHZwhlBq8Q/m1g+1A93C6d6nQVsMyW7Ltji6scNXqxS
# EyhOhPuq0eaSbVf2/hIXY8PkZrzEZWdDsIUrY4zdLquHYpcPOMRYN7ElWw39zGA4
# jlPP7AQVIdKBaDwFMX3Zic1qFMdSgrdoVKIQQC1J05G07RQBjdQn1ogmx0ecTLCK
# /YLCDpX8IUW3fVc1pE1yNXpL5bDafaefbe6Nzx1lrHGka9q+15MRQO4n5N9/uqGC
# AgswggIHBgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMg
# VGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQ
# MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
# DQEJBTEPFw0xODA1MDIxNTExMjRaMCMGCSqGSIb3DQEJBDEWBBQ3RKOgMXfT+J9b
# XAIe0okp7M44pTANBgkqhkiG9w0BAQEFAASCAQAMyEzjKvjDCvGLQ8GkaRyR35kC
# H6sSvtxQvcpkD+FOhBqXSEu7L/ZCPY3IkSplviJ0AjEvVU6eicdR62TjRmeVUU2a
# ZG5zKXJXizGbX0CWuWD5cCI2Erj+bPMnEZSxpIN8Tm0rJExTmykRQfD8Sc8b7s3A
# fLQY1HJWE9JMehGaDEMQM5rCqtehH/8pyA0NQJfLnMC6/PA7js/iN1OXcEVGoVe0
# yh3LIYbI9fYtq0cCGqblmgM+ejoT5qpQtyFGeZ2j/xK0honzV4ZZ75DPu7YUJ/Fr
# ffTVOz/RpiZn2Y6obLGFCxyUikNT0E/0yvsuSvnWk9M0vrqrLQ5iexcQUk7L
# SIG # End signature block
