##############################
# Logon Script for Windows 7 #
##############################

# Get Current Time
$Time2 = Get-Date

# What time is it did the logon action start
$Time1 = Get-EventLog -LogName System -InstanceId 7001 -Newest 1

# Get the username
$Username = Get-Content env:username

# Get the domain
$Domain = Get-Content env:userdomain

# Set the time of the current logon
$LogonDateTime = Get-Date -Format "MMM dd yyyy HH:mm:ss"

# Workstation Name
$WorkstationName = Get-Content env:ComputerName

# Who is logging in
$LoggedOnUser = $Domain + "\" + $Username

# How long did the logon process take
$TimeToLogon = $time2.TimeOfDay.TotalSeconds - $Time1.TimeGenerated.TimeOfDay.TotalSeconds 

# Get the network information
$NetInfo = Get-WMIObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DNSDomain -eq "market.financial.local"}
$IPAddress = $NetInfo.IPAddress

# Drive Mappings
$DriveMappings = Get-WMIObject Win32_MappedLogicalDisk
 
# Connect to SQL
$dbconn = New-Object System.Data.SqlClient.SqlConnection("Data Source=YOURSQLSERVER; Initial Catalog=LOGINRESULTS; Integrated Security=SSPI")
$dbconn.Open()

# Write the Logon info to the table
$dbwriteWSinfo = $dbconn.CreateCommand()
$dbwriteWSinfo.CommandText = "INSERT INTO dbo.tbLogons (LogonDateTime,WorkstationName,LoggedOnUser,TimeToLogon,IPAddress) VALUES ('$LogonDateTime','$WorkstationName','$LoggedOnUser','$TimeToLogon','$IPAddress')"
$dbwriteWSinfo.ExecuteNonQuery()

# Write the drive mapping info to the table
ForEach ($DriveMapping in $DriveMappings) {
	$DriveLetter = $DriveMapping.Caption
	$DrivePath = $DriveMapping.ProviderName

	$dbwriteDrives = $dbconn.CreateCommand()
	$dbwriteDrives.CommandText = "INSERT INTO dbo.tblDriveMappings (DriveLetter,DrivePath,Username,Workstation,LogonDateTime) VALUES ('$DriveLetter','$DrivePath','$LoggedOnUser','$WorkstationName','$LogonDateTime')"
	$dbwriteDrives.ExecuteNonQuery()
}

# Close the DB connection
$dbconn.Close()