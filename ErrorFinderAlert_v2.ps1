# ErrorFinderAlert_v2.ps1

# Will Green
# 05/28/2019

# Updates:
# 06/10/2019 - Added SQL trigger
# 06/10/2019 - Switched to HTML format emails

# Check for livecycle related errors, if found, check if old or new, if old, ignore, if new, alert admins via email.

# This script runs as a scheduled task on a single server (due to on site restrictions of the service account used)
# A more modular and expandable version will be written as time allows.

#################
##### PROD  #####
##### WAS03 #####
#################

# Initial variables
$checkscriptlog = "D:\Scripts\ErrorFinderAlert\Logs\ErrorFinderAlertLog.txt"
$checkscripterrordb = "D:\Scripts\ErrorFinderAlert\Databases\ErrorFinderAlertDb.txt"
$lclogdirforms01 = "D:\was\wasp\85\profiles\lcforms\logs\lcforms01"
$lclogdirds01 = "D:\was\wasp\85\profiles\lcds\logs\lcds01"

# Gather database content
$reviewdberrors = Get-Content -Path $checkscripterrordb

# Email variables
$emailneedssent = ""
$emailfrom = "Admin <person@email.com>"
$emailsubject = "ALERT: LiveCycle Log File Errors Found!"
$emailbody = "Hello,<br><br>There were Errors Detected!<br><br>Please investigate. The alert for THESE errors will only occur ONCE!<br><br>Errors detected:<br>"
$emailserver = "emailserver"
$emailport = "25"

# Log when script executes via scheduled task
Write-Output "-" >> $checkscriptlog
Write-Output "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): SCRIPT EXECUTED" >> $checkscriptlog

##### WAS03 / LCFORMS01 #####

# Get latest log file
$lclastlogfile1 = Get-ChildItem -Path $lclogdirforms01 -File "TextLog_*" | Sort-Object LastAccessTime -Descending | Select-Object -First 1
$lclastlogfilefullpath1 = $lclogdirforms01 + "\" + $lclastlogfile1

$threaderrorlist1 = Get-Content -Path $lclastlogfilefullpath1 | Select-String -Pattern "milliseconds and may be hung"
$threaderrorlist1a = Get-Content -Path $lclastlogfilefullpath1 | Select-String -Pattern "The driver could not establish a secure connection to SQL Server by using Secure Sockets Layer \(SSL\) encryption"

if ($threaderrorlist1 -ne $null -OR $threaderrorlist1a -ne $null)
{
    
    $emailbody += "<br>LCFORMS01 @ SERVER<br><br>"

}

# ERROR: milliseconds and may be hung
foreach ($threaderror1 in $threaderrorlist1)
{

    if ((Get-Content $checkscripterrordb | %{ $res = $false } { $res = $res -or $_.Contains($threaderror1) } {return $res }) -eq $true)
        {

            # File already reported on... Do nothing.
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCFORMS01: Thread Error > Old Error!"

        } else {

            # File(s) were not reported on and alert needs to be sent
            $emailneedssent += "x"
            $emailbody += "<font face='courier'>- $threaderror1</font><br><br>"
            Add-Content $checkscripterrordb "$threaderror1"
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCFORMS01: Email Alert Sent > $threaderror1"

        }

}

# ERROR: The driver could not establish a secure connection to SQL Server by using Secure Sockets Layer (SSL) encryption
foreach ($threaderror1a in $threaderrorlist1a)
{

    if ((Get-Content $checkscripterrordb | %{ $res = $false } { $res = $res -or $_.Contains($threaderror1a) } {return $res }) -eq $true)
        {

            # File already reported on... Do nothing.
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCFORMS01: SQL Error > Old Error!"

        } else {

            # File(s) were not reported on and alert needs to be sent
            $emailneedssent += "x"
            $emailbody += "<font face='courier'>- $threaderror1a</font><br><br>"
            Add-Content $checkscripterrordb "$threaderror1a"
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCFORMS01: Email Alert Sent > $threaderror1a"

        }

}

##### WAS03 / LCDS01 #####

# Get latest log file
$lclastlogfile2 = Get-ChildItem -Path $lclogdirds01 -File "TextLog_*" | Sort-Object LastAccessTime -Descending | Select-Object -First 1
$lclastlogfilefullpath2 = $lclogdirds01 + "\" + $lclastlogfile2

$threaderrorlist2 = Get-Content -Path $lclastlogfilefullpath2 | Select-String -Pattern "milliseconds and may be hung"
$threaderrorlist2a = Get-Content -Path $lclastlogfilefullpath2 | Select-String -Pattern "The driver could not establish a secure connection to SQL Server by using Secure Sockets Layer \(SSL\) encryption"

if ($threaderrorlist2 -ne $null -OR $threaderrorlist2a -ne $null)
{
    
    $emailbody += "<br>LCDS01 @ SERVER<br><br>"

}

# ERROR: milliseconds and may be hung
foreach ($threaderror2 in $threaderrorlist2)
{

    if ((Get-Content $checkscripterrordb | %{ $res = $false } { $res = $res -or $_.Contains($threaderror2) } {return $res }) -eq $true)
        {

            # File already reported on... Do nothing.
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCDS01: Thread Error > Old Error!"

        } else {

            # File(s) were not reported on and alert needs to be sent
            $emailneedssent += "x"
            $emailbody += "<font face='courier'>- $threaderror2</font><br><br>"
            Add-Content $checkscripterrordb "$threaderror2"
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCDS01: Email Alert Sent > $threaderror2"

        }

}

# ERROR: The driver could not establish a secure connection to SQL Server by using Secure Sockets Layer (SSL) encryption
foreach ($threaderror2a in $threaderrorlist2a)
{

    if ((Get-Content $checkscripterrordb | %{ $res = $false } { $res = $res -or $_.Contains($threaderror2a) } {return $res }) -eq $true)
        {

            # File already reported on... Do nothing.
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCDS01: SQL Error > Old Error!"

        } else {

            # File(s) were not reported on and alert needs to be sent
            $emailneedssent += "x"
            $emailbody += "<font face='courier'>- $threaderror2a</font><br><br>"
            Add-Content $checkscripterrordb "$threaderror2a"
            Add-Content $checkscriptlog "$(Get-Date -Format "yyyy MMM dd HH:mm:ss"): WAS03 LCDS01: Email Alert Sent > $threaderror2a"

        }

}

# Process email alert

# Sign email
$emailbody += "V/r<br>Will Green"

# Send the email alert
if ($emailneedssent -ne "")
{
        
    Send-MailMessage -From $emailfrom -Bcc "Admin <admin@emailserver>", "Person1 <person1@emailserver>" -Subject $emailsubject -Body $emailbody -SmtpServer $emailserver -Port $emailport -BodyAsHtml -Priority High  

}