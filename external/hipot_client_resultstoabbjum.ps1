# Define the server IP and port
$serverIp = "192.168.0.9"
$port = 8080

# Specify the folder containing CSV files
$folderPath = "C:\16483\results"

# Get the most recently modified CSV file
$latestFile = Get-ChildItem $folderPath -Filter *.csv | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestFile -eq $null) {
    Write-Host "No CSV files found in $folderPath"
} else {
    $filePath = $latestFile.FullName

    # Create a TCP client
    $client = [System.Net.Sockets.TcpClient]::new()
    $client.Connect($serverIp, $port)
    $stream = $client.GetStream()

    # Send the file name
    #[System.IO.BinaryWriter]::new($stream).Write($latestFile.Name)

    # Read  the file content
    $command = "HIPOT:MET:"
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    
    # Send Data
    $data = $command+$fileBytes
    $stream.Write($command, 0, $command.Length)

    $stream.Close()
    $client.Close()

    Write-Host "File $latestFile sent to $serverIp on port $port"
}
