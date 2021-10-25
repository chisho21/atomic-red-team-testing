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

#import atomic windows indexes and select all tests that are not known to reboot the machine.
    $excludelist = "T1003","T1529","T1546.002" #exclude attacks that are known to reboot the box.
    $windex = Import-Csv -Path "C:\AtomicRedTeam\atomics\Indexes\Indexes-CSV\windows-index.csv" | sort-object 'Technique #'
    $MitreNums = ($windex | select 'Technique #' -Unique).'Technique #' | Sort-Object | Where-Object {$excludelist -notcontains $_}

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