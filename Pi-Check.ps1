$ErrorActionPreference = "SilentlyContinue"
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "   Generating Pi Node Dashboard...     " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Set save paths
$HtmlFile = "$env:TEMP\pi_dashboard.html"
# Save "pi_node_results.txt" in the same folder as this script
$TxtFile  = "$PSScriptRoot\basic_info.txt"

# 1. Execute commands and capture outputs
$wsl  = (wsl -l -v 2>&1) -join "`n"
$dps  = (docker ps -a 2>&1) -join "`n"
$dver = (docker version 2>&1) -join "`n"
$dst  = (docker exec testnet2 stellar-core http-command info 2>&1) -join "`n"

# 2. Define Clean HTML Template
$template = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pi Node Dashboard</title>
    <style>
        body { font-family: -apple-system, sans-serif; background-color: #f4f6f9; color: #333; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; }
        h1 { color: #2c3e50; font-size: 24px; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        .command-section { background: #fff; border-radius: 8px; margin-bottom: 25px; border: 1px solid #e1e4e8; overflow: hidden; }
        .command-header { background-color: #f8f9fa; padding: 12px 20px; font-weight: bold; display: flex; justify-content: space-between; align-items: center; }
        .command-title { font-family: monospace; color: #2980b9; font-size: 15px; }
        .status-badge { padding: 3px 8px; border-radius: 12px; font-size: 12px; color: white; background-color: #2ecc71; }
        .terminal { background-color: #1e1e1e; color: #f1f1f1; padding: 18px; margin: 0; font-family: 'Consolas', monospace; font-size: 14px; line-height: 1.5; overflow-x: auto; white-space: pre-wrap; }
        .prompt { color: #3498db; }
    </style>
</head>
<body>
<div class="container">
    <h1>Pi Node System Status (Local Scan)</h1>
    <div class="command-section">
        <div class="command-header"><span class="command-title"><span class="prompt">&gt;</span> wsl -l -v</span><span class="status-badge">Success</span></div>
        <pre class="terminal">_WSL_</pre>
    </div>
    <div class="command-section">
        <div class="command-header"><span class="command-title"><span class="prompt">&gt;</span> docker ps -a</span><span class="status-badge">Success</span></div>
        <pre class="terminal">_DPS_</pre>
    </div>
    <div class="command-section">
        <div class="command-header"><span class="command-title"><span class="prompt">&gt;</span> docker version</span><span class="status-badge">Success</span></div>
        <pre class="terminal">_DVER_</pre>
    </div>
    <div class="command-section">
        <div class="command-header"><span class="command-title"><span class="prompt">&gt;</span> docker exec testnet2 stellar-core http-command info</span><span class="status-badge">Success</span></div>
        <pre class="terminal">_DST_</pre>
    </div>
</div>
</body>
</html>
'@

# 3. Replace Placeholders and Save HTML
$html = $template.Replace('_WSL_', $wsl).Replace('_DPS_', $dps).Replace('_DVER_', $dver).Replace('_DST_', $dst)
[System.IO.File]::WriteAllText($HtmlFile, $html, [System.Text.Encoding]::UTF8)

# 4. Export all results into a single report text file
$textContent = @"
=======================================
Pi Node Local Scan Report
Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
=======================================

> wsl -l -v
---------------------------------------
$wsl

> docker ps -a
---------------------------------------
$dps

> docker version
---------------------------------------
$dver

> docker exec testnet2 stellar-core http-command info
---------------------------------------
$dst
"@
[System.IO.File]::WriteAllText($TxtFile, $textContent, [System.Text.Encoding]::UTF8)

# 5. Open in default browser
Start-Process $HtmlFile
