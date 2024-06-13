# ���������� PostgreSQL 9.6 �� ������ 12 (��� 1�)
#
# �� ����� SYSTEM!!!
#
# ������� �������>  Set-AuthenticodeSignature C:\UpdatePG-967-11C-local\updatePG-967-11C-local.ps1 @(Get-ChildItem Cert:\LocalMachine\My -codesigning)[0]
#
# ��������� ����� �������
# UpdatePG9
# |-installer
# | |-postgresql-14-int.msi - !!! ���� -int �� ��������� PostgreSQL ��� 1C � ������������ locale (ru_RU.UTF-8), ������� postgres � ����������� �������� StackBuilder
# |-append-as-9-6-postgresql.conf
# |-updatePG.ps1
#

# ������ Trassir � 1C
$srv1C = '1C:Enterprise 8.3 Server Agent (x86-64)'
$srvTrassir = 'trassir'
# PostgresQL 9.6
$dirPG9 = 'C:\Program Files\PostgreSQL\9.6.7-1.1C'
$srvPG9 = 'pgsql-9.6.7-1.1C-x64'
# PostgreSQL 14
$dirPG14 = 'C:\Program Files\PostgreSQL\14.11-3.1C'
$srvPG14 = 'pgsql-14.11-3.1C-x64'
# 
$Stamp = (Get-Date -Format "yyyy-MM-dd--HH-mm")
$StampName = (Get-Date -Format "yyyy-MM-dd--HH-mm")
# ��������� �����
$dirTemp = 'C:\tempPG' + '--' + $StampName
$fileDump = 'pg9.dmp'
# 
#$dirPswd = $Env:APPDATA + '\postgresql'
$dirPswd = $dirTemp + '\postgresql'
$filePswd = 'pgpass.conf'
$pathPswd = $dirPswd + '\' + $filePswd
# !!! ������� ������ postgres
$strPswd = 'localhost:5432:*:postgres:375183'
$utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding($False)
$strCmd = $null
# ��c�������� PostgreSQL 14 
#$dirInstaller = $MyInvocation.MyCommand.Path | split-path -parent
#$pathInstaller = $dirInstaller + '\installer\postgresql-14-int.msi'

$dirInstaller = ($MyInvocation.MyCommand.Path | split-path -parent)
$nameInstaller = 'postgresql-14-int.msi'
$pathInstaller = $dirInstaller + '\' + 'installer\' + $nameInstaller
$nameConf = 'append-as-9-6-postgresql.conf'
$pathConf = $dirInstaller + '\' + $nameConf

# !!! ������� ���� � �������������� 1�
#$pathRecomend = $dirInstaller + '\append-1�-recomendation-postgresql.conf'
#
# !!! ������� ���� � ����� � ������
#$dirLog = '\\172.18.209.20\UpdatePG'
$dirLog = $dirTemp
$pathLog = $dirLog  + '\' + ($env:computername) + '--' + $StampName + '.log'
$pathLogPG = $dirLog  + '\' + ($env:computername) + '--' + $StampName + '--PG.log'
$strErr = $null


### ��������� ���������� (��� ������� �������)
function Check-Admin
{
    Param([switch]$Elevated)
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) }
    if ((Check-Admin) -eq $false)
    { 
        if ($elevated) {
            # Could not elevate, quit
        }
        else { 
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ( $myinvocation.MyCommand.Definition ))
        }
    exit
}


### �����������
function WriteLog
{
    Param([string]$strLog)
    $Stamp = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
    $msgLog = "$Stamp : $strLog"
    Add-Content -Path $pathLog -Value $msgLog
}


# ������
$Error.Clear()


### �� ������, ���� �������� ��������� ���� � �������
Set-Service -Name seclogon -StartupType Automatic
Start-Service -Name seclogon


### ������ ��������� �����
if (-Not(Test-Path -Path $dirTemp))
{
    New-Item -Path $dirTemp -ItemType Directory
    WriteLog "�������� ��������� ����� $dirTemp"
}
else {WriteLog "��������� ����� $dirTemp ��� ����������"}


### ����
WriteLog ("������ ���������� PostgreSQL ������ 9.6 �� ������ 14 �� ����������� " +  ($env:computername))


