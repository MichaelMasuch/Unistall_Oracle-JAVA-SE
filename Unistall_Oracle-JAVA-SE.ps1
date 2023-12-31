<#
#########################################################
#
# michael.masuch@faps.fau.de
#
# MMa v1 2022-02-16
# MMa v2 2022-03-02 
# MMa v3 2022-05-10 : Kommentare ergaenzt
#
# in Anlehnung an Skript:
# https://adamtheautomator.com/removing-old-java/
# 
# Beschreibung:
# Deinstallation von Oracle Java SE da an der FAU nicht mehr kostenfrei nutzbar,
# ohne gegen die Lizenzbedingungen von Oracle zu verstossen.
#
# Siehe:
# https://www.rrze.fau.de/2019/04/oracle-java-ist-lizenz%E2%80%90-und-kostenpflichtig/
#
# Siehe auch Mail von michael.fischer@fau.de vom 2020-03-13
#
#########################################################
#>


$RegUninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)


Get-CimInstance -ClassName 'Win32_Process' |  `
    Where-Object { $_.ExecutablePath -like '*Program Files\Java*' -or $_.ExecutablePath -like '*Program Files (x86)\Java*' } | `
    Select-Object @{n = 'Name'; e = { $_.Name.Split('.')[0] } } | Stop-Process -Force
 
Get-Process -Name *iexplore* | Stop-Process -Force -ErrorAction SilentlyContinue

$UninstallSearchFilter = { (($_.GetValue('DisplayName') -like '*Java*') -and ($_.GetValue('Publisher') -like '*Oracle*')) }

# Uninstall unwanted Java versions and clean up program files
 
