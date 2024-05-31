# Обновление PostgreSQL 9.6 до версии 12 (для 1С)
#
# подпись скрипта>  Set-AuthenticodeSignature C:/testPG/testPG.ps1 @(Get-ChildItem Cert:\LocalMachine\My -codesigning)[0]
#
# структура папки скрипта
# UpdatePG9
# |-installer
# | |-postgresql-14.11-3.1C(x64).msi
# | |-postgresql-14.11-3.1C(x64)-int.msi - !!! файл с заполненным паролем
# | |-vcredist_x64.exe
# |-append-postgresql.conf - в проекте
# |-pg_hba.conf - в проекте
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
# !!! указать пароль postgres
$strPswd = 'localhost:5432:*:postgres:375183'
$utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding($False)
$cmdStr = ''
$srv1C = '1C:Enterprise 8.3 Server Agent (x86-64)'
$srvTrassir = 'trassir'
$srvPG9 = 'pgsql-9.6.7-1.1C-x64'
$srvPG14 = 'pgsql-14.11-3.1C-x64'
# инcталлятор PostgreSQL 14 
$dirInstaller = $MyInvocation.MyCommand.Path | split-path -parent
$pathInstaller = $dirInstaller + '\installer\postgresql-14.11-3.1C(x64).msi'
# !!! указать путь к папке с логами
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

### Логи
WriteLog ("Начало обновления PostgreSQL версии 9.6 до версии 14 на комппьютере " +  ($env:computername))

# Проверка выполнения от имени администратора
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break

#    WriteLog "Требуется выполнение от имени администратора"
#    Exit
}

# Ошибки
$Error.Clear()

# Настраиваем остановку работы скрипта при ошибке
$ErrorActionPreference = 'Stop'

#
Set-Service -Name seclogon -StartupType Automatic
Start-Service -Name seclogon

### создаём временную папку
if (-Not(Test-Path -Path $dirTemp))
{
    New-Item -Path $dirTemp -ItemType Directory
    WriteLog "Создание временной папки $dirTemp"
}
else
{
    WriteLog "Временная папка $dirTemp уже существует"
}

#### создаём файл pgpass.conf в C:\Users\%username%\AppData\Roaming\postgresql\
#if (Test-Path -Path $pathPswd)
#{
#    Rename-Item -Path $pathPswd $filePswd'--'$Stamp
#    WriteLog ("Переименование cуществующего файла $pathPswd в $filePswd"+"--"+$Stamp)
#}

#if (-Not(Test-Path -Path $dirPswd))
#{
#    New-Item -Path $dirPswd -ItemType Directory
#}


#if (-Not(Test-Path -Path $pathPswd))
#{
#    New-Item -Path $pathPswd -ItemType File
#    $strPswd | Out-file $pathPswd
#    ### конвертируем в utf-8 без BOM строку с паролем postgres
#    [System.IO.File]::WriteAllLines($pathPswd,  $strPswd, $utf8NoBOMEncoding)
#    WriteLog "Создание файла $pathPswd с учётными данными для выполнения скрипта"
#}

### останавливаем службы Trassir и 1C
#!!!Stop-Service $srv1C
#!!!Stop-Service $srvTrassir
#WriteLog "Остановка служб 1С и Trassir"

#### полный дамп 9 версии
##cd ($dirPG9 + '\bin\')
#pg_dumpall -U postgres --file=$dirTemp'\'$fileDump
#WriteLog "Полный дамп кластера PostgreSQL 9.6"

#### останавливаем и *отключаем* PostgreSQL 9.6
#Set-Service $srvPG9 -StartupType Disabled -Status Stopped
#WriteLog "Отключение службы PostgreSQL 9.6"

