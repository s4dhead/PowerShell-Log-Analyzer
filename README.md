# Logs PowerShell Script

This PowerShell script is designed to help analyze Windows event logs by detecting errors, warnings, and other log entries. It provides flexibility to filter logs by severity, date range, and log type, and outputs the results in a variety of formats.

## 🚀 Features:
- Retrieves **Error**, **Warning**, and other log entries (e.g., Application, System, Security) from Windows Event Logs.
- Allows filtering logs by **severity** and **date range**.
- Outputs results to **.txt**, **CSV** files, and can even send logs via **email**.
- Supports an **interactive mode** for easier use and custom configurations.
- Option to automate script execution with **Task Scheduler**.

## 📌 Usage

### Navigate to the script directory:
```sh
cd PowerShell-Log-Analyzer
```

### Open PowerShell as Administrator (required to access event logs):
1. Press **Win + X** and select **PowerShell (Admin)**.
2. Navigate to the script’s directory by running:
   ```sh
   cd C:\path\to\PowerShell-Log-Analyzer
   ```

### Run the script with the desired parameters:
The script allows you to specify how many days of logs to check, which log type to analyze, and where to save the results. Example:
```sh
.\logs.ps1 -days 7 -logName "System" -outputFormat "txt" -email "example@example.com"
```
This will retrieve logs from the **System** event log for the last **7 days** and save them as a **.txt** file.

- If an **email** is provided, the script will send the logs to the specified email address.

### View the results:
- By default, the output file is saved in **C:\temp\Event_Logs.txt**.
- If you selected **CSV** format, the file will be named **Event_Logs.csv**.
- Open the file using **Notepad, Excel, or any text editor**.

---

## ⚙️ Parameters:
The script supports the following parameters:

- **`-days`**: Number of days to check for logs.
  - Example: `-days 3` (retrieves logs from the last **3 days**).
- **`-logName`**: The name of the log to analyze (e.g., System, Application).
  - Example: `-logName "Security"` (analyzes **Security logs**).
- **`-outputFormat`**: Format of the output file (**txt, csv**).
  - Example: `-outputFormat "csv"` (saves logs as a **CSV file**).
- **`-email`**: Optionally send logs via email.
  - Example: `-email "admin@example.com"` (sends logs via **email**).

---

## 🔄 Automating with Task Scheduler:
To run the script automatically at regular intervals, follow these steps:

### Open Task Scheduler:
1. Press **Win + R**, type `taskschd.msc`, and press **Enter**.

### Create a new task:
1. Click **"Create Basic Task"**, enter a name, and click **Next**.
2. Choose when to run the script:
   - Select **Daily, Weekly**, or a **custom interval**, then click **Next**.

### Set the action to run a program:
1. Choose **"Start a Program"** and click **Next**.
2. Browse to `powershell.exe` and in **Add arguments**, enter:
   ```sh
   -ExecutionPolicy Bypass -File "C:\path\to\PowerShell-Log-Analyzer\logs.ps1" -days 7 -logName "System" -outputFormat "txt"
   ```
3. Click **Finish** to schedule the task.

This ensures that logs are analyzed and saved automatically at regular intervals!

