#The following script is based on the info from https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
#Replace the DnsName "SRVpAPI.yourdomain.com" with the FQDN of the server you want to create the certificate for
#Replace the DnsName "My Root CA" with whichever name you wish to use as the Root CA
#The password for the certificate is 3Vlt1nc.  This can be changed to whatever password you like
#Note: the machine using a login with administrative rights and enroll for the certificate again. From <https://knowledge.digicert.com/solution/SO5850.html>
#Step 1 - Create the root certificate
$params = @{
  DnsName = "My Root CA"
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(5)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  KeyUsage = 'CertSign','CRLSign','DigitalSignature' #fixes invalid cert error
  }
$rootCA = New-SelfSignedCertificate @params

#Step 2 - Create the server cert signed by the new root
$params = @{
  DnsName = "SRVpAPI.yourdomain.com"
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  }
$vpnCert = New-SelfSignedCertificate @params
#Specify the password for the server certificate
$pwd = ConvertTo-SecureString -String '3Vlt1nc' -Force -AsPlainText
#Create the directory and export the root certificate and server certificate as .pfx
New-Item -ItemType Directory -Path c:\sslcert -Force
Export-Certificate -Cert $rootCA -FilePath "C:\sslcert\rootCA.crt"
Export-PfxCertificate -Cert $vpnCert -FilePath 'C:\sslcert\cert.pfx' -Password $pwd