### устанавливаем PostgreSQL 14 (на стандартный порт 5432!)
try {
    #Set-Service -Name seclogon -StartupType Automatic
    #Start-Service -Name seclogon
   
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
        $pathInstaller
        "/quiet"
        "/norestart"
        "/L*v"
        $pathLogPG
    )

    #$msiArguments =@(
    #    "/i"
    #    $pathInstaller
    #    "/L*v"
    #    $pathLogPG
    #)


    #Start-Process "msiexec.exe" -ArgumentList $msiArguments -Wait -NoNewWindow
    Start-Process msiexec "/i $pathInstaller /quiet /norestart /l*v $pathLogPG" -Wait -NoNewWindow
}
catch {
    WriteLog "Установка PostgreSQL 14 не выполнена"
    WriteLog $_
    WriteLog $PSItem
    WriteLog $Error
}
WriteLog "Установка PostgreSQL 14 (на стандартный порт 5432!)"

#### перезаписываем переменные среды
#$Env:PGPORT = "5432"
#$Env:PGUSER = "postgres"
#$Env:PGLOCALEDIR = $dirPG14 + "\share\locale"
#$Env:PGDATABASE = "postgres"
#$Env:PGDATA = $dirPG14 + "\data"
#WriteLog "Переменные среды PG*"

#### восстанавливаем рабочие базы в 14 версию
##cd ($dirPG14 + '/bin/')
#psql.exe -U postgres --file=$dirTemp'\'$fileDump
#WriteLog "Восстановление рабочих баз в версию 14"

#### заменяем pg_hba.conf (в версию 14 из версии 9)
#Rename-Item -Path $dirPG14'\data\pg_hba.conf' 'pg_hba.conf0'
#Copy-Item $dirPG9'\data\pg_hba.conf' -Destination $dirPG14'\data\'
#WriteLog "Настройки подключения из версии 9"

###добавляем в postgresql.conf значения параметров, рекомендованные для 1С
#!!!!!!!!!!!!!!!!!

#### перезапускаем службу PostgreSQL 14
#Restart-Service $srvPG14
#WriteLog "Перезапуск службы PostgreSQL 14"

#### удаляем файл с паролем
#if (Test-Path -Path $pathPswd)
#{Remove-Item -Path $pathPswd}
#if (Test-Path -Path $pathPswd'--'$Stamp)
#{Rename-Item -Path $pathPswd'--'$Stamp $filePswd}
#WriteLog "Удаление файла $pathPswd с учётными данными для выполнения скрипта"

### удаляем временную папку
#!!!if (Test-Path -Path $dirTemp)
#!!!{Remove-Item -Path $dirTemp -recurse}
#WriteLog "Удаление временной папки"

###запускаем службы Trassir и 1C
#!!!SC start $srv1C
#!!!SC start $srvTrassir
#WriteLog "Запуск служб 1С и Trassir"

WriteLog "Ошибки: $Error"
WriteLog "Завершение"

# Возвращаем значение действий при ошибке, установленное в системе
#$ErrorActionPreference = $aep


# SIG # Begin signature block
# MIIFZQYJKoZIhvcNAQcCoIIFVjCCBVICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoCUYon6wo9afBXmJB1fmeVQD
# mFSgggMJMIIDBTCCAe2gAwIBAgIQJoTcjL4GsLhIi0YMEQBZ+TANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFcNNUOnhOKisS22B58S
# kNn4fTGkMA0GCSqGSIb3DQEBAQUABIIBAG61xWeC3Cq7N4iRcCz+G9GpL4wcz5hN
# Blvm90ZNTmf/1otaq4yFWqOL0LtTsYx+k5nslXg2CwfVOFJdNyCcg1Ao+tGYNUNo
# wlM81cvayG6ytnnfKLKMTFT/Mxn5n7ag04G6j2An+Fpx03Gwz7QUSMzeR9bPWFxx
# xcxpZzZJ6rgCqc8He5sL+RDNxTowSiNhZ2Briun8uwlEiV1spbWYaBSUc3ZsI46m
# BQi78KxuxiFMAPU37FaLKMuIn4+NDEe9aXtLBuqYezBTxghxpzTMbxKestQEeun0
# cOAf7ebT9badOWNECq7fa3Sw8vww+zRoCEdn/WmX2Ohiw8Aabo7XwkY=
# SIG # End signature block
