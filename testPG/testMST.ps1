# Обновление PostgreSQL 9.6 до версии 12 (для 1С)
#
# структура папки скрипта
# UpdatePG9
# |-installer
# | |-postgresql-14.11-3.1C(x64).msi
# | |-postgresql-14.11-3.1C(x64)-int.msi
# | |-vcredist_x64.exe
# |-append-postgresql.conf
# |-pg_hba.conf
# |-update-9-to-14.ps1
#

$dirPG9 = 'C:\Program Files\PostgreSQL\9.6.7-1.1C'
$dirPG14 = 'C:\Program Files\PostgreSQL\14.11-3.1C'
$dirTemp = 'C:\tempPG'
$fileDump = 'pg9.dmp'
$filePswd = 'pgpass.conf'
$pathPswd = $Env:APPDATA + '\postgresql\' + $filePswd
# !!! указать пароль postgres
$strPswd = 'localhost:5432:*:postgres:375183'
$utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding($False)
$cmdStr = ''
$srv1C = '1C:Enterprise 8.3 Server Agent (x86-64)'
$srvTrassir = 'trassir'
$srvPG9 = 'pgsql-9.6.7-1.1C-x64'
$srvPG14 = 'pgsql-14.11-3.1C-x64'
# !!! инcталлятор PostgreSQL 14 
$dirInstaller = $MyInvocation.MyCommand.Path | split-path -parent
$pathInstaller = $dirInstaller + '\installer\postgresql-14.11-3.1C(x64).msi' 

### устанавливаем PostgreSQL 14 (на стандартный порт 5432!)
$pathInstaller
msiexec /i $pathInstaller /LIME 'C:\testPG\logfile.txt'
#msiexec /i $pathInstaller /quiet /qn /LIME 'C:\testPG\logfile8.txt'


while (Get-Process -Name 'msiexec' -ErrorAction SilentlyContinue) {
    Start-sleep -Seconds 5
}

'123' | Out-file 'C:\testPG\123.txt'


# SIG # Begin signature block
# MIIFZQYJKoZIhvcNAQcCoIIFVjCCBVICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/ZG/LoNY+grQxTOCJh6jE6ft
# 1nigggMJMIIDBTCCAe2gAwIBAgIQJoTcjL4GsLhIi0YMEQBZ+TANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPpavW/3HAhYyC439s9r
# Lv15RMbQMA0GCSqGSIb3DQEBAQUABIIBAChz060bxu9GY298OIX7FB3cvH2eKBFG
# IN+kJORwiic9KHq9uFPvNX1Q4fLlNTyVTM/mY38p+HI5VAYmYKaMyqYB0cLExZ8O
# 1yFzCNaFyAKagU2J+DwdF8ZKhsxNgX5HnX/djyxMmwehZJIHjCncwCI0Nl7yVd2L
# 8z3zTzrJkyxK8oQVMZEVNs+wvvO8/qNMg1z5lfU2D71EJTHW+DuDPRqSBqRZ5NW3
# rASejQW+TlA8DgeUjPc7VB3fp+vt5kCLsHvzjpXJ/sfQU79O09NaPyexD/yvvjci
# 7LtULa1mFpdB6+0M+G4qRNBwKMaN1Lrvn2/MO7/kga80g8SNgkJ8W/A=
# SIG # End signature block
