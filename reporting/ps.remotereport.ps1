# Please replace these entries: $REPLACE

############################# CSS #############################

$px_head = @"
<title>PowerShell Report</title>

<style>

*{font-family: sans-serif; font-size: 20px; width: calc(100% - 2px); padding: 0px; margin: 0px; text-align: left; border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
table{height: 100%;}
tr{height: 40px;}

</style>
"@

####################### Basic functions #######################

cls
$px_time = Get-Date -Format yyyy-MM-dd-hh:mm:ss
$px_report = @()

##################### variable definition #####################

# example: $Global:px_from = "Sender <sender@domain.com>"
$Global:px_from = $REPLACE
# example: $Global:px_to = "Receipient <receipient@domain.com>"
$Global:px_to = $REPLACE

#mfr
# get DNS-Domain
$px_dnsdomain = (Get-WmiObject Win32_ComputerSystem).Domain
$Global:px_subject = "PowerShell report from $env:COMPUTERNAME.$px_dnsdomain"

#$Global:px_subject = "PowerShell report from $env:USERDNSDOMAIN"
$Global:px_body = "There is a new PowerShell report from $env:COMPUTERNAME.$env:USERDNSDOMAIN. $Global:px_time"

$Global:px_smtpserver = $REPLACE
$Global:px_smtpport = $REPLACE

$px_user = $REPLACE
$px_pword = ConvertTo-SecureString –String $REPLACE –AsPlainText -Force
$Global:px_cred = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $px_user, $px_pword

###############################################################

function px-send
{

    Send-MailMessage -from $Global:px_from -to $Global:px_to -Subject $Global:px_subject -Body $Global:px_body -SmtpServer $Global:px_smtpserver -port $Global:px_smtpport -UseSsl -Credential $Global:px_cred -Attachments $Global:px_attachment

}

$Global:px_report_table = “PowerShell Report”

#Create Table object
$Global:px_table = New-Object system.Data.DataTable “$Global:px_report_table”

#Define Columns
$Global:px_col1 = New-Object system.Data.DataColumn Date,([string])
$Global:px_col2 = New-Object system.Data.DataColumn Computer,([string])
$Global:px_col3 = New-Object system.Data.DataColumn LastBoot,([string])
$Global:px_col4 = New-Object system.Data.DataColumn HDDDevice,([string])
$Global:px_col5 = New-Object system.Data.DataColumn HDDFree,([string])
$Global:px_col6 = New-Object system.Data.DataColumn HDDSize,([string])
$Global:px_col7 = New-Object system.Data.DataColumn RAMFree,([string])
$Global:px_col8 = New-Object system.Data.DataColumn RAMSize,([string])


#Add the Columns
$Global:px_table.columns.add($Global:px_col1)
$Global:px_table.columns.add($Global:px_col2)
$Global:px_table.columns.add($Global:px_col3)
$Global:px_table.columns.add($Global:px_col4)
$Global:px_table.columns.add($Global:px_col5)
$Global:px_table.columns.add($Global:px_col6)
$Global:px_table.columns.add($Global:px_col7)
$Global:px_table.columns.add($Global:px_col8)

$px_srv = Get-Content -Path .\srv.list.txt
foreach($srv in $px_srv){

    $Global:px_device = Get-WmiObject Win32_LogicalDisk -Filter "DriveType='3'" -ComputerName $srv
    $Global:px_device = $Global:px_device.DeviceID

    $Global:px_free = Get-WmiObject Win32_LogicalDisk -Filter "DriveType='3'" -ComputerName $srv | ForEach-Object {$_.freespace / 1GB}
    $Global:px_free = $Global:px_free | ForEach-Object {[math]::Round($_)}

    $Global:px_size = Get-WmiObject Win32_LogicalDisk -Filter "DriveType='3'" -ComputerName $srv | ForEach-Object {$_.Size / 1GB}
    $Global:px_size = $Global:px_size | ForEach-Object {[math]::Round($_)}

    $Global:px_boot = Get-WmiObject -computername $srv -Class Win32_OperatingSystem
    $Global:px_boot = [Management.ManagementDateTimeConverter]::ToDateTime($Global:px_boot.LastBootUpTime)    
    $Global:px_boot = Get-Date $Global:px_boot -Format yyyy-MM-dd-hh:mm

    $Global:px_mem = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $srv | ForEach-Object {$_.FreePhysicalMemory / 1024 / 1024}
    $Global:px_mem = $Global:px_mem | ForEach-Object {[math]::Round($_)}

    $Global:px_mem_size = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $srv | ForEach-Object {$_.TotalVisibleMemorySize / 1024 / 1024}
    $Global:px_mem_size = $Global:px_mem_size | ForEach-Object {[math]::Round($_)}

    #Create a row
    $Global:px_row = $Global:px_table.NewRow()

    #Enter data in the row
    $Global:px_row.Date = Get-Date -Format yyyy-MM-dd
    $Global:px_row.Computer = $srv
    $Global:px_row.LastBoot = [string]$Global:px_boot
    $Global:px_row.HDDDevice = [string]$Global:px_device
    $Global:px_row.HDDFree =  [string]$Global:px_free
    $Global:px_row.HDDSize = [string]$Global:px_size
    $Global:px_row.RAMFree = [string]$Global:px_mem
    $Global:px_row.RAMSize = [string]$Global:px_mem_size

    #Add the row to the table
    $Global:px_table.Rows.Add($Global:px_row)

}

#Display the table
cls
$Global:px_table | Select-Object Date, Computer, LastBoot, HDDDevice, HDDFree, HDDSize, RAMFree, RAMSize | ConvertTo-Html -Head $px_head | set-content .\$($px_row.Date)_report.htm
$Global:px_attachment = ".\$($px_row.Date)_report.htm"

px-send
