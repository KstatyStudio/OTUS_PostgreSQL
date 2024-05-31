# ���������� PostgreSQL 9.6 �� ������ 12 (��� 1�)
#
# ������� �������>  Set-AuthenticodeSignature C:/testPG/testPG.ps1 @(Get-ChildItem Cert:\LocalMachine\My -codesigning)[0]
#
# ��������� ����� �������
# UpdatePG9
# |-installer
# | |-postgresql-14.11-3.1C(x64).msi
# | |-postgresql-14.11-3.1C(x64)-int.msi - !!! ���� � ����������� �������
# | |-vcredist_x64.exe
# |-append-postgresql.conf - � �������
# |-pg_hba.conf - � �������
# |-update-9-to-14.ps1
#


$dirPG9 = 'C:/Program Files/PostgreSQL/9.6.7-1.1C'
$dirPG14 = 'C:/Program Files/PostgreSQL/14.11-3.1C'
$Stamp = (Get-Date -Format "yyyy-MM-dd--HH-mm")
$dirTemp = 'C:/tempPG' + '--' + $Stamp
$fileDump = 'pg9.dmp'
$dirPswd = $Env:APPDATA + '\postgresql'
$filePswd = 'pgpass.conf'
$pathPswd = $dirPswd + '\' + $filePswd
# !!! ������� ������ postgres
$strPswd = 'localhost:5432:*:postgres:375183'
$utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding($False)
$cmdStr = ''
$srv1C = '1C:Enterprise 8.3 Server Agent (x86-64)'
$srvTrassir = 'trassir'
$srvPG9 = 'pgsql-9.6.7-1.1C-x64'
$srvPG14 = 'pgsql-14.11-3.1C-x64'
# ��c�������� PostgreSQL 14 
$dirInstaller = $MyInvocation.MyCommand.Path | split-path -parent
$pathInstaller = $dirInstaller + '\installer\postgresql-14.11-3.1C(x64).msi'
# !!! ������� ���� � ����� � ������
$dirLog = 'C:/testPG'
$pathLog = $dirLog  + '/' + ($env:computername) + '--' + $Stamp + '.log'
$pathLogPG = $dirLog  + '/' + ($env:computername) + '--' + $Stamp + '--PG.log'
$strErr = ''
$eap = $ErrorActionPreference


function WriteLog
{
Param([string]$strLog)
$Stamp = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
$msgLog = "$Stamp : $strLog"
Add-Content -Path $pathLog -Value $msgLog
}


# ����������� ��������� ������ ������� ��� ������
$ErrorActionPreference = 'Stop'

### ������ ���� ����
WriteLog ("������ ���������� PostgreSQL ������ 9.6 �� ������ 14 �� ����������� " +  ($env:computername))

### ������ ��������� �����
if (-Not(Test-Path -Path $dirTemp))
{
    New-Item -Path $dirTemp -ItemType Directory
    WriteLog "�������� ��������� ����� $dirTemp"
}
else
{
    WriteLog "��������� ����� $dirTemp ��� ����������"
}

### ������ ���� pgpass.conf � C:\Users\%username%\AppData\Roaming\postgresql\
if (Test-Path -Path $pathPswd)
{
    Rename-Item -Path $pathPswd $filePswd'--'$Stamp
    WriteLog ("�������������� c������������ ����� $pathPswd � $filePswd"+"--"+$Stamp)
}

if (-Not(Test-Path -Path $dirPswd))
{
    New-Item -Path $dirPswd -ItemType Directory
}


if (-Not(Test-Path -Path $pathPswd))
{
    New-Item -Path $pathPswd -ItemType File
    $strPswd | Out-file $pathPswd
    ### ������������ � utf-8 ��� BOM ������ � ������� postgres
    [System.IO.File]::WriteAllLines($pathPswd,  $strPswd, $utf8NoBOMEncoding)
    WriteLog "�������� ����� $pathPswd � �������� ������� ��� ���������� �������"
}

### ������������� ������ Trassir � 1C
#!!!Stop-Service $srv1C
#!!!Stop-Service $srvTrassir
#WriteLog "��������� ����� 1� � Trassir"

### ������ ���� 9 ������
#cd ($dirPG9 + '\bin\')
pg_dumpall -U postgres --file=$dirTemp'\'$fileDump
WriteLog "������ ���� �������� PostgreSQL 9.6"

