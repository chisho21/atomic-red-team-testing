# Atomic Red Team Testing

## Synopsis
Atomic Red Team by Red Canary Co. allows every security team to test their controls by executing simple "atomic tests" that exercise the same techniques used by adversaries (all mapped to Mitre's ATT&CK).

## Testing Process
All of the following steps can be run at once via the PowerShell scripts in this folder, but are provided below with more verbose explainations.

### Step 1 - Open Powershell ISE as Admin on Victim Box
Our attacks will run locally on the victim machine as Administrator. We are assuming the machine is compromised and the attacker has gained root access.

### Step 2 - Install Powershell Modules and Atomic Red Team
The script below reaches out to the most recent version of the Atomic Red Team repository and installs necessary dependencies to run attacks.
```
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics -Force
Install-module powershell-yaml
```

### Step 3 - Select MITRE Techniques to Be Run
The below code will select our top 11 techniques.
```
$includelist = "T1566.001","T1053.005","T1547.001","T1548.002","T1140","T1110.001","T1087.002","T1135","T1550.002","T1071.001","T1048.003"
$windex = Import-Csv -Path "C:\AtomicRedTeam\atomics\Indexes\Indexes-CSV\windows-index.csv" | sort-object 'Technique #'
$MitreNums = ($windex | select 'Technique #' -Unique).'Technique #' | Sort-Object | Where-Object {$includelist -contains $_ }
```
The below code will select ALL tests that do not reboot the victim machine.
```
$excludelist = "T1003","T1529","T1546.002" #exclude attacks that are known to reboot the box.
$windex = Import-Csv -Path "C:\AtomicRedTeam\atomics\Indexes\Indexes-CSV\windows-index.csv" | sort-object 'Technique #'
$MitreNums = ($windex | select 'Technique #' -Unique).'Technique #' | Sort-Object | Where-Object {$excludelist -notcontains $_}
```

The below code will allow you to select whichever tests you want from the repository via an Out-Gridview.
```
$windex = Import-Csv -Path "C:\AtomicRedTeam\atomics\Indexes\Indexes-CSV\windows-index.csv" | sort-object 'Technique #'
$MitreNums = ($windex | select-object 'Technique #','tactic','Technique Name' -Unique | Out-GridView -PassThru -Title "Select all desired Atomic Tests" ).'Technique #' | Sort-Object
```

### Step 4 - Iterate Through Each Selected Test
Once you have defined all the $MitreNums you wish to test, run the following to iterate through and perform the following steps:
1. Start a PowerShell transcript to aid in post testing review.
2. Display attack information to screen. There may be mutliple attacks run per MITRE Number
3. Identify and download any prerequisites as defined by the Atomic Test.
4. Execute attacks as defined by the Atomic Test.
5. Perform any cleanup activities as defined by the Atomic Test.
6. Stop The logging transcript

```
$count = 0
$total = $MitreNums.count
foreach ($mitre in $MitreNums){
	$count++
	$mitre
	$technique = $mitre
	
	## Step 1: Start a transcript log to see what was run and when
	Write-Host "============================ $mitre - Starting Transcript ($count of $total) Step 1/5 ========================================"
	$datestamp = Get-date -Format yyyyMMdd_hh.mm.ss
	Start-Transcript -Path "C:\AtomicRedTeam\$technique.$datestamp.log"
	
	## Step 2: Display Attack details to screen
	Write-host ""
	Write-Host "============================ $mitre - Show Attack Details  ($count of $total) Step 2/5 ========================================"
	Write-host ""
	Invoke-AtomicTest -AtomicTechnique $technique -ShowDetails
	
	## Step 3: Download any prerequisites for attack to run.
	Write-host ""
	Write-Host "============================ $mitre - Gathering PreReqs  ($count of $total) Step 3/5 ========================================"
	Write-host ""
	Invoke-AtomicTest -AtomicTechnique $technique -GetPrereqs
	
	## Step 4: Execute attacks as defined by Details
	Write-host ""
	Write-Host "============================ $mitre - Executing attacks ($count of $total) Step 4/5 ========================================"
	Write-host ""
	Invoke-AtomicTest -AtomicTechnique $technique
	
	## Step 5: Perform any clean up as defined by Details.
	Write-host ""
	Write-Host "============================ $mitre - Cleaning up ($count of $total) Step 5/5 ========================================"
	Write-host ""
	Invoke-AtomicTest -AtomicTechnique $technique -Cleanup

	## Stop the transcript for this technique number.
	Stop-Transcript
	
}
```

### Step 5 - (Optional) Examine "C:\AtomicRedTeam\" for log files of what was run and what failed to run.

### Step 6 - (Optional) Compare MITRE numbers tested to MITRE numbers that alerted in security product.

## Helpful Links
Atomic Red Team Repository - https://github.com/redcanaryco/atomic-red-team
Atomic Red Team Main Site - https://atomicredteam.io/
Youtube playlist for deep dives on Atomic Red Team usage - https://www.youtube.com/playlist?list=PL92eUXSF717XLqkiCitdSZSUijwdDsM20
MITRE ATT&CK Framework webiste - https://attack.mitre.org/