foreach ($Path in $RegUninstallPaths) {
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | `
            ForEach-Object { 
           
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/uninstall $($_.PSChildName) /qn /norestart" -Wait
    
        }
    }
}

New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' | Out-Null
$ClassesRootPath = 'HKCR:\Installer\Products'
Get-ChildItem $ClassesRootPath | 
Where-Object { ($_.GetValue('ProductName') -like '*Java*') } | ForEach-Object {
    Remove-Item -Path $_.PsPath -Recurse -Force 
}

$JavaSoftPath = 'HKLM:\SOFTWARE\JavaSoft'
if (Test-Path -Path $JavaSoftPath) {
    Remove-Item -Path $JavaSoftPath -Recurse -Force 
}

Get-ChildItem -Path "${env:ProgramFiles(x86)}\Java\" -ErrorAction SilentlyContinue | `
    Where-Object { $_.PSPath -like '*jre*' } -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "${env:ProgramFiles}\Java\" -ErrorAction SilentlyContinue | `
    Where-Object { $_.PSPath -like '*jre*' } -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Remove-PSDrive -Name 'HKCR'
Remove-Variable -Name 'RegUninstallPaths' 
Remove-Variable -Name 'Path' 
Remove-Variable -Name 'JavaSoftPath' 
Remove-Variable -Name 'ClassesRootPath' 
Remove-Variable -Name 'UninstallSearchFilter' 

# SIG # Begin signature block
# MIIqkwYJKoZIhvcNAQcCoIIqhDCCKoACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAOXahsRCeTZS0W
# 9neuMgCZZJVi8nx0aDQt2TrxMZiJLKCCI3QwggPDMIICq6ADAgECAgEBMA0GCSqG
# SIb3DQEBCwUAMIGCMQswCQYDVQQGEwJERTErMCkGA1UECgwiVC1TeXN0ZW1zIEVu
# dGVycHJpc2UgU2VydmljZXMgR21iSDEfMB0GA1UECwwWVC1TeXN0ZW1zIFRydXN0
# IENlbnRlcjElMCMGA1UEAwwcVC1UZWxlU2VjIEdsb2JhbFJvb3QgQ2xhc3MgMjAe
# Fw0wODEwMDExMDQwMTRaFw0zMzEwMDEyMzU5NTlaMIGCMQswCQYDVQQGEwJERTEr
# MCkGA1UECgwiVC1TeXN0ZW1zIEVudGVycHJpc2UgU2VydmljZXMgR21iSDEfMB0G
# A1UECwwWVC1TeXN0ZW1zIFRydXN0IENlbnRlcjElMCMGA1UEAwwcVC1UZWxlU2Vj
# IEdsb2JhbFJvb3QgQ2xhc3MgMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAKpf2htf6HOR5dpc9KLmR+XzaFVgBR0CpLObWfMeiq80rfwNwtlIGe5pj8kg
# /CGqBxntsFysZcdf7QJ8e3wtG9a6uYDCGIIWhPpmsAjGVCOB5M25ST/2T243SCg4
# D8W+52hw/TmXTdLHmJFQqsREsyN9OUfpUmLWEpNetzGWQgX7dqceo/XC/Ol6xWyp
# cU/qy3i8YK/H3vTZy75+M6VulIPwNPohq+qOcqA/pN4wW++GTWqVW0NEqBAVHOUB
# V8WY8eYGKJGqIMW3UyZRQ7ILEZVY4cAPdtnAjXyB83Jwnm/+Go7ZXzXGsm80fL5I
# T+JaOdfYnXien4Y+A14Zi0Si1ccCAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAO
# BgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFL9ZIDYAeaCgImuM1fJh0rgsy4JKMA0G
# CSqGSIb3DQEBCwUAA4IBAQAxA6JhCx906HI2xm35TZ76IqjhgVbPzbuf6quRGTiv
# qnwVTfO2o42l9I72RKmn6CGVrT4AYhaI8AK6/GEj5jObMHprNmJ7rQQjhFhl4tsr
# iuclUzdiU1+82gFiKaKmJ3HmOiJ+wW8dlXAgSgc03+r/FYDlutd62Ft1fAV6KUd+
# QKgxE3fNQDu0UUd6LhHjRxHenWbQi9VUZvqDVep8wimJG+lvs87iBYTJLz54hWJu
# yV/BeGN0WMBIGAyZOeukzBq1eVqNFZzYFA32egdXxyKDBS08myUmPRizqUN8yMir
# ZI8Oo7+cG50w29rQGS6qPPH7M4B25M2tGU8FJ44ToW7CMIIFEjCCA/qgAwIBAgIJ
# AOML1fivJdmBMA0GCSqGSIb3DQEBCwUAMIGCMQswCQYDVQQGEwJERTErMCkGA1UE
# CgwiVC1TeXN0ZW1zIEVudGVycHJpc2UgU2VydmljZXMgR21iSDEfMB0GA1UECwwW
# VC1TeXN0ZW1zIFRydXN0IENlbnRlcjElMCMGA1UEAwwcVC1UZWxlU2VjIEdsb2Jh
# bFJvb3QgQ2xhc3MgMjAeFw0xNjAyMjIxMzM4MjJaFw0zMTAyMjIyMzU5NTlaMIGV
# MQswCQYDVQQGEwJERTFFMEMGA1UEChM8VmVyZWluIHp1ciBGb2VyZGVydW5nIGVp
# bmVzIERldXRzY2hlbiBGb3JzY2h1bmdzbmV0emVzIGUuIFYuMRAwDgYDVQQLEwdE
# Rk4tUEtJMS0wKwYDVQQDEyRERk4tVmVyZWluIENlcnRpZmljYXRpb24gQXV0aG9y
# aXR5IDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDLYNf/ZqFBzdL6
# h5eKc6uZTepnOVqhYIBHFU6MlbLlz87TV0uNzvhWbBVVdgfqRv3IA0VjPnDUq1SA
# sSOcvjcoqQn/BV0YD8SYmTezIPZmeBeHwp0OzEoy5xadrg6NKXkHACBU3BVfSpbX
# eLY008F0tZ3pv8B3Teq9WQfgWi9sPKUA3DW9ZQ2PfzJt8lpqS2IB7qw4NFlFNkkF
# 2njKam1bwIFrEczSPKiL+HEayjvigN0WtGd6izbqTpEpPbNRXK2oDL6dNOPRDReD
# dcQ5HrCUCxLx1WmOJfS4PSu/wI7DHjulv1UQqyquF5deM87I8/QJB+MChjFGawHF
# EAwRx1npAgMBAAGjggF0MIIBcDAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFJPj
# 2DIm2tXxSqWRSuDqS+KiDM/hMB8GA1UdIwQYMBaAFL9ZIDYAeaCgImuM1fJh0rgs
# y4JKMBIGA1UdEwEB/wQIMAYBAf8CAQIwMwYDVR0gBCwwKjAPBg0rBgEEAYGtIYIs
# AQEEMA0GCysGAQQBga0hgiweMAgGBmeBDAECAjBMBgNVHR8ERTBDMEGgP6A9hjto
# dHRwOi8vcGtpMDMzNi50ZWxlc2VjLmRlL3JsL1RlbGVTZWNfR2xvYmFsUm9vdF9D
# bGFzc18yLmNybDCBhgYIKwYBBQUHAQEEejB4MCwGCCsGAQUFBzABhiBodHRwOi8v
# b2NzcDAzMzYudGVsZXNlYy5kZS9vY3NwcjBIBggrBgEFBQcwAoY8aHR0cDovL3Br
# aTAzMzYudGVsZXNlYy5kZS9jcnQvVGVsZVNlY19HbG9iYWxSb290X0NsYXNzXzIu
# Y2VyMA0GCSqGSIb3DQEBCwUAA4IBAQCHC/8+AptlyFYt1juamItxT9q6Kaoh+UYu
# 9bKkD64ROHk4sw50unZdnugYgpZi20wz6N35at8yvSxMR2BVf+d0a7Qsg9h5a7a3
# TVALZge17bOXrerufzDmmf0i4nJNPoRb7vnPmep/11I5LqyYAER+aTu/de7QCzsa
# zeX3DyJsR4T2pUeg/dAaNH2t0j13s+70103/w+jlkk9ZPpBHEEqwhVjAb3/4ru0I
# Qp4e1N8ULk2PvJ6Uw+ft9hj4PEnnJqinNtgs3iLNi4LY2XjiVRKjO4dEthEL1QxS
# r2mMDwbf0KJTi1eYe8/9ByT0/L3D/UqSApcb8re2z2WKGqK1chk5MIIFrDCCBJSg
# AwIBAgIHG2O60B4sPTANBgkqhkiG9w0BAQsFADCBlTELMAkGA1UEBhMCREUxRTBD
# BgNVBAoTPFZlcmVpbiB6dXIgRm9lcmRlcnVuZyBlaW5lcyBEZXV0c2NoZW4gRm9y
# c2NodW5nc25ldHplcyBlLiBWLjEQMA4GA1UECxMHREZOLVBLSTEtMCsGA1UEAxMk
# REZOLVZlcmVpbiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAyMB4XDTE2MDUyNDEx
# Mzg0MFoXDTMxMDIyMjIzNTk1OVowgY0xCzAJBgNVBAYTAkRFMUUwQwYDVQQKDDxW
# ZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1dHNjaGVuIEZvcnNjaHVuZ3Nu
# ZXR6ZXMgZS4gVi4xEDAOBgNVBAsMB0RGTi1QS0kxJTAjBgNVBAMMHERGTi1WZXJl
# aW4gR2xvYmFsIElzc3VpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCdO3kcR94fhsvGadcQnjnX2aIw23IcBX8pX0to8a0Z1kzhaxuxC3+hq+B7
# i4vYLc5uiDoQ7lflHn8EUTbrunBtY6C+li5A4dGDTGY9HGRp5ZukrXKuaDlRh3nM
# F9OuL11jcUs5eutCp5eQaQW/kP+kQHC9A+e/nhiIH5+ZiE0OR41IX2WZENLZKknt
# wbktHZ8SyxXTP38eVC86rpNXp354ytVK4hrl7UF9U1/Isyr1ijCs7RcFJD+2oAsH
# /U0amgNSoDac3iSHZeTn+seWcyQUzdDoG2ieGFmudn730Qp4PIdLsDfPU8o6OBDz
# y0dtjGQ9PFpFSrrKgHy48+enTEzNAgMBAAGjggIFMIICATASBgNVHRMBAf8ECDAG
# AQH/AgEBMA4GA1UdDwEB/wQEAwIBBjApBgNVHSAEIjAgMA0GCysGAQQBga0hgiwe
# MA8GDSsGAQQBga0hgiwBAQQwHQYDVR0OBBYEFGs6mIv58lOJ2uCtsjIeCR/oqjt0
# MB8GA1UdIwQYMBaAFJPj2DIm2tXxSqWRSuDqS+KiDM/hMIGPBgNVHR8EgYcwgYQw
# QKA+oDyGOmh0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvZ2xvYmFsLXJvb3QtZzItY2Ev
# cHViL2NybC9jYWNybC5jcmwwQKA+oDyGOmh0dHA6Ly9jZHAyLnBjYS5kZm4uZGUv
# Z2xvYmFsLXJvb3QtZzItY2EvcHViL2NybC9jYWNybC5jcmwwgd0GCCsGAQUFBwEB
# BIHQMIHNMDMGCCsGAQUFBzABhidodHRwOi8vb2NzcC5wY2EuZGZuLmRlL09DU1At
# U2VydmVyL09DU1AwSgYIKwYBBQUHMAKGPmh0dHA6Ly9jZHAxLnBjYS5kZm4uZGUv
# Z2xvYmFsLXJvb3QtZzItY2EvcHViL2NhY2VydC9jYWNlcnQuY3J0MEoGCCsGAQUF
# BzAChj5odHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1
# Yi9jYWNlcnQvY2FjZXJ0LmNydDANBgkqhkiG9w0BAQsFAAOCAQEAgXhFpE6kfw5V
# 8Amxaj54zGg1qRzzlZ4/8/jfazh3iSyNta0+x/KUzaAGrrrMqLGtMwi2JIZiNkx4
# blDw1W5gjU9SMUOXRnXwYuRuZlHBQjFnUOVJ5zkey5/KhkjeCBT/FUsrZpugOJ8A
# zv2n69F/Vy3ITF/cEBGXPpYEAlyEqCk5bJT8EJIGe57u2Ea0G7UDDDjZ3LCpP3EG
# C7IDBzPCjUhjJSU8entXbveKBTjvuKCuL/TbB9VbhBjBqbhLzmyQGoLkuT36d/HS
# HzMCv1PndvncJiVBby+mG/qkE5D6fH7ZC2Bd7L/KQaBh+xFJKdioLXUV2EoY6hbv
# VTQiGhONBjCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcN
# AQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3Rl
# ZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8Ty
# kTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsm
# c5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTn
# KC3r07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2
# R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0
# QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/
# oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1ps
# lPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhI
# fxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8
# I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkU
# EBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1G
# nrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEA
# MB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC
# 0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSG
# Mmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0B
# AQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7
# cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2p
# Vs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxk
# Jodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpkn
# G6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2
# n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fm
# w0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvt
# Cl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU
# 5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8K
# vYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/
# GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbGMIIE
# rqADAgECAhAKekqInsmZQpAGYzhNhpedMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcN
# MjIwMzI5MDAwMDAwWhcNMzMwMzE0MjM1OTU5WjBMMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFt
# cCAyMDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALkqliOm
# XLxf1knwFYIY9DPuzFxs4+AlLtIx5DxArvurxON4XX5cNur1JY1Do4HrOGP5PIhp
# 3jzSMFENMQe6Rm7po0tI6IlBfw2y1vmE8Zg+C78KhBJxbKFiJgHTzsNs/aw7ftwq
# HKm9MMYW2Nq867Lxg9GfzQnFuUFqRUIjQVr4YNNlLD5+Xr2Wp/D8sfT0KM9CeR87
# x5MHaGjlRDRSXw9Q3tRZLER0wDJHGVvimC6P0Mo//8ZnzzyTlU6E6XYYmJkRFMUr
# DKAz200kheiClOEvA+5/hQLJhuHVGBS3BEXz4Di9or16cZjsFef9LuzSmwCKrB2N
# O4Bo/tBZmCbO4O2ufyguwp7gC0vICNEyu4P6IzzZ/9KMu/dDI9/nw1oFYn5wLOUr
# sj1j6siugSBrQ4nIfl+wGt0ZvZ90QQqvuY4J03ShL7BUdsGQT5TshmH/2xEvkgMw
# zjC3iw9dRLNDHSNQzZHXL537/M2xwafEDsTvQD4ZOgLUMalpoEn5deGb6GjkagyP
# 6+SxIXuGZ1h+fx/oK+QUshbWgaHK2jCQa+5vdcCwNiayCDv/vb5/bBMY38ZtpHlJ
# rYt/YYcFaPfUcONCleieu5tLsuK2QT3nr6caKMmtYbCgQRgZTu1Hm2GV7T4LYVrq
# PnqYklHNP8lE54CLKUJy93my3YTqJ+7+fXprAgMBAAGjggGLMIIBhzAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAg
# BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZ
# bU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFI1kt4kh/lZYRIRhp+pvHDaP3a8N
# MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAG
# CCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQw
# DQYJKoZIhvcNAQELBQADggIBAA0tI3Sm0fX46kuZPwHk9gzkrxad2bOMl4IpnENv
# AS2rOLVwEb+EGYs/XeWGT76TOt4qOVo5TtiEWaW8G5iq6Gzv0UhpGThbz4k5HXBw
# 2U7fIyJs1d/2WcuhwupMdsqh3KErlribVakaa33R9QIJT4LWpXOIxJiA3+5Jlbez
# zMWn7g7h7x44ip/vEckxSli23zh8y/pc9+RTv24KfH7X3pjVKWWJD6KcwGX0ASJl
# x+pedKZbNZJQfPQXpodkTz5GiRZjIGvL8nvQNeNKcEiptucdYL0EIhUlcAZyqUQ7
# aUcR0+7px6A+TxC5MDbk86ppCaiLfmSiZZQR+24y8fW7OK3NwJMR1TJ4Sks3Kkzz
# XNy2hcC7cDBVeNaY/lRtf3GpSBp43UZ3Lht6wDOK+EoojBKoc88t+dMj8p4Z4A2U
# KKDr2xpRoJWCjihrpM6ddt6pc6pIallDrl/q+A8GQp3fBmiW/iqgdFtjZt5rLLh4
# qk1wbfAs8QcVfjW05rUMopml1xVrNQ6F1uAszOAMJLh8UgsemXzvyMjFjFhpr6s9
# 4c/MfRWuFL+Kcd/Kl7HYR+ocheBFThIcFClYzG/Tf8u+wQ5KbyCcrtlzMlkI5y2S
# oRoR/jKYpl0rl+CL05zMbbUNrkdjOEcXW28T2moQbh9Jt0RbtAgKh1pZBHYRoad3
# AhMcMIIHZzCCBk+gAwIBAgIMJgTtaoYGmKtMjK/2MA0GCSqGSIb3DQEBCwUAMIGN
# MQswCQYDVQQGEwJERTFFMEMGA1UECgw8VmVyZWluIHp1ciBGb2VyZGVydW5nIGVp
# bmVzIERldXRzY2hlbiBGb3JzY2h1bmdzbmV0emVzIGUuIFYuMRAwDgYDVQQLDAdE
# Rk4tUEtJMSUwIwYDVQQDDBxERk4tVmVyZWluIEdsb2JhbCBJc3N1aW5nIENBMB4X
# DTIyMDExNzEzMzIxM1oXDTI1MDExNjEzMzIxM1owgdExCzAJBgNVBAYTAkRFMQ8w
# DQYDVQQIDAZCYXllcm4xETAPBgNVBAcMCEVybGFuZ2VuMTwwOgYDVQQKDDNGcmll
# ZHJpY2gtQWxleGFuZGVyLVVuaXZlcnNpdGFldCBFcmxhbmdlbi1OdWVybmJlcmcx
# DTALBgNVBAsMBEZBUFMxJTAjBgNVBEEMHE1pY2hhZWwgTWFzdWNoIC0gQ29kZVNp
# Z25pbmcxKjAoBgNVBAMMIVBOIC0gTWljaGFlbCBNYXN1Y2ggLSBDb2RlU2lnbmlu
# ZzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANXtZP6ekfKLExpY3jYp
# 9p5W7QTpYmvsq4lbqO9mnvvXvQw6vwDlvaNd0D9yPiF6sCYdL3rIXStc7v/lRB+x
# gsfYJo/fvTOX7GLSBQQzPZ/XWtvFw5XTb6C5qQ+iBEukVXzP8gSphNiV2hvyuGE5
# F2PCOJOPPAbFeT/ZST3QglacmYfijYvWasbUzW+sqyeMgIeP47nTrC8HItU/VH9W
# 2F3Brg5EU9h6DdUzCjhb8KhgApoGjTCHcAtVhvwv6XW6uBNSvOGqECK+7L8I5oky
# aEnNpNOaykQUO6iBtH1yzXLnPNx7pDYsV8GbZxB7LFlVyJJcm5vfklju3UDRNgka
# Ug39yttxNHjQVdQRrhR7Q/uXHPL9bqL9Gfp9x4yheTVTyhyOhY9ncKDorunDqykV
# gIIBT/uBH4kNfLTALO5ujctsuMbz10TATFDRSRZyvmi2NGZtWGiRoT732JYnlTrg
# 3O7UWZ4vVH3MSWU7wUIECfDTQBhMh9ikhUhFCkFlOjSDppywvXat/zoQtS2F1t8W
# jWSFN0CrE2xr8VYizFiaJBkfk7pAR4XUcVS0QLa47l6eezITL/fprmD2ogfyGeUL
# zVYA9qsBblXkKpP3dtfBeCx0ggTZOEDdjbEOTdYoneQEr+X61EmNFa7P6UbNLz5p
# NJ8m7V/S4o4346Kp7ZJP7bohAgMBAAGjggJ/MIICezA+BgNVHSAENzA1MA8GDSsG
# AQQBga0hgiwBAQQwEAYOKwYBBAGBrSGCLAEBBAowEAYOKwYBBAGBrSGCLAIBBAow
# CQYDVR0TBAIwADAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# HQYDVR0OBBYEFKTu4u2mMJzXq0QFLH7OEemfKkwgMB8GA1UdIwQYMBaAFGs6mIv5
# 8lOJ2uCtsjIeCR/oqjt0MFsGA1UdEQRUMFKBGm1pY2hhZWwubWFzdWNoQGZhcHMu
# ZmF1LmRlgRVtaWNoYWVsLm1hc3VjaEBmYXUuZGWBHW1pbWFzdWNoQGZhcHMudW5p
# LWVybGFuZ2VuLmRlMIGNBgNVHR8EgYUwgYIwP6A9oDuGOWh0dHA6Ly9jZHAxLnBj
# YS5kZm4uZGUvZGZuLWNhLWdsb2JhbC1nMi9wdWIvY3JsL2NhY3JsLmNybDA/oD2g
# O4Y5aHR0cDovL2NkcDIucGNhLmRmbi5kZS9kZm4tY2EtZ2xvYmFsLWcyL3B1Yi9j
# cmwvY2FjcmwuY3JsMIHbBggrBgEFBQcBAQSBzjCByzAzBggrBgEFBQcwAYYnaHR0
# cDovL29jc3AucGNhLmRmbi5kZS9PQ1NQLVNlcnZlci9PQ1NQMEkGCCsGAQUFBzAC
# hj1odHRwOi8vY2RwMS5wY2EuZGZuLmRlL2Rmbi1jYS1nbG9iYWwtZzIvcHViL2Nh
# Y2VydC9jYWNlcnQuY3J0MEkGCCsGAQUFBzAChj1odHRwOi8vY2RwMi5wY2EuZGZu
# LmRlL2Rmbi1jYS1nbG9iYWwtZzIvcHViL2NhY2VydC9jYWNlcnQuY3J0MA0GCSqG
# SIb3DQEBCwUAA4IBAQBssTheCDKuB0VdQDl4L3jaKuP5JJKz2TdAxKoQtRA7t5kw
# aaMKW98Sl78IZuo7WkUKj1CkCmJNTH1QqM6Qlq/eP5eWjejh+KH/q2fkVYyMm76A
# fOPcz42DSaMTxVIcfOChOnLhdJtsrMjtsL55ayFtuVfj/iOrKLcC0rswoStXV7C6
# +cU9uBWjQDOYOJJ8tuB8uIdLbgX4Gj10cgmqOaJNQVdz+V4QKmg7utiYwK8lmmpb
# Cy17oo2SrNsRiUwCAzPM+LrZxqzXufpGAHKzHxY18FogR3HcqCmW4tVV2Zow8eyl
# F6chV5w060EyAqfwbpzudw9mI/qpiHkTnlPBGncdMYIGdTCCBnECAQEwgZ4wgY0x
# CzAJBgNVBAYTAkRFMUUwQwYDVQQKDDxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWlu
# ZXMgRGV1dHNjaGVuIEZvcnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsMB0RG
# Ti1QS0kxJTAjBgNVBAMMHERGTi1WZXJlaW4gR2xvYmFsIElzc3VpbmcgQ0ECDCYE
# 7WqGBpirTIyv9jANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCDbdVKOefYIAejHTWvJ7rpF
# f5/f/S2SKu32irn+eBBDJDANBgkqhkiG9w0BAQEFAASCAgAHup/4MQ2gPKR2i42Q
# zZi5wuUSPGZ24Uecq8YSlombRH+o6YyyFw0Jpvij3zPqWLeS71K2Wf0xb5WPqiHa
# t40ZPwqm76uOn+um8jirfhV8wcr7j8/fjxrMjxrHpyPEsRA4CHev+W+7u6OIvazB
# GJdjTOLprk8O64IYS20hnOdQ2ut4LzhX56OJx+l/cNFPO7W79lRvCaCQ8pIl+u7/
# PP4SsSqhaz2UnATROfmwYyXfGdU/Gb3s64Mv0Ppe0QhkS29j0sVB2fSLtL64xMqo
# 8qULE2dHMa9IbTVDvwxeuMjChBYmbi0/ot/A3zqlsBB9BuQj6z3QmfciM4e5bOXt
# VKevVmRVCErMj0+b79qxwf+UODbocqOlNyuEWUIxZ255aJOVUqQToAVZS7M0t9fJ
# mMTS+2If6Lqwu0qU4CTa99Q2pHlSrV8UxZFDDOe3yMStjTq/MKWK0y4lNwTtcrPV
# JA4sSNeoF2K69pPn3RPgV1lQIlahC9kTAv/gXfNKMEmz3osiWo5g/6MEEybIldGN
# b16oRzQfvr1jcqWi4Henvyczg4iZfOabbu0ko2GUvNTHS6Z8uRQ/nopL+0n+CDFg
# QeclfgJQznBt9u+VUDyzlC/zmu2NeZNgh3nmDZ7qgWnpB4QrdC+sLl/HLZxi8Sbc
# LNzld00bYVGQk7MUZzhoY/50zaGCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIB
# ATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCgaTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA1MTExMTI1
# NDVaMC8GCSqGSIb3DQEJBDEiBCAlIJobVUm62wslv2jhSFMNw1TBYGGAmMRwxhKq
# A6Em+jANBgkqhkiG9w0BAQEFAASCAgB2M9AyDWHhJ68N46Eu/Nkar0xJG4uSKzgD
# gPwfLBKxZIbRsmWmiyomcSin2KyYHH8CFVv8854fJI6gvI3OLxBTcj2RCvyVoRyw
# iEFn3n0JjjtyEN4pCgaGKrIIPP/DUKF+cy01/pE4FgH2abU9rbxR1YpytiX8UW05
# azV9q8f/lwNKhST+GYg0GjwDRB4sUAhAiYrUsIizxcC6Qc3tq45GEvo1ap2/3S1S
# TSxELrT3DDsXQUueERXTFucaA8Nyb+Dj8g4k7IYNRgKOeLtESRXUjzjWo8zJExoF
# F38CBIXBtzK4eZhNYfwkU1S1DwKSHDChKQ8ZIDSm8rWQm5vZw2aMqRXXwT+jCwfx
# PKOoaDO03wD1UGzxr93P3kQGynXs8JK43wj+NarqdqbLywbtHZXiwt/B9HCf6yPt
# gL7VgHPK0X8feZkMLg8QR7YJHHHNDbyigW3u85AOm1jUCIQQ0e/+x5dcGPf9iWIp
# 0Vk+tys014+7m/dCW5Dqr7ClI+0WTZmb8RFdC4Yb38r6Hv1bMHA1BKpzxXtGGVDR
# 2GM+HDwPt4DyifcexZ4G1yyo0CwVBTbLRc51eudfUbBSl/TMrVWcKgtcINZCOPYZ
# 2rwGTdtYhxCKB2xfTl4OFeb6HFgdiVviZQjxXtsRmMbKygz+H6Rb2INNfFVWGlaD
# xze1N6Jw/Q==
# SIG # End signature block