### ������������� � *���������* PostgreSQL 9.6
Set-Service $srvPG9 -StartupType Disabled -Status Stopped
WriteLog "���������� ������ PostgreSQL 9.6"

### ������������� PostgreSQL 14 (�� ����������� ���� 5432!)
try {
    Set-Service -Name seclogon -StartupType Automatic
    Start-Service -Name seclogon
    $pathInstaller
    $pathLogPG
    #msiexec /i $pathInstaller /lime $pathLogPG
    msiexec /i $pathInstaller /quiet /lime $pathLogPG
    #msiexec /i $pathInstaller /quiet /qn /lime $pathLogPG
    while (Get-Process -Name 'msiexec' -ErrorAction SilentlyContinue) {
        Start-sleep -Seconds 5
    }
}
catch {
    WriteLog $PSItem
}
finally {
    WriteLog "��������� PostgreSQL 14 (�� ����������� ���� 5432!)"
}

### �������������� ���������� �����
$Env:PGPORT = "5432"
$Env:PGUSER = "postgres"
$Env:PGLOCALEDIR = $dirPG14 + "\share\locale"
$Env:PGDATABASE = "postgres"
$Env:PGDATA = $dirPG14 + "\data"
WriteLog "���������� ����� PG*"

### ��������������� ������� ���� � 14 ������
#cd ($dirPG14 + '/bin/')
psql.exe -U postgres --file=$dirTemp'\'$fileDump
WriteLog "�������������� ������� ��� � ������ 14"

### �������� pg_hba.conf (� ������ 14 �� ������ 9)
Rename-Item -Path $dirPG14'\data\pg_hba.conf' 'pg_hba.conf0'
Copy-Item $dirPG9'\data\pg_hba.conf' -Destination $dirPG14'\data\'
WriteLog "��������� ����������� �� ������ 9"

###��������� � postgresql.conf �������� ����������, ��������������� ��� 1�
#!!!!!!!!!!!!!!!!!

### ������������� ������ PostgreSQL 14
Restart-Service $srvPG14
WriteLog "���������� ������ PostgreSQL 14"

### ������� ���� � �������
if (Test-Path -Path $pathPswd)
{Remove-Item -Path $pathPswd}
if (Test-Path -Path $pathPswd'--'$Stamp)
{Rename-Item -Path $pathPswd'--'$Stamp $filePswd}
WriteLog "�������� ����� $pathPswd � �������� ������� ��� ���������� �������"

### ������� ��������� �����
#!!!if (Test-Path -Path $dirTemp)
#!!!{Remove-Item -Path $dirTemp -recurse}
#WriteLog "�������� ��������� �����"

###��������� ������ Trassir � 1C
#!!!SC start $srv1C
#!!!SC start $srvTrassir
#WriteLog "������ ����� 1� � Trassir"

WriteLog "������: $Error"
WriteLog "����������"

# ���������� �������� �������� ��� ������, ������������� � �������
$ErrorActionPreference = $aep



# SIG # Begin signature block
# MIIFZQYJKoZIhvcNAQcCoIIFVjCCBVICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK1InhQgPgvAD9w7+euVqFMBg
# S9ygggMJMIIDBTCCAe2gAwIBAgIQJoTcjL4GsLhIi0YMEQBZ+TANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPqh45AQNeIhHPswbk/g
# MCwl2QMDMA0GCSqGSIb3DQEBAQUABIIBAAAfo8zj/mrFhQoA0WwFqPw4rJbSi6fL
# 5NgtrR0mPDwdnE6JvSx8U9l3/e6/1MvNGOWlJ4N9zuRZ74Bia87imhbFJalf8woF
# rkGuyi2EQ9Zl4kT2BC53DFjJ+KJib8mpe3UA7ZY24t2rDeWCzW8xWARQJSpOW/wA
# jUf0lq087Y/R40ds21KkbCe1uxg0E8JlnDgjt652kv3/3l5ArDIW0i4X2k3126M5
# IGP0c8Y+n4wah2f6va5a97BsPWSmcfyPl3wytATYX7xBLKCalzothmtCzYD4x+Rc
# Kp78kDrIS/KnPdzMj5iCi3qJThSx8aNqGw7mQdwiaGVEktkl/9OPWKQ=
# SIG # End signature block
