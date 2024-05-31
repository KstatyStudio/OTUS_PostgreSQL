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
    #$arguments = "& '" + $myinvocation.mycommand.definition + "'"
    #Start-Process powershell -Verb runAs -ArgumentList $arguments
    #Break

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


