# Document the DHCP Scopes includer all scopes, options, and reservations
# Stores scope info in a master file and each server will export its reservations and options 

Import-Module DHCPServer

# Clear the $AllScopes Variable
$AllScopes = ""

$DHCPMasterFile = "DHCP-MasterFile.txt"

If (Test-Path $DHCPMasterFile) {Clear-Content $DHCPMasterFile}
Add-Content $DHCPMasterFile -Value "Server,ID,Description,Subnet,Start,End,Lease,State"

# Fill in your server names to be queried here. Be sure to leave the comma off of the last entry
$DHCPServerList = @(
	"SERVER1",
	"SERVER2",
	"SERVER3"
	)

ForEach ($DHCPServer in $DHCPServerList) {
	
	# Clear the existing files
	If (Test-Path $DHCPServer-File.txt) {Clear-Content $DHCPServer-File.txt}
	If (Test-Path $DHCPServer-Option.txt) {Clear-Content $DHCPServer-Option.txt}
	If (Test-Path $DHCPServer-Reservation.txt) {Clear-Content $DHCPServer-Reservation.txt}

	Add-Content $DHCPServer-File.txt -Value "Server,ID,Description,Subnet,Start,End,Lease,State"
	Add-Content $DHCPServer-Reservation.txt -Value "IPAddress,ScopeID,ClientID,Name,Description"

	# Get-DHCPServerSetting -Computer $DHCPServer
	$DHCPScopes = Get-DHCPServerv4Scope -Computer $DHCPServer | Select-Object * 
	
	ForEach ($DHCPScope in $DHCPScopes) {
		$ScopeID = $DHCPScope.ScopeID
		$ScopeSubnet = $DHCPScope.SubnetMask
		$ScopeStart = $DHCPScope.StartRange
		$ScopeEnd = $DHCPScope.EndRange
		$ScopeDescription = $DHCPScope.Description
		$ScopeState = $DHCPScope.State
		$ScopeLease = $DHCPScope.LeaseDuration
		
		# Write out the files documenting the scopes for each server and then collectively in the master file
		Add-Content $DHCPServer-File.txt -Value "$DHCPServer,$ScopeID,$ScopeDescription,$ScopeSubnet,$ScopeStart,$ScopeEnd,$ScopeLease,$ScopeState"
		Add-Content $DHCPMasterFile -Value "$DHCPServer,$ScopeID,$ScopeDescription,$ScopeSubnet,$ScopeStart,$ScopeEnd,$ScopeLease,$ScopeState"
		
		# Get the reservations for the scope 
		$Reservations = Get-DHCPServerv4Reservation -ComputerName $DHCPServer -ScopeID $ScopeID 
		ForEach ($Reservation in $Reservations) {
			$ReservationIP = $Reservation.IPAddress
			$ReservationScopeID = $Reservation.ScopeId
			$ReservationClientId = $Reservation.ClientId
			$ReservationName = $Reservation.Name
			$ReservationDescription = $Reservation.Description

			Add-Content $DHCPServer-Reservation.txt "$ReservationIP,$ReservationScopeId,$ReservationClientId,$ReservationName,$ReservationDescription"
		}
		
		# Get the DHCP Options
		$Options = Get-DHCPServerv4OptionValue -ComputerName $DHCPServer -ScopeID $ScopeID
		ForEach ($Option in $Options) {
			
		}
	} 
	#Add-Content $DHCPServer-File.txt -Value $DHCPScopes
}

