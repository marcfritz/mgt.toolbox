cls
$px_time = Read-Host "Time to restart computer (Example: 1500)"

do{
    
    Start-Sleep -Seconds 2
    cls
    $px_now = Get-Date -Format HHmm

    Write-Host "[Info] Current time is:" $px_now -ForegroundColor Green
    Write-Host "[Info] Wait until time equals:" $px_time -ForegroundColor Green

}Until($px_now -eq $px_time)

cls

$px_srv = Get-Content -Path .\srv.list.txt

foreach($srv in $px_srv){

    Restart-Computer -ComputerName $srv -Force

}

Write-Host "[Info] Restart process successful" -ForegroundColor Green
