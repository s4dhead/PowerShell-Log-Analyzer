Logs PowerShell Script

This PowerShell script is designed to help analyze Windows event logs by detecting errors, warnings, and other log entries. It provides flexibility to filter logs by severity, date range, and log type, and outputs the results in a variety of formats.

Features:
	•	Retrieves Error, Warning, and other log entries (e.g., Application, System, Security) from Windows Event Logs.
	•	Allows for filtering logs by severity and date range.
	•	Outputs results to .txt, CSV files, and can even send logs via email.
	•	Supports an interactive mode for easier use and custom configurations.
	•	Option to automate script execution with Task Scheduler.

Usage:
	1.	Clone the repository.
	2.	Open PowerShell and navigate to the script directory.
	3.	Run the script with the desired parameters:

.\logs.ps1 -days 7 -logName "System" -outputFormat "txt" -email "example@example.com"


	4.	The results will be saved to the specified output file (default: C:\temp\Event_Logs.txt).

Parameters:
	•	-days: Number of days to check for logs. Default is 1.
	•	-logName: The name of the log to analyze (e.g., System, Application). Default is Application.
	•	-outputFormat: Format of the output file (txt, csv). Default is txt.
	•	-email: Optionally send logs via email.

Contributing

Contributions are welcome! If you have any ideas for improvements or want to report bugs, feel free to open an issue or submit a pull request.

How to Contribute:
	1.	Fork the repository.
	2.	Clone it to your local machine.
	3.	Create a new branch:

git checkout -b feature-branch


	4.	Make your changes and commit them.
	5.	Push to your fork and submit a pull request.