cls

$px_srv = Get-Content -Path .\srv.list.txt

foreach($srv in $px_srv){
    
    Write-Host "------------ $srv ------------" -ForegroundColor White
    Get-WmiObject win32_service -ComputerName $srv | Where-Object -FilterScript { $_.state -ne "Running" -and $_.StartMode -eq "Auto" } | Select-Object name, startmode, state, status | Format-Table
}

Write-Host "[Info] Service check successful" -ForegroundColor Green
