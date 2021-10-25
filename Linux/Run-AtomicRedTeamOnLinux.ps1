## STILL IN PROGRESS ##

## Install Redteam
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics -Force

##Select attacks
	$excludelist = "T1070.004" #exclude attacks that are known to reboot the box.
	$index = Import-Csv -Path ~/AtomicRedTeam/atomics/Indexes/Indexes-CSV/linux-index.csv | sort-object 'Technique #'
	$MitreNums = ($index | select 'Technique #' -Unique).'Technique #' | Sort-Object | Where-Object {$excludelist -notcontains $_}
	
	
# Run Atomic Red Team tests
    $count = 0
    $total = $MitreNums.count
    foreach ($mitre in $MitreNums){
        $count++
        $mitre
        $technique = $mitre
			Write-Host "============================ $mitre - Starting Transcript ($count of $total) Step 1/5 ========================================"
            $datestamp = Get-date -Format yyyyMMdd_hh.mm.ss
            Start-Transcript -Path "~\AtomicRedTeam\$technique.$datestamp.log"
        
            Write-host ""
            Write-Host "============================ $mitre - Show Attack Details  ($count of $total) Step 2/5 ========================================"
            Write-host ""
            Invoke-AtomicTest -AtomicTechnique $technique -ShowDetails
        
            Write-host ""
            Write-Host "============================ $mitre - Gathering PreReqs  ($count of $total) Step 3/5 ========================================"
            Write-host ""
            Invoke-AtomicTest -AtomicTechnique $technique -GetPrereqs
        
            Write-host ""
            Write-Host "============================ $mitre - Executing attacks ($count of $total) Step 4/5 ========================================"
            Write-host ""
            Invoke-AtomicTest -AtomicTechnique $technique
			
			Write-host ""
            Write-Host "============================ $mitre - Cleaning up ($count of $total) Step 5/5 ========================================"
            Write-host ""
            Invoke-AtomicTest -AtomicTechnique $technique -Cleanup
			
            Stop-Transcript
        
    }