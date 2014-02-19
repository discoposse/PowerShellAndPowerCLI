#
# DISCLAIMER: This script does not contain any -WhatIf options. This WILL update all servers which are found in the query below. 
# Please test using a limited query to capture a single server or small subset of servers first to confirm the behaviour
#
# NOTE: I've taken the lazy path here too and I don't do any error handling. Computers in Active Directory that are not
# online when the script is run will throw and RPC error, but it won't stop the script
#
# No logging is in place in this version 
#

# Import the Active Directory module to query for computer objects
Import-Module ActiveDirectory

# Pull all servers and you can exclude by names to stop some from being modified like domain controllers. 
# Modify the query to meet your needs.
#
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*Server*" -and name -notlike "YOURDCNAME*"} 

ForEach ($Server in $Servers) {

	$ServerName=$Server.name
	Write-Host $ServerName

	# Get the list of IP Enabled NICs
	# This assumes you will statically set all DNS/WINS for any IP enabled NIC
	$NICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ServerName -Filter "IPEnabled=TRUE"
	
	# Get the site name using nltest. Trust me, this was the easiest way :)
	$SiteRetrieval = nltest /server:$ServerName /dsgetsite
	
	# When the site name is retrieved, it also has 'The command completed successfully' so we remove that to make it easier to parse the site name
	$SiteResult = $SiteRetrieval -replace "The command completed successfully",""

	# Set the IP information depending on what site the server is it
	# 
	# ***Replace the site names and IP addresses*** 
	# 
	Switch ($SiteResult)	
	{
		SiteName1 {
			Write-Host $ServerName is in $SiteResult
			ForEach ($NIC in $NICs) {
				$DNSServers = "aa.bb.cc.dd","aa.bb.cc.dd"
				$NIC.SetDNSServerSearchOrder($DNSServers)
				$NIC.SetDynamicDNSRegistration("TRUE")
				$NIC.SetWINSServer("aa.bb.cc.dd","aa.bb.cc.dd")
			}
		}
		SiteName2 {
			Write-Host $ServerName is in $SiteResult
			ForEach ($NIC in $NICs) {
				$DNSServers = "aa.bb.cc.dd","aa.bb.cc.dd"
				$NIC.SetDNSServerSearchOrder($DNSServers)
				$NIC.SetDynamicDNSRegistration("TRUE")
				$NIC.SetWINSServer("aa.bb.cc.dd","aa.bb.cc.dd")
			}
		}
	} 
}

