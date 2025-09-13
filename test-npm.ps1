# Test npm start command
Push-Location "frontend"
Write-Host "Current directory: $(Get-Location)"
Write-Host "About to run npm start..."
& npm start
Pop-Location