# ��������� ���������� (��� ������� �������)
#Check-Admin
# �������� ���������� �� ����� ��������������
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
## ������� ������ ������� Check-Admin
##    $arguments = "& '" + $myinvocation.MyCommand.Definition + "'"
##    Start-Process powershell -Verb runAs -ArgumentList $arguments
##    Break

    WriteLog "��������� ���������� �� ����� ��������������"
    Exit
}


# ����������� ��������� ������ ������� ��� ������
$ErrorActionPreference = 'Stop'


### !!! ������ ���� pgpass.conf �� ��������� �����

<# ��� �������� pgpass � ������� ������������
if (Test-Path -Path $pathPswd)
{
    Rename-Item -Path $pathPswd $filePswd'--'$StampName
    WriteLog ("�������������� c������������ ����� $pathPswd � $filePswd"+"--"+$StampName)
}
#>

if (-Not(Test-Path -Path $dirPswd))
{New-Item -Path $dirPswd -ItemType Directory}

if (-Not(Test-Path -Path $pathPswd))
{
    New-Item -Path $pathPswd -ItemType File
    $strPswd | Out-file $pathPswd
    ### ������������ � utf-8 ��� BOM ������ � ������� postgres
    [System.IO.File]::WriteAllLines($pathPswd,  $strPswd, $utf8NoBOMEncoding)

    [Environment]::SetEnvironmentVariable('PGPASSFILE', $pathPswd, "Process")
    
    WriteLog "�������� ����� $pathPswd � �������� ������� ��� ���������� �������"
}


### ������������� ������ PostgreSQL 9
Restart-Service $srvPG9
WriteLog "���������� ������ PostgreSQL 9"

<#
### ������������� ������ Trassir � 1C
Stop-Service $srv1C
#Stop-Service $srvTrassir
WriteLog "��������� ����� 1� � Trassir"
#>

