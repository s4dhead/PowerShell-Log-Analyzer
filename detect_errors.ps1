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
    [switch]$help
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
    Write-Host "  -emailRecipient <email>  Send logs via email"
    Write-Host "  -criticalOnly            Show only critical system errors"
    Write-Host "  -interactive             Interactive mode (prompts for input)"
    Write-Host "  -help                    Show this help message and exit"
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
}

# Define the start time
$startTime = (Get-Date).AddDays(-$days)

# Try using Get-WinEvent for modern logs
try {
    $events = Get-WinEvent -LogName $logname | 
              Where-Object { $_.TimeCreated -ge $startTime -and ($_.Level -eq 2 -or $_.Level -eq 3) } |
              Select-Object Id, TimeCreated, LevelDisplayName, ProviderName, Message
} catch {
    Write-Host "Get-WinEvent failed, using Get-EventLog instead..." -ForegroundColor Yellow
    $events = Get-EventLog -LogName $logname -EntryType Error, Warning -After $startTime | 
              Select-Object Index, TimeGenerated, EntryType, Source, InstanceId, Message
}

# Apply Critical Errors filter
if ($criticalOnly) {
    $events = $events | Where-Object { $_.LevelDisplayName -eq "Critical" }
}

# Apply Event ID filtering
if ($eventID -ne 0) {
    $events = $events | Where-Object { $_.Id -eq $eventID -or $_.Index -eq $eventID }
}

# Apply Keyword filtering
if ($keyword -ne "") {
    $events = $events | Where-Object { $_.Message -match $keyword }
}

# If no logs found, exit
if ($events.Count -eq 0) {
    Write-Host "No matching logs found in the last $days day(s) for '$logname' log." -ForegroundColor Green
    exit
}

# Display results with color-coded severity
foreach ($event in $events) {
    $color = if ($event.LevelDisplayName -eq "Error" -or $event.EntryType -eq "Error") { "Red" } 
             elseif ($event.LevelDisplayName -eq "Warning" -or $event.EntryType -eq "Warning") { "Yellow" } 
             elseif ($event.LevelDisplayName -eq "Critical") { "Magenta" } 
             else { "White" }

    Write-Host ("{0,-8} {1,-20}" -f ($event.Id ?? $event.Index), $event.TimeCreated) -NoNewline
    Write-Host (" {0,-10}" -f ($event.LevelDisplayName ?? $event.EntryType)) -ForegroundColor $color -NoNewline
    Write-Host (" {0,-40} {1,-10}" -f ($event.ProviderName ?? $event.Source), ($event.InstanceId ?? ""))

    Write-Host "Message: " -ForegroundColor Cyan
    Write-Host $event.Message -ForegroundColor Gray
    Write-Host "------------------------------------------------------------"
}

# Save output to text file
$events | Format-Table -AutoSize | Out-File -FilePath $outputFile
Write-Host "Events have been saved to $outputFile" -ForegroundColor Cyan

# Save output to CSV if specified
if ($csvOutput -ne "") {
    $events | Export-Csv -Path $csvOutput -NoTypeInformation
    Write-Host "Events have been saved to CSV: $csvOutput" -ForegroundColor Green
}

# Send email if specified
if ($emailRecipient -ne "") {
    $body = Get-Content -Path $outputFile | Out-String
    Send-MailMessage -To $emailRecipient -From "admin@yourdomain.com" -Subject "Windows Logs Report" -Body $body -SmtpServer "smtp.yourmailserver.com"
    Write-Host "Logs sent to $emailRecipient" -ForegroundColor Cyan
}



