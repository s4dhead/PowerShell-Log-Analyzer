# PowerShell Log Analyzer

## 📌 Usage

### Navigate to the Script Directory
```powershell
cd PowerShell-Log-Analyzer
```

### Open PowerShell as Administrator (Required to Access Event Logs)
1. Press `Win + X` and select **PowerShell (Admin)**.
2. Navigate to the script’s directory by running:
   ```powershell
   cd C:\path\to\PowerShell-Log-Analyzer
   ```

### Run the Script with Desired Parameters
The script allows you to specify how many days of logs to check, which log type to analyze, and where to save the results.

#### Example:
```powershell
.\logs.ps1 -days 7 -logName "System" -outputFile "C:\temp\Custom_Event_Logs.txt" -emailRecipient "example@example.com"
```
This retrieves logs from the **System event log** for the last **7 days** and saves them as a **.txt file**.

If an `-emailRecipient` is provided, the script will send the logs to the specified email address.

### View the Results
- **By default**, the output file is saved in `C:\temp\Event_Errors.txt`.
- **If CSV format is selected**, the file will be saved as specified.
- **HTML reports** are saved in `C:\temp\EventLogsReport.html`.
- Open the file using **Notepad, Excel, any text editor, or web browser**.

## ⚙️ Parameters

The script supports the following parameters:

### `-days`
- Number of days to check for logs.
- **Example:** `-days 3` (retrieves logs from the last 3 days).

### `-logName`
- The name of the log to analyze (e.g., System, Application, Security).
- **Example:** `-logName "Security"` (analyzes Security logs).

### `-outputFile`
- Path to save the output file.
- **Example:** `-outputFile "C:\temp\Custom_Event_Errors.txt"`

### `-keyword`
- Filter logs by a specific keyword.
- **Example:** `-keyword "Error"` (filters logs containing "Error").

### `-eventID`
- Filter logs by a specific Event ID.
- **Example:** `-eventID 1000` (filters logs with Event ID 1000).

### `-csvOutput`
- Path to save the output file in CSV format.
- **Example:** `-csvOutput "C:\temp\Event_Errors.csv"`

### `-emailRecipient`
- Send logs via email.
- **Example:** `-emailRecipient "admin@example.com"`

### `-criticalOnly`
- Show only critical system errors.
- **Example:** `-criticalOnly` (filters only Critical level logs).

### `-interactive`
- Enables interactive mode for easier use.
- **Example:** `-interactive` (prompts for input).

### `-filterUser`
- Filter logs by a specific user.
- **Example:** `-filterUser "UserName"` (filters logs generated by UserName).

## 🔄 Automating with Task Scheduler

### 1. Open Task Scheduler
- Press `Win + R`, type `taskschd.msc`, and press **Enter**.

### 2. Create a New Task
- Click **"Create Basic Task"**, enter a name, and click **Next**.

### 3. Choose When to Run the Script
- Select **Daily, Weekly, or a custom interval**, then click **Next**.

### 4. Set the Action to Run a Program
- Choose **"Start a Program"** and click **Next**.
- Browse to **powershell.exe** and in **Add arguments**, enter:
  ```powershell
  -ExecutionPolicy Bypass -File "C:\path\to\PowerShell-Log-Analyzer\logs.ps1" -days 7 -logName "System" -outputFile "C:\temp\Event_Errors.txt"
  ```

### 5. Click **Finish** to Schedule the Task
This ensures that logs are analyzed and saved automatically at regular intervals!

---
**Now your PowerShell Log Analyzer is ready to use! 🚀**

