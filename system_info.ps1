Clear-Host
# Run on remote or local servers
# $Servers = 'Server1.contoso.com', 'Server2.contoso.com'
$Servers = $env:COMPUTERNAME

foreach ($Server in $Servers)

{    
	if ($Server -notmatch $env:COMPUTERNAME)
{        
	# Get hardware and operating system information        
		 $computerSystem = Get-CimInstance CIM_ComputerSystem -ComputerName $Server        
	 	 $computerBIOS = Get-CimInstance CIM_BIOSElement -ComputerName $Server        
	  	 $computerOS = Get-CimInstance CIM_OperatingSystem -ComputerName $Server        
		 $computerCPU = Get-CimInstance CIM_Processor -ComputerName $Server        
             $computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'" -ComputerName $Server    
    }
    else    
    {
	
		# Get hardware and operating system information        
		$computerSystem = Get-CimInstance CIM_ComputerSystem        
		$computerBIOS = Get-CimInstance CIM_BIOSElement        
		$computerOS = Get-CimInstance CIM_OperatingSystem        	
		$computerCPU = Get-CimInstance CIM_Processor        
		$computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'"   
 }

	Write-Host "System Information for: $($computerSystem.Name)" -BackgroundColor DarkCyan

	@"
	
	Manufacturer    : $($computerSystem.Manufacturer)    
	Model           : $($computerSystem.Model)    
	Serial Number   : $($computerBIOS.SerialNumber)    
	CPU             : $($computerCPU.Name)    
	HDD Capacity    : $("{0:N2}" -f ($computerHDD.Size/1GB))GB    
	HDD Space       : $("{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size)) Free ($("{0:N2}" -f ($computerHDD.FreeSpace/1GB))GB)    
	RAM             : $([int]($computerSystem.TotalPhysicalMemory/1GB))GB    
	Operating System: $($computerOS.caption), Service Pack: $($computerOS.ServicePackMajorVersion)    
	User logged In  : $($computerSystem.UserName)    
	Last Reboot     : $($computerOS.LastBootUpTime)

"@

#Export the fields you want from above in the specified order
    [PSCustomObject]@{
        'Name'                  = $computerSystem.Name        
	  'Manufacturer'          = $computerSystem.Manufacturer        
	  'Model'                 = $computerSystem.Model        
	  'Serial Number'         = $computerBIOS.SerialNumber        
	  'CPU'                   = $computerCPU.Name        
	  'HDD Capacity'          = "$("{0:N2}" -f ($computerHDD.Size/1GB))GB"       
	  'HDD Space'             = "$("{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size)) Free ($("{0:N2}" -f ($computerHDD.FreeSpace/1GB))GB)"        
	  'RAM'                   = "$([int]($computerSystem.TotalPhysicalMemory/1GB))GB"        
	  'Operating System'      = "$($computerOS.caption), Service Pack: $($computerOS.ServicePackMajorVersion)"        
	  'User logged In'        = $computerSystem.UserName        
	  'Last Reboot'           = $computerOS.LastBootUpTime    
} | Select-Object Name, RAM, 'Last Reboot', 'Operating System', 'Model', 'Serial Number' | Export-Csv 'C:\Temp\system-info.csv' -NoTypeInformation -Append -Force
}