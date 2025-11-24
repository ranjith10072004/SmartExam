param(
    [int]$Port = 3000
)

# --- Configuration ---
$FlutterCommand = "flutter run"

# --- Function to Clean Up Processes ---
function Stop-Ngrok {
    Write-Host "`nStopping ngrok process..." -ForegroundColor Yellow
    
    # Check if ngrok process exists and stop it
    if ($global:ngrokProcess) {
        Stop-Process -Id $global:ngrokProcess.Id -Force -ErrorAction SilentlyContinue
    }
}

# --- Main Execution ---

# Ensure the script stops ngrok when interrupted (Ctrl+C)
trap {
    Stop-Ngrok
    exit 1
}

# 1. Start ngrok in the background
Write-Host "1. Starting ngrok tunnel for port $Port..." -ForegroundColor Cyan
$global:ngrokProcess = Start-Process -FilePath "ngrok" -ArgumentList "http $Port" -NoNewWindow -PassThru

# Give ngrok a few seconds to initialize and create the tunnel
Start-Sleep -Seconds 5

# 2. Query the ngrok API for the public URL
Write-Host "2. Retrieving public URL from ngrok API..." -ForegroundColor Cyan
try {
    # Ngrok exposes its management API on localhost:4040
    $NgrokResponse = Invoke-RestMethod -Uri http://localhost:4040/api/tunnels
    
    # Find the HTTPS tunnel (more secure for mobile apps)
    $NgrokTunnel = $NgrokResponse.tunnels | Where-Object { $_.proto -eq 'https' }
    $NgrokUrl = $NgrokTunnel.public_url

    if (-not $NgrokUrl) {
        throw "Could not find a valid HTTPS public URL."
    }
} catch {
    Write-Error "Failed to retrieve ngrok URL. Is ngrok installed and on your PATH, and is your backend running on port $Port?"
    Stop-Ngrok
    exit 1
}

Write-Host "   ✅ Ngrok URL retrieved: $NgrokUrl" -ForegroundColor Green
Write-Host "---"

# 3. Construct and Execute the Flutter Command
$DefineArgument = "`"BASE_URL=$NgrokUrl`""
$FullCommand = "$FlutterCommand --dart-define=$DefineArgument"

Write-Host "3. Running Flutter app with dynamic BASE_URL..." -ForegroundColor Cyan
Write-Host "   Executing: $FullCommand" -ForegroundColor DarkGray

# Execute the flutter command directly
Invoke-Expression $FullCommand

# 4. Clean up after Flutter exits
Stop-Ngrok

Write-Host "`nScript finished." -ForegroundColor Green