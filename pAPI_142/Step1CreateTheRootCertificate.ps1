#The following script is based on the info from https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
#Replace the DnsName "rs-2k16.corp.ssv.com" with the FQDN of the server you want to create the certificate for
#Replace the DnsName "My Root CA" with whichever name you wish to use as the Root CA
#The password for the certificate is 3Vlt1nc.  This can be changed to whatever password you like
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
$rootCA = New-SelfSignedCertificate @params