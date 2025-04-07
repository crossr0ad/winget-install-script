Param (
    [string]$Manifest = "$PSScriptRoot/packages.json"
)

function Main {
    $packages = (Get-Content $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json).packages
    $packages | Foreach-Object { Install-Package $_ }
    Write-Host "winget install が終了しました"
}

function Install-Package {
    param (
        $Package
    )
    begin {
        $index = 0
    }
    process {
        Write-Host "($index) Processing $($Package.id)..."

        if ($Package.disabled) {
            Write-Host "'disabled' が設定されているので、スキップします"
            Write-Host
            return
        }

        if ($Package.skip_install) {
            Write-Host "'skip_install' が設定されているので、インストールをスキップします"
        }
        else {
            if ($Package.device -and $env:COMPUTERNAME -notin $Package.device) {
                Write-Host "'device' で指定されているデバイスなので、インストールをスキップします"
            }
            else {
                # Use Invoke-Expression to handle $Package.option
                $command = "winget install -e --id $($Package.id) $($Package.option -join " ") --accept-package-agreements --accept-source-agreements"
                if ($Package.pin) {
                    $command += " --no-upgrade"
                }
                Write-Host "Executing '$command'..."

                Invoke-Expression $command
            }
        }

        if ($Package.pin) {
            Write-Host "ピンを設定しています…"
            winget pin add -e --id $Package.id --blocking
        }
        else {
            Write-Host "ピンを除去しています…"
            winget pin remove -e --id $Package.id
        }

        Write-Host
        $index += 1
    }
}

Main
