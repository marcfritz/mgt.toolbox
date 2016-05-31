cls
$px_network = net view | Select-String -pattern "\\"
$px_network -replace " .*" -replace "\\", "" -replace " ", "" | Out-File .\srv.list.txt

$px_counter = $px_network.Count
cls

Write-Host "[Info] List generator was successful (Hostname counter: $px_counter)" -ForegroundColor Green
