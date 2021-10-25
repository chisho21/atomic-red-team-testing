# Instructions
	<#
		1. Open 'Powershell ISE' as Administrator on testing machine.
		2. Expand Script Pane.
		3. Copy ALL this text into script pane.
		4. Click the 'Play' button (green triangle) or press 'F5'
		5. (Optional) After all attacks run, examine "C:\AtomicRedTeam\" for log files of what was run.
		6. (Optional) Compare Mitre numbers tested to Mitre numbers that alerted in security product.
	
	#>

# Install Atomic Red Team Powershell Module, Yaml Powershell Module, and download all Atomic YAML instructions.
    IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
    Install-AtomicRedTeam -getAtomics -Force
    Install-module powershell-yaml

#import atomic windows indexes and select only the following tests.
    <#
    T1566.001 (Initial Access > Phishing) (Requires office)
    T1053.005 (Execution > scheduled task)
    T1547.001 (Persistence > Registry Keys added)
    T1548.002 (Priv. Escalation > Abuse elevation control)
    T1140 (Defense Evasion > Deobfuscate Files)
    T1110.001 (Credential Access > Brute Force)
    T1087.002 (Discovery > Account Discovery) (Domain Only)
    T1135 (Discovery > File Share Discovery)
    T1550.002 (Lateral Movement > Use Alternate Authentication Material)
    T1071.001 (Command & Control > Application Layer Protocol)
    T1048.003 (Exfiltration > Exfiltration Over Alternate Protocol)
    #>
    $includelist = "T1566.001","T1053.005","T1547.001","T1548.002","T1140","T1110.001","T1087.002","T1135","T1550.002","T1071.001","T1048.003"
    $windex = Import-Csv -Path "C:\AtomicRedTeam\atomics\Indexes\Indexes-CSV\windows-index.csv" | sort-object 'Technique #'

    $MitreNums = ($windex | select 'Technique #' -Unique).'Technique #' | Sort-Object | Where-Object {$includelist -contains $_}

# Run All Atomic Red Team tests selected above
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
        
		## Step 4: Execute attacks as defined by Details.
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