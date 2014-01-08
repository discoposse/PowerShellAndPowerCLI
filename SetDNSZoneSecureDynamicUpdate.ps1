# This script sets all of the reverse lookup zones to Secure Dynamic Update
# It is assumed that this is running from the server console

# Collect all DNS zones from the server 
$Zones = Get-DnsServerZone | Select-Object *

ForEach ($Zone in $Zones) {
	$ReverseZone = $Zone.IsReverseLookupZone
	$ZoneName = $Zone.ZoneName

	# If the zone is a reverse zone, change to Secure Dynamic Update
	If ($ReverseZone -eq "True") {
		Set-DnsServerPrimaryZone -Name $ZoneName -DynamicUpdate Secure
	}
}