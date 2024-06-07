# Обновление PostgreSQL 9.6 до версии 12 (для 1С)
#
# подпись скрипта>  Set-AuthenticodeSignature C:/testPG/updatePG.ps1 @(Get-ChildItem Cert:\LocalMachine\My -codesigning)[0]
#
# структура папки скрипта
# UpdatePG9
# |-installer
# | |-postgresql-14-int.msi - !!! файл -int из установки PostgreSQL для 1C с заполненными locale (ru_RU.UTF-8) и паролем postgres, 
# |-append-1С-recomendation-postgresql.conf - в проекте (https://its.1c.ru/db/metod8dev#content:5866:hdoc:_top:postgresql)
# |-append-as-9-6-postgresql.conf
# |-pg_hba.conf - в проекте
# |-updatePG.ps1
#


$dirPG9 = 'C:\Program Files\PostgreSQL\9.6.7-1.1C'
$dirPG14 = 'C:\Program Files\PostgreSQL\14.11-3.1C'
$Stamp = (Get-Date -Format "yyyy-MM-dd--HH-mm")
$dirTemp = 'C:\tempPG' + '--' + $Stamp
$fileDump = 'pg9.dmp'
$dirPswd = $Env:APPDATA + '\postgresql'
$filePswd = 'pgpass.conf'
$pathPswd = $dirPswd + '\' + $filePswd
# !!! указать пароль postgres
$strPswd = 'localhost:5432:*:postgres:375183'
$utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding($False)
$strCmd = $null
$srv1C = '1C:Enterprise 8.3 Server Agent (x86-64)'
$srvTrassir = 'trassir'
$srvPG9 = 'pgsql-9.6.7-1.1C-x64'
$srvPG14 = 'pgsql-14.11-3.1C-x64'
# инcталлятор PostgreSQL 14 
$dirInstaller = $MyInvocation.MyCommand.Path | split-path -parent
$pathInstaller = $dirInstaller + '\installer\postgresql-14-int.msi'
# !!! указать файл с настройками PostgreSQL
$pathConf = $dirInstaller + '\append-as-9-6-postgresql.conf'
# !!! указать файл с рекомендациями 1С
$pathRecomend = $dirInstaller + '\append-1С-recomendation-postgresql.conf'
# !!! указать путь к папке с логами (не временная папка!)
$dirLog = '\\172.18.209.20\UpdatePG'
$pathLog = $dirLog  + '\' + ($env:computername) + '--' + $Stamp + '.log'
$pathLogPG = $dirLog  + '\' + ($env:computername) + '--' + $Stamp + '--PG.log'
$strErr = $null


### Повышение привилегий (при запуске вручную)
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


### Логирование
function WriteLog
{
    Param([string]$strLog)
    $Stamp = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
    $msgLog = "$Stamp : $strLog"
    Add-Content -Path $pathLog -Value $msgLog
}


### На случай, если отключен вторичный вход в систему
Set-Service -Name seclogon -StartupType Automatic
Start-Service -Name seclogon

### Логи
WriteLog ("Начало обновления PostgreSQL версии 9.6 до версии 14 на комппьютере " +  ($env:computername))


# Повышение привилегий (при запуске вручную)
#Check-Admin
# Проверка выполнения от имени администратора
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
## вариант вместо функции Check-Admin
##    $arguments = "& '" + $myinvocation.MyCommand.Definition + "'"
##    Start-Process powershell -Verb runAs -ArgumentList $arguments
##    Break

    WriteLog "Требуется выполнение от имени администратора"
    Exit
}


# Ошибки
$Error.Clear()


# Настраиваем остановку работы скрипта при ошибке
$ErrorActionPreference = 'Stop'


### создаём временную папку
if (-Not(Test-Path -Path $dirTemp))
{
    New-Item -Path $dirTemp -ItemType Directory
    WriteLog "Создание временной папки $dirTemp"
}
else {WriteLog "Временная папка $dirTemp уже существует"}


### создаём файл pgpass.conf в C:\Users\%username%\AppData\Roaming\postgresql\
if (Test-Path -Path $pathPswd)
{
    Rename-Item -Path $pathPswd $filePswd'--'$Stamp
    WriteLog ("Переименование cуществующего файла $pathPswd в $filePswd"+"--"+$Stamp)
}

if (-Not(Test-Path -Path $dirPswd))
{New-Item -Path $dirPswd -ItemType Directory}


if (-Not(Test-Path -Path $pathPswd))
{
    New-Item -Path $pathPswd -ItemType File
    $strPswd | Out-file $pathPswd
    ### конвертируем в utf-8 без BOM строку с паролем postgres
    [System.IO.File]::WriteAllLines($pathPswd,  $strPswd, $utf8NoBOMEncoding)
    WriteLog "Создание файла $pathPswd с учётными данными для выполнения скрипта"
}


### останавливаем службы Trassir и 1C
Stop-Service $srv1C
Stop-Service $srvTrassir
WriteLog "Остановка служб 1С и Trassir"


