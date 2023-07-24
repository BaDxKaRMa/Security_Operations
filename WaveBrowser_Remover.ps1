# Script to remove Wave Browser, annoying PUP.

$ErrorActionPreference = 'SilentlyContinue'

$badprocs = get-process | Where-Object {$_.name -like 'Wave*Browser*'} | Select-Object -exp Id;

Write-Output '------------------------';
Write-Output 'Process(es) Terminated'
Write-Output '------------------------';
if ($badprocs)
{
  Foreach ($badproc in $badprocs)
  {
    Write-Output "Killing process: $badproc"
    stop-process -Id $badproc -force
  }
} else
{
  Write-Output 'No Processes Terminated.'
}

$stasks = schtasks /query /fo csv /v | convertfrom-csv | Where-Object {$_.TaskName -like 'Wavesor*'} | Select-Object -exp TaskName

Write-Output ''
Write-Output '----------------------------';
' Scheduled Task(s) Removed'
Write-Output '----------------------------';

if ($stasks)
{
  Foreach ($task in $stasks)
  {
    Write-Output "Removing Scheduled Task: $task"
    schtasks /delete /tn $task /F
  }
} else
{
  Write-Output "No Scheduled Tasks Found."
};

$badDirs = 'C:\Users\*\Wavesor Software',
'C:\Users\*\Downloads\Wave Browser*.exe',
'C:\Users\*\AppData\Local\WaveBrowser',
'C:\Windows\System32\Tasks\Wavesor Software_*',
'C:\WINDOWS\SYSTEM32\TASKS\WAVESORSWUPDATERTASKUSER*CORE',
'C:\WINDOWS\SYSTEM32\TASKS\WAVESORSWUPDATERTASKUSER*UA',
'C:\USERS\*\APPDATA\ROAMING\MICROSOFT\WINDOWS\START MENU\PROGRAMS\WAVEBROWSER.LNK',
'C:\USERS\*\APPDATA\ROAMING\MICROSOFT\INTERNET EXPLORER\QUICK LAUNCH\WAVEBROWSER.LNK',
'C:\USERS\*\APPDATA\ROAMING\MICROSOFT\INTERNET EXPLORER\QUICK LAUNCH\USER PINNED\TASKBAR\WAVEBROWSER.LNK'

Write-Output ''
Write-Output '-------------------------------';
Write-Output 'File System Artifacts Removed'
Write-Output '-------------------------------';

start-sleep -s 2;

ForEach ($badDir in $badDirs)
{
  $dsfolder = Get-Item -Path $badDir -ea 0 | Select-Object -exp fullname;
  if ( $dsfolder)
  {
    Write-Output "Removing Directory: $dsfolder"
    rm $dsfolder -recurse -force -ea 0
  } else
  {
  }
}

$checkhandle = Get-Item -Path 'C:\Users\*\AppData\Local\WaveBrowser' -ea 0 | Select-Object -exp fullname;

if ($checkhandle)
{
  Write-Output ""
  Write-Output "NOTE: C:\Users\*\AppData\Local\WaveBrowser' STILL EXISTS! A PROCESS HAS AN OPEN HANDLE TO IT!"
}

$badreg = 'Registry::HKU\*\Software\WaveBrowser',
'Registry::HKU\*\SOFTWARE\CLIENTS\STARTMENUINTERNET\WaveBrowser.*',
'Registry::HKU\*\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\APP PATHS\wavebrowser.exe',
'Registry::HKU\*\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\UNINSTALL\WaveBrowser',
'Registry::HKU\*\Software\Wavesor',
'Registry::HKLM\SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION\SCHEDULE\TASKCACHE\TREE\WavesorSWUpdaterTaskUser*UA',
'Registry::HKLM\SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION\SCHEDULE\TASKCACHE\TREE\WavesorSWUpdaterTaskUser*Core',
'Registry::HKLM\SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION\SCHEDULE\TASKCACHE\TREE\Wavesor Software_*'

Write-Output ''
Write-Output '---------------------------';
Write-Output 'Registry Artifacts Removed'
Write-Output '---------------------------';

Foreach ($reg in $badreg)
{
  $regoutput = Get-Item -path $reg | Select-Object -exp Name
  if ($regoutput)
  {
    Write-Output "Removing Registry Key: $regoutput"
    reg delete $regoutput /f
  } else
  {
  }
}

$badreg2 = 'Registry::HKU\*\Software\Microsoft\Windows\CurrentVersion\Run',
'Registry::HKU\*\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run'

Write-Output ''
Write-Output '----------------------------------';
Write-Output 'Registry Run Persistence Removed'
Write-Output '----------------------------------';

Foreach ($reg2 in $badreg2)
{
  $regoutput = Get-Item -path $reg2 -ea silentlycontinue | Where-Object {$_.Property -like 'Wavesor SWUpdater'} | Select-Object -exp Property ;
  $regpath = Get-Item -path $reg2 -ea silentlycontinue | Where-Object {$_.Property -like 'Wavesor SWUpdater'} | Select-Object -exp Name ;
  Foreach($prop in $regoutput)
  {
	   If ($prop -like 'Wavesor SWUpdater')
    {
      Write-Output "Removing Registry Key: $regpath Value: $prop"
      reg delete $regpath /v $prop /f
    } else
    {
    }
  }
}
