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

    # Read the file content
    $fileContent = Get-Content -Path $filePath -Raw
    $data = "HIPOT:MET:ST80:" + $fileContent
    $data = $data.Replace("`n", "__NL__")
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($data)
    
    # Send Data
    $stream.Write($bytes, 0, $bytes.Length)

    $stream.Close()
    $client.Close()

    Write-Host "File $latestFile sent to $serverIp on port $port"
    Write-Host $bytes.Length
    Write-Host "File $lastFile sent to $serverIp on port $port"
}
