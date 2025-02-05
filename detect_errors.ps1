param (
    [int]$days = 1, # Number of days to check
    [string]$logname = "Application" # Log name to check (e.g., "System", "Security")
)

# Define the start time based on user input
$startTime = (Get-Date).AddDays(-$days)

# Retrieve filtered events from the event log
$events = Get-EventLog -LogName $logname -EntryType Error, Warning -After $startTime | 
          Select-Object Index, TimeGenerated, EntryType, Source, InstanceId, Message

# Display results in a formatted table with colors applied only to "EntryType"
foreach ($event in $events) {
    # Determine the color for EntryType
    $color = if ($event.EntryType -eq "Error") { "Red" } elseif ($event.EntryType -eq "Warning") { "Yellow" } else { "White" }

    # Print the log entry with colored EntryType
    Write-Host ("{0,-8} {1,-20}" -f $event.Index, $event.TimeGenerated) -NoNewline
    Write-Host (" {0,-10}" -f $event.EntryType) -ForegroundColor $color -NoNewline
    Write-Host (" {0,-40} {1,-10} {2}" -f $event.Source, $event.InstanceId, $event.Message)
}

# Save the output to a file in table format without truncation
$events | Format-Table -AutoSize | Out-File -FilePath "C:\temp\Event_Errors.txt"
Write-Host "Events have been saved to C:\temp\Event_Errors.txt" -ForegroundColor Cyan



