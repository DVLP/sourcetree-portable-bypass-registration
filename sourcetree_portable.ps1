$version="3.4.18"
$url="https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourcetreeEnterpriseSetup_$($version).msi"
$client = New-Object System.Net.WebClient

echo "Downloading sourcetree"
$client.DownloadFile($url, (Get-Item -Path ".\").FullName + "\sourcetree.msi")
mkdir sourcetree
$msi = (Get-ChildItem "*.msi" | select  -Last 1).fullname
$target = (Get-Item -Path ".\sourcetree").FullName

echo ""
echo "Unpacking..."
msiexec /a $msi /qb TARGETDIR=$target
Start-Sleep -s 5

echo "Opening and closing SourceTree.exe to create default directories..."
$exe = (Get-ChildItem -Recurse "./SourceTree.exe" | select  -Last 1).fullname
& $exe
Start-Sleep -s 5
echo "Waiting 10s. Don't close SourceTree, it will close itself."
Start-Sleep -s 10

echo "Killing SourceTree"
kill (Get-Process SourceTree).id

echo "Finding installation directories"

$userConfPath=(Get-ChildItem -LiteralPath $env:LOCALAPPDATA\Atlassian -Recurse -Directory -Filter $version* -Force).fullname

echo "Copying config files (sign-in bypass)"
Copy-Item ".\user.config" -Destination $userConfPath
Copy-Item ".\accounts.json" -Destination $env:APPDATA\Atlassian\SourceTree

echo "Flattening folder"
Get-ChildItem -Path .\sourcetree\ProgramFiles\Atlassian\Sourcetree -Recurse | Move-Item -Destination .\sourcetree
# Start-Sleep -s 2

echo "Cleaning up"
rm $msi
rm .\sourcetree\sourcetree.msi
rm -Recurse .\sourcetree\ProgramFiles

Read-Host -Prompt "Press Enter to exit"
