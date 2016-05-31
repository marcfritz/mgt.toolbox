cls

$px_path = [Environment]::GetFolderPath("Personal")
New-Item -Path $px_path\mgt.toolbox -ItemType Directory -ErrorAction SilentlyContinue

$px_url = "https://github.com/2160px/mgt.toolbox/archive/master.zip"
$px_output = "$px_path\mgt.toolbox\mgt.toolbox.zip"

Invoke-WebRequest -Uri $px_url -OutFile $px_output