### полный дамп 9 версии
cd ($dirPG9 + '\bin\')
.\pg_dumpall.exe -U postgres --file=$dirTemp'\'$fileDump
WriteLog "Полный дамп кластера PostgreSQL 9.6"


### останавливаем и *отключаем* PostgreSQL 9.6
Set-Service $srvPG9 -StartupType Disabled -Status Stopped
WriteLog "Отключение службы PostgreSQL 9.6"


### устанавливаем PostgreSQL 14 (на стандартный порт 5432!)
Try
{
    # вариант 1
    #msiexec.exe /i $pathInstaller /quiet /lime $pathLogPG
    #while (Get-Process -Name 'msiexec' -ErrorAction SilentlyContinue)
    #{Start-sleep -Seconds 5}
    
    # вариант 2
    $msiArguments =@(
        "/i"
        $pathInstaller
        "/quiet"
        "/norestart"
        "/lime"
        $pathLogPG
    )
    Start-Process "msiexec.exe" -ArgumentList $msiArguments -Wait -NoNewWindow
}
Catch {
    WriteLog "Установка PostgreSQL 14 не выполнена"
    WriteLog $_
    WriteLog $PSItem
    WriteLog $Error
    Set-Service $srvPG9 -StartupType Automatic -Status Running
}
Finally {
    if (-Not(Test-Path -Path $dirPG14)) {
        WriteLog "Отсутствует папка $dirPG14. Требуется проверка запуска службы PostgreSQl!"
        WriteLog $_
        WriteLog $PSItem
        WriteLog $Error
        #Set-Service $srvPG9 -StartupType Automatic -Status Running
        Exit
    }
}

WriteLog "Установка PostgreSQL 14 (на стандартный порт 5432!)"


### перезаписываем переменные среды
[Environment]::SetEnvironmentVariable('PGPORT', '5432', "Machine")
[Environment]::SetEnvironmentVariable('PGUSER', 'postgres', "Machine")
[Environment]::SetEnvironmentVariable('PGLOCALEDIR', (($dirPG14 -replace '/', '\') + "\share\locale"), "Machine")
[Environment]::SetEnvironmentVariable('PGDATABASE', 'postgres')
[Environment]::SetEnvironmentVariable('PGDATA', (($dirPG14 -replace '/', '\') + "\data"), "Machine")
$strCmd = [Environment]::GetEnvironmentVariable('Path')
$strCmd = $strCmd.Replace((';' + ($dirPG9 -replace '/', '\') + "\bin;"), ';')
$strCmd = $strCmd + ';' + (($dirPG14 -replace '/', '\') + "\bin")
[Environment]::SetEnvironmentVariable('Path', $strCmd, 'Machine')

WriteLog "Переменные среды PG*"


### заменяем pg_hba.conf (в версию 14 из версии 9)
Rename-Item -Path $dirPG14'\data\pg_hba.conf' 'pg_hba.conf0'
Copy-Item $dirPG9'\data\pg_hba.conf' -Destination $dirPG14'\data\'
WriteLog "Настройки подключения из версии 9"


###добавляем в postgresql.conf значения параметров из предыдущей установки
$strCmd = Get-Content -Path $pathConf
Add-Content -Path $dirPG14'\data\postgresql.conf' -Value $strCmd
WriteLog "Настройки из версии 9"

###добавляем в postgresql.conf значения параметров, рекомендованные для 1С
#????????????????


### перезапускаем службу PostgreSQL 14
#Restart-Service $srvPG14
Start-Service $srvPG14
WriteLog "Запуск службы PostgreSQL 14"


### восстанавливаем рабочие базы в 14 версию
cd ($dirPG14 + '/bin/')
$ErrorActionPreference = 'Continue'
.\psql.exe -U postgres --file=$dirTemp'\'$fileDump
$ErrorActionPreference = 'Stop'
WriteLog "Попытка восстановления рабочих баз в версию 14"
WriteLog "Ошибки и предупреждения: $Error"


### удаляем файл с паролем
if (Test-Path -Path $pathPswd)
{Remove-Item -Path $pathPswd}

if (Test-Path -Path $pathPswd'--'$Stamp)
{Rename-Item -Path $pathPswd'--'$Stamp $filePswd}

WriteLog "Удаление файла $pathPswd"


### удаляем временную папку
if (Test-Path -Path $dirTemp)
{Remove-Item -Path $dirTemp -recurse}
WriteLog "Удаление временной папки"


###запускаем службы Trassir и 1C
Start-Service $srv1C
Start-Service $srvTrassir
WriteLog "Запуск служб 1С и Trassir"


Clear-RecycleBin -Force

#WriteLog "Ошибки: $Error"
WriteLog "Завершение"


# SIG # Begin signature block
# MIIFZQYJKoZIhvcNAQcCoIIFVjCCBVICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSF3Dvaw6wzs1zeZJrJjV082b
# 7FigggMJMIIDBTCCAe2gAwIBAgIQJoTcjL4GsLhIi0YMEQBZ+TANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGSuZCeKhc4B4g2zSKtf
# piPnZzM/MA0GCSqGSIb3DQEBAQUABIIBAFTF7U4fE6YA+UL4I37W0mQFsofEI5wS
# PcdYYGQ/cu6iyxlSvRhyRE5WSM9ndJtZNKpUJ8F3J3KkJ5qg/Eysn8BVU7uVQ9Fr
# W+pYiYX9zSGCV+n0VAqLRAgdqpBZPkVDw9HIyBJhDoUuGfDs1ySsCWLgT0/P8yHS
# DoD/iy/bkszs2tuV+rX5s42NGyF07DhYKiFSQVsVq4JRwdqMsVmVA5Pi0TWmEWB5
# 4KtMbZpIKoFh6vVy1XkE/htdhUmfYYwa2wTWmbkZMmFDv85RcIXOYkfWfzpI6gFd
# OOLgXBWezeedIMLVitun/zNTLrAUU4FOjpCtHBZDAPCT/EMODbIBV64=
# SIG # End signature block