### ������ ���� 9 ������
cd ($dirPG9 + '\bin\')
.\pg_dumpall.exe -U postgres --file=$dirTemp'\'$fileDump
WriteLog "������ ���� �������� PostgreSQL 9.6"


### ������������� � *���������* PostgreSQL 9.6
Set-Service $srvPG9 -StartupType Disabled -Status Stopped
WriteLog "���������� ������ PostgreSQL 9.6"


### �������� ����������� 
Copy-Item $pathInstaller -Destination $dirTemp
WriteLog "����������� ������������ PostgreSQL 14"


### ������������� PostgreSQL 14 (�� ����������� ���� 5432!)
Try
{
    # ������� 1
    #msiexec.exe /i $pathInstaller /quiet /lime $pathLogPG
    #while (Get-Process -Name 'msiexec' -ErrorAction SilentlyContinue)
    #{Start-sleep -Seconds 5}
    
    # ������� 2
    <#
    $msiArguments =@(
        "/i"
        $pathInstaller
        "/quiet"
        "/norestart"
        "/lime"
        $pathLogPG
    )
    <#>
    $msiArguments =@(
        "/i"
        $dirTemp + "\" + $nameInstaller
        "/quiet"
        "/norestart"
        "/lime"
        $pathLogPG
    )
    
    Start-Process "msiexec.exe" -ArgumentList $msiArguments -Wait -NoNewWindow
}
Catch {
    WriteLog "��������� PostgreSQL 14 �� ���������"
    WriteLog $_
    WriteLog $PSItem
    WriteLog $Error
    Set-Service $srvPG9 -StartupType Automatic -Status Running
    Set-Service $srvPG9 -StartupType Automatic -Status Running
    #Start-Service $srv1C
    #Start-Service $srvTrassir
    if (Test-Path -Path $pathPswd)
    {Remove-Item -Path $pathPswd}
}
Finally {
    if (-Not(Test-Path -Path $dirPG14)) {
        WriteLog "����������� ����� $dirPG14. ��������� �������� ������� ������ PostgreSQl!"
        WriteLog $_
        WriteLog $PSItem
        WriteLog $Error
        Set-Service $srvPG9 -StartupType Automatic -Status Running
        #Start-Service $srv1C
        #Start-Service $srvTrassir
        if (Test-Path -Path $pathPswd)
        {Remove-Item -Path $pathPswd}
        
        Exit
    }
}

WriteLog "��������� PostgreSQL 14 (�� ����������� ���� 5432!)"


### �������������� ���������� ����� (process)
[Environment]::SetEnvironmentVariable('PGPORT', '5432', "Process")
[Environment]::SetEnvironmentVariable('PGUSER', 'postgres', "Process")
[Environment]::SetEnvironmentVariable('PGLOCALEDIR', (($dirPG14 -replace '/', '\') + "\share\locale"), "Process")
[Environment]::SetEnvironmentVariable('PGDATABASE', 'postgres')
[Environment]::SetEnvironmentVariable('PGDATA', (($dirPG14 -replace '/', '\') + "\data"), "Process")
$strCmd = [Environment]::GetEnvironmentVariable('Path')
$strCmd = $strCmd.Replace((';' + ($dirPG9 -replace '/', '\') + "\bin;"), ';')
$strCmd = $strCmd + ';' + (($dirPG14 -replace '/', '\') + "\bin")
[Environment]::SetEnvironmentVariable('Path', $strCmd, 'Process')

WriteLog "���������� ����� PG* (process)"

### (machine)
[Environment]::SetEnvironmentVariable('PGPORT', '5432', "Machine")
[Environment]::SetEnvironmentVariable('PGUSER', 'postgres', "Machine")
[Environment]::SetEnvironmentVariable('PGLOCALEDIR', (($dirPG14 -replace '/', '\') + "\share\locale"), "Machine")
[Environment]::SetEnvironmentVariable('PGDATABASE', 'postgres')
[Environment]::SetEnvironmentVariable('PGDATA', (($dirPG14 -replace '/', '\') + "\data"), "Machine")
$strCmd = [Environment]::GetEnvironmentVariable('Path')
$strCmd = $strCmd.Replace((';' + ($dirPG9 -replace '/', '\') + "\bin;"), ';')
$strCmd = $strCmd + ';' + (($dirPG14 -replace '/', '\') + "\bin")
[Environment]::SetEnvironmentVariable('Path', $strCmd, 'Machine')

WriteLog "���������� ����� PG*"


### �������� pg_hba.conf (� ������ 14 �� ������ 9)
Rename-Item -Path $dirPG14'\data\pg_hba.conf' 'pg_hba.conf0'
Copy-Item $dirPG9'\data\pg_hba.conf' -Destination $dirPG14'\data\'
WriteLog "��������� ����������� �� ������ 9"


###��������� � postgresql.conf �������� ���������� �� ���������� ���������
Copy-Item $pathconf -Destination $dirTemp
$strCmd = Get-Content -Path ($dirTemp + '\' + $nameConf)
Add-Content -Path $dirPG14'\data\postgresql.conf' -Value $strCmd
WriteLog "��������� �� ������ 9"

###��������� � postgresql.conf �������� ����������, ��������������� ��� 1�
#????????????????


### ������������� ������ PostgreSQL 14
#Restart-Service $srvPG14
Start-Service $srvPG14
WriteLog "������ ������ PostgreSQL 14"


### ��������������� ������� ���� � 14 ������
cd ($dirPG14 + '/bin/')
$ErrorActionPreference = 'Continue'
.\psql.exe -U postgres --file=$dirTemp'\'$fileDump
$ErrorActionPreference = 'Stop'
WriteLog "������� �������������� ������� ��� � ������ 14"
WriteLog "������ � ��������������: $Error"


### ������� ���� � �������
if (Test-Path -Path $pathPswd)
{Remove-Item -Path $pathPswd}

if (Test-Path -Path $pathPswd'--'$StampName)
{Rename-Item -Path $pathPswd'--'$StampName $filePswd}

WriteLog "�������� ����� $pathPswd"

### ������� ����������� � ���������
if (Test-Path -Path ($dirTemp + "\" + $nameInstaller))
{Remove-Item -Path ($dirTemp + "\" + $nameInstaller)}
WriteLog "�������� ����� $dirTemp\$nameInstaller"

if (Test-Path -Path ($dirTemp + '\' + $nameConf))
{Remove-Item -Path ($dirTemp + '\' + $nameConf)}
WriteLog "�������� ����� $dirTemp\$nameConf"


<#
### ������� ��������� �����
if (Test-Path -Path $dirTemp)
{Remove-Item -Path $dirTemp -recurse}
WriteLog "�������� ��������� �����"
#>

<#
###��������� ������ Trassir � 1C
Start-Service $srv1C
#Start-Service $srvTrassir
WriteLog "������ ����� 1� � Trassir"
#>

Clear-RecycleBin -Force
WriteLog "������� �������"

#WriteLog "������: $Error"
WriteLog "����������"

# SIG # Begin signature block
# MIIFZQYJKoZIhvcNAQcCoIIFVjCCBVICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNpIGetlD+gQvS8SJM6mKXmQ5
# ioCgggMJMIIDBTCCAe2gAwIBAgIQJoTcjL4GsLhIi0YMEQBZ+TANBgkqhkiG9w0B
# AQsFADARMQ8wDQYDVQQDDAZwc1Rlc3QwHhcNMjQwNTI3MTEyMTMyWhcNMjUwNTI3
# MTE0MTMyWjARMQ8wDQYDVQQDDAZwc1Rlc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQChwDuhp4kzhJV/Y0o+BxTKZu1D93N3tMquLTTt/gYGI0sSjil4
# WfVwRXl0Z67LGDS7ecrekuTzHt2X8qqwaqPLbWfQkAHc7BEe7OdmBPrTmLvuxV1Y
# ve9AYkYgybmoVlcDW4GedzS/CdLXzJEWzbI4TJpl8px1uI7TZMIKFvlvJ6nqLovI
# pm+dx7ub4+5XLJgs26Jw1dLDFXC9kmAZu0CAQpONd3PVtkRj/Dscrp4bcLvhuoU1
# b5F2frND7fMpccYp8Ast0nVOV1I86fiSr3NWDX5ZJP6aEmNryp15UboLQHBumshd
# Mp91EtYWlTQZGwFh/gx139kxcdaQWda2Tw2RAgMBAAGjWTBXMA4GA1UdDwEB/wQE
# AwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzARBgNVHREECjAIggZwc1Rlc3QwHQYD
# VR0OBBYEFDhwx9RlHc4BeF/TOGVKOBn2wTr8MA0GCSqGSIb3DQEBCwUAA4IBAQCa
# 27rhSZ2sv+V9dhNLfFMI9mM46gDkVGL4EUoJvXdWsqqq/J9kA62s4HFWOzrZLoZs
# vkE3/e1PZLmpmCr+8tQX5O4I6lsJ+atO+tZk8iGndnvhUjhXSgIuGynDrzy4W42S
# tcV7Z0h6KF7nNC7QgHS1XzuIPL73cM+u1T82ml0aV9h3FTR6yLA0VGboONWRK5Vo
# 3x6NV+ZWf/H7zG02+e7CRIkKYRAkFU1OPNJe7SB9gqmDLSDOx6f2Y4NZ0ckNLIWM
# mg4zx7rgRdLOMemiUlAft3HHf0iz037Jidqq11mBg4rKwR3VUs7Ae6ekGaw09S+K
# Ow51h+57IrQ1TqI7lJS4MYIBxjCCAcICAQEwJTARMQ8wDQYDVQQDDAZwc1Rlc3QC
# ECaE3Iy+BrC4SItGDBEAWfkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFOaDl0AVsSmrBULyVzbh
# Ps34TUNrMA0GCSqGSIb3DQEBAQUABIIBAF6EEx/XsCHFnjKqUhNBXkKavwNEuHpK
# wBmZNQK98eC9aDapTQvtzZk+kGydpyiHIozpTvK6WfwXBSP0l0TFmcFZVd8lqNzL
# WImw1nDGGjpVYb/PBbZgmF1kRHbeq9P+JvrcEO3y735euAwE9XvXI0AQ0RHnBNAd
# VHRgdlwyieaBTnkui5sYtIQ4hMj0rI8+rtGlh3JwL/d4RkBXZYFjbuDDpdl035jT
# OthyiLbhMWxRSB55zc9BV2Z10tAHwze4F1mRCdadYNc+GvxKN0dCL6T8YnST+1nh
# RXySqA7Ccjn8phnIQj89ESCpqVm+nn4HFgEZjNJppZCiJ6zs4xl0xlc=
# SIG # End signature block
