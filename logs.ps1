param (
    [int]$days = 1,
    [string]$logname = "Application",
    [string]$outputFile = "C:\temp\Event_Errors.txt",
    [string]$keyword = "",
    [int]$eventID = 0,
    [string]$csvOutput = "",
    [string]$emailRecipient = "",
    [switch]$criticalOnly,
    [switch]$interactive,
    [switch]$help,
    [string]$filterUser = ""
)

# Show help message and exit
if ($help) {
    Write-Host "`nUsage: .\logs.ps1 [options]`n" -ForegroundColor Cyan
    Write-Host "Options:"
    Write-Host "  -days <number>           Number of days to search logs (default: 1)"
    Write-Host "  -logname <name>          Log type (e.g., Application, System, Security)"
    Write-Host "  -outputFile <path>       Save output to a text file (default: C:\temp\Event_Errors.txt)"
    Write-Host "  -keyword <text>          Filter logs by a specific keyword"
    Write-Host "  -eventID <number>        Filter logs by a specific Event ID"
    Write-Host "  -csvOutput <path>        Save output to a CSV file"
    Write-Host "  -emailRecipient <email>  Send logs via email (optional)"
    Write-Host "  -criticalOnly            Show only critical system errors"
    Write-Host "  -interactive             Interactive mode (prompts for input)"
    Write-Host "  -help                    Show this help message and exit"
    Write-Host "  -filterUser <user>       Filter logs by a specific user"
    exit
}

# Interactive mode: Prompt user for input
if ($interactive) {
    $logname = Read-Host "Enter Log Name (e.g., System, Application, Security)"
    $days = Read-Host "Enter Number of Days to Search"
    $eventID = Read-Host "Enter Specific Event ID to Filter (or press Enter to skip)"
    $keyword = Read-Host "Enter a keyword to filter logs (or press Enter to skip)"
    $outputFile = Read-Host "Enter output file path (default: C:\temp\Event_Errors.txt)"
    $csvOutput = Read-Host "Enter CSV output path (or press Enter to skip)"
    $filterUser = Read-Host "Enter user to filter logs (or press Enter to skip)"
}

# Define the start time
$startTime = (Get-Date).AddDays(-$days)

# Use Get-WinEvent for all logs
try {
    $filterHash = @{
        LogName = $logname
        StartTime = $startTime
        EndTime = (Get-Date)
    }
    $events = Get-WinEvent -FilterHashtable $filterHash | Select-Object Id, TimeCreated, LevelDisplayName, ProviderName, Message, UserId, Level
} catch {
    Write-Host "Failed to retrieve events from '$logname'. Error: $_" -ForegroundColor Red
    exit 1
}

# Apply Critical or Error filter (Level 1 or 2)
if ($criticalOnly) {
    $events = $events | Where-Object { $_.Level -in 1, 2 }
}

# Apply Event ID filtering
if ($eventID -ne 0) {
    $events = $events | Where-Object { $_.Id -eq $eventID }
}

# Apply Keyword filtering
if ($keyword) {
    $events = $events | Where-Object { $_.Message -match $keyword }
}

# Apply User filtering
if ($filterUser) {
    $events = $events | Where-Object { $_.UserId -eq $filterUser }
}

# If no logs found, exit
if ($events.Count -eq 0) {
    Write-Host "No matching logs found in the last $days day(s) for '$logname' log." -ForegroundColor Green
    exit
}

# Display results
foreach ($event in $events) {
    if ($event.LevelDisplayName -eq 'Error') {
        Write-Host "$($event.TimeCreated) [ERROR] $($event.Message)" -ForegroundColor Red
    } elseif ($event.LevelDisplayName -eq 'Warning') {
        Write-Host "$($event.TimeCreated) [WARNING] $($event.Message)" -ForegroundColor Yellow
    } else {
        Write-Host "$($event.TimeCreated) [INFO] $($event.Message)" -ForegroundColor Green
    }
    Write-Host "------------------------------------------------------------"
}

# Save output to default text file if no outputFile specified
if (-not $PSBoundParameters.ContainsKey('outputFile')) {
    $outputFile = "C:\temp\Event_Errors.txt"
}

# Save output to text file
$events | ForEach-Object {
    "$($_.Id) $($_.TimeCreated) $($_.LevelDisplayName) $($_.ProviderName) $($_.Message)"
} | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Events have been saved to $outputFile" -ForegroundColor Cyan

# Save output to CSV if specified
if ($csvOutput) {
    $events | Export-Csv -Path $csvOutput -NoTypeInformation
    Write-Host "Events have been saved to CSV: $csvOutput" -ForegroundColor Green
}

# Send email if emailRecipient is specified
$emailSent = $false
if ($emailRecipient) {
    $body = Get-Content -Path $outputFile | Out-String
    $smtpServer = "smtp.yourmailserver.com" # Update with your SMTP server
    $smtpFrom = "admin@yourdomain.com" # Update with your sender email address
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($smtpFrom, $emailRecipient, "Windows Logs Report", $body)
    Write-Host "Logs sent to $emailRecipient" -ForegroundColor Cyan
    $emailSent = $true
}

# Generate HTML report
$htmlOutput = @"
<html>
<head>
<title>Event Logs Report</title>
<style>
    body { font-family: Arial, sans-serif; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    tr:hover { background-color: #ddd; }
    .error { color: red; }
    .warning { color: orange; }
    .info { color: green; }
</style>
</head>
<body>
<h2>Event Logs Report</h2>
<table>
<tr><th>Time Created</th><th>Event ID</th><th>Level</th><th>Provider</th><th>Message</th></tr>
"@

foreach ($event in $events) {
    $colorClass = ""
    switch ($event.LevelDisplayName) {
        "Error" { $colorClass = "error" }
        "Warning" { $colorClass = "warning" }
        "Information" { $colorClass = "info" }
    }
    $htmlOutput += "<tr class='$colorClass'><td>$($event.TimeCreated)</td><td>$($event.Id)</td><td>$($event.LevelDisplayName)</td><td>$($event.ProviderName)</td><td>$($event.Message)</td></tr>"
}

$htmlOutput += @"
</table>
</body>
</html>
"@

# Save HTML report to a file
$reportPath = "C:\temp\EventLogsReport.html"
$htmlOutput | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "HTML report has been saved to $reportPath" -ForegroundColor Cyan

# Check and delete existing task if it exists
$taskName = "EventLogsAnalyzer_v2"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Set up Task Scheduler automation with a unique task name
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-File `"$PSScriptRoot\logs.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 3AM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings

# Final message based on whether the email was sent
if ($emailSent) {
    Write-Host "Script execution completed. Logs exported to $outputFile, HTML report saved to $reportPath, and email sent to $emailRecipient."
} else {
    Write-Host "Script execution completed. Logs exported to $outputFile and HTML report saved to $reportPath."
}



