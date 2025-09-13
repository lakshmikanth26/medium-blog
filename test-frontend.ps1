# Test script for frontend functionality
param(
    [switch]$Test
)

function Test-Frontend {
    Write-Host "Testing Frontend Setup..." -ForegroundColor Blue
    
    Write-Host "Current directory: $(Get-Location)"
    Write-Host "Frontend directory exists: $(Test-Path 'frontend')"
    
    if (Test-Path "frontend") {
        Write-Host "Navigating to frontend directory..."
        Push-Location "frontend"
        Write-Host "Now in directory: $(Get-Location)"
        
        Write-Host "Testing npm command..."
        try {
            $npmVersion = & npm --version
            Write-Host "npm version: $npmVersion" -ForegroundColor Green
        }
        catch {
            Write-Host "Error running npm: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Pop-Location
    } else {
        Write-Host "Frontend directory not found!" -ForegroundColor Red
    }
}

if ($Test) {
    Test-Frontend
} else {
    Write-Host "Usage: .\test-frontend.ps1 -Test"
}
