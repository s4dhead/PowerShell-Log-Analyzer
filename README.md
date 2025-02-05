# Detect Errors PowerShell Script

This PowerShell script helps detect errors and warnings in Windows event logs within a specified date range.

## Features:
- Retrieves `Error` and `Warning` entries from the specified event log (e.g., System, Application).
- Outputs the results to a `.txt` file for further analysis.

## Usage:
1. Clone the repository.
2. Open PowerShell and navigate to the script directory.
3. Run the script with the desired parameters:
   ```powershell
   .\detect_errors.ps1 -days 7 -logName "System"
4. The results will be saved to C:\temp\Event_Errors.txt.

## Contributing

Contributions are welcome! If you have any ideas for improvements or if you'd like to report bugs, feel free to open an issue or submit a pull request.

### How to contribute
1. Fork the repository
2. Clone it to your local machine
3. Create a new branch (`git checkout -b feature-branch`)
4. Make your changes and commit them
5. Push to your fork and submit a pull request
