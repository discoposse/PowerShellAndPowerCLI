# This will trigger some VM deployments from a template followed by powering on, stopping, then destroying the VMs

# Set up our parameters

$Template = ""
$Datastore = ""
$VMHost = ""
$CounterTotal = ""

# Connect to vCenter
Connect-VIserver -Server $VMHost -User "YOURUSERNAME" -Password "YOURPASSWORD" -Force

for ($counter=1; $counter -le $CounterTotal; $counter++)
{
	# Deploy a VM from the template
	New-VM -Name TEST$counter -VMHost $VMHost -Datastore $Datastore -Location RJL -Template $Template -RunAsync -Confirm:$FALSE 
}

sleep -seconds 60

for ($counter=1; $counter -le $CounterTotal; $counter++)
{
	#Start our VMs
	Start-VM -VM TEST$counter -RunAsync -Confirm:$FALSE
}

sleep -seconds 60

for ($counter=1; $counter -le $CounterTotal; $counter++)
{
	# Stop all of our VMs
	Stop-VM -VM TEST$counter -Confirm:$FALSE -Kill -RunAsync
}

sleep -seconds 60

for ($counter=1; $counter -le $CounterTotal; $counter++)
{
	# Delete all of our VMs
	Remove-VM -VM TEST$counter -Confirm:$FALSE -RunAsync -DeletePermanently
}
