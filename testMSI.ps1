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
$dirLog = 'C:\testPG'
$pathLog = $dirLog  + '\' + ($env:computername) + '--' + $Stamp + '.log'
$pathLogPG = $dirLog  + '\' + ($env:computername) + '--' + $Stamp + '--PG.log'
$strErr = ''
#$eap = $ErrorActionPreference


function WriteLog
{
Param([string]$strLog)
$Stamp = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
$msgLog = "$Stamp : $strLog"
Add-Content -Path $pathLog -Value $msgLog
}

### ����
WriteLog ("������ ���������� PostgreSQL ������ 9.6 �� ������ 14 �� ����������� " +  ($env:computername))

# �������� ���������� �� ����� ��������������
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    #$arguments = "& '" + $myinvocation.mycommand.definition + "'"
    #Start-Process powershell -Verb runAs -ArgumentList $arguments
    #Break

    WriteLog "��������� ���������� �� ����� ��������������"
    Exit
}

# ������
$Error.Clear()

# ����������� ��������� ������ ������� ��� ������
$ErrorActionPreference = 'Stop'

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

#### ������ ���� pgpass.conf � C:\Users\%username%\AppData\Roaming\postgresql\
#if (Test-Path -Path $pathPswd)
#{
#    Rename-Item -Path $pathPswd $filePswd'--'$Stamp
#    WriteLog ("�������������� c������������ ����� $pathPswd � $filePswd"+"--"+$Stamp)
#}

#if (-Not(Test-Path -Path $dirPswd))
#{
#    New-Item -Path $dirPswd -ItemType Directory
#}


#if (-Not(Test-Path -Path $pathPswd))
#{
#    New-Item -Path $pathPswd -ItemType File
#    $strPswd | Out-file $pathPswd
#    ### ������������ � utf-8 ��� BOM ������ � ������� postgres
#    [System.IO.File]::WriteAllLines($pathPswd,  $strPswd, $utf8NoBOMEncoding)
#    WriteLog "�������� ����� $pathPswd � �������� ������� ��� ���������� �������"
#}

### ������������� ������ Trassir � 1C
#!!!Stop-Service $srv1C
#!!!Stop-Service $srvTrassir
#WriteLog "��������� ����� 1� � Trassir"

#### ������ ���� 9 ������
##cd ($dirPG9 + '\bin\')
#pg_dumpall -U postgres --file=$dirTemp'\'$fileDump
#WriteLog "������ ���� �������� PostgreSQL 9.6"

#### ������������� � *���������* PostgreSQL 9.6
#Set-Service $srvPG9 -StartupType Disabled -Status Stopped
#WriteLog "���������� ������ PostgreSQL 9.6"

### ������������� PostgreSQL 14 (�� ����������� ���� 5432!)
try {
    Set-Service -Name seclogon -StartupType Automatic
    Start-Service -Name seclogon
    #$pathInstaller
    #$pathLogPG
    #msiexec.exe /i $pathInstaller /lime $pathLogPG
    #msiexec.exe /i $pathInstaller /quiet /lime $pathLogPG
    #msiexec /i $pathInstaller /quiet /qn /lime $pathLogPG
    #while (Get-Process -Name 'msiexec' -ErrorAction SilentlyContinue) {
    #    Start-sleep -Seconds 5
    #}


    $msiArguments =@(
        "/i"
        ('"{0}"' -f $pathInstaller)
        "/quiet"
        "/norestart"
        "/L*v"
        $pathLogPG
    )
    #Start-Process "msiexec.exe" -ArgumentList $msiArguments -Wait -NoNewWindow
    Start-Process msiexec "/i $pathInstaller /quiet /l*v $pathLogPG" -Wait -NoNewWindow
}
catch {
    WriteLog "��������� PostgreSQL 14 �� ���������"
    WriteLog $_
    WriteLog $PSItem
    WriteLog $Error
}
WriteLog "��������� PostgreSQL 14 (�� ����������� ���� 5432!)"

#### �������������� ���������� �����
#$Env:PGPORT = "5432"
#$Env:PGUSER = "postgres"
#$Env:PGLOCALEDIR = $dirPG14 + "\share\locale"
#$Env:PGDATABASE = "postgres"
#$Env:PGDATA = $dirPG14 + "\data"
#WriteLog "���������� ����� PG*"

#### ��������������� ������� ���� � 14 ������
##cd ($dirPG14 + '/bin/')
#psql.exe -U postgres --file=$dirTemp'\'$fileDump
#WriteLog "�������������� ������� ��� � ������ 14"

#### �������� pg_hba.conf (� ������ 14 �� ������ 9)
#Rename-Item -Path $dirPG14'\data\pg_hba.conf' 'pg_hba.conf0'
#Copy-Item $dirPG9'\data\pg_hba.conf' -Destination $dirPG14'\data\'
#WriteLog "��������� ����������� �� ������ 9"

###��������� � postgresql.conf �������� ����������, ��������������� ��� 1�
#!!!!!!!!!!!!!!!!!

#### ������������� ������ PostgreSQL 14
#Restart-Service $srvPG14
#WriteLog "���������� ������ PostgreSQL 14"

#### ������� ���� � �������
#if (Test-Path -Path $pathPswd)
#{Remove-Item -Path $pathPswd}
#if (Test-Path -Path $pathPswd'--'$Stamp)
#{Rename-Item -Path $pathPswd'--'$Stamp $filePswd}
#WriteLog "�������� ����� $pathPswd � �������� ������� ��� ���������� �������"

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
#$ErrorActionPreference = $aep


