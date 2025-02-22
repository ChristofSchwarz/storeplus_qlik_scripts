 
$parent = Split-Path -Path $PSScriptRoot -Parent
Write-Host "parent folder: $parent"
$stable = "$parent\stable"
$preview = "$parent\preview"
$backups = "$parent\backups"
if (-not (Test-Path -Path $preview -PathType Container)) {
    Write-Host -f Red "No such folder: $preview"
    Exit
}
if (-not (Test-Path -Path $stable -PathType Container)) {
    Write-Host -f Red "No such folder: $stable"
    Exit
}
if (-not (Test-Path -Path $backups -PathType Container)) {
    New-Item -ItemType Directory -Path $backups
}
Write-Host "Making a backup .zip file ..."
Compress-Archive $stable "$parent\backups\stable $((Get-Date).ToString('yyyy-MM-dd HHmmss')).zip"
Remove-Item -Path "$stable\*" -Recurse -Force
Write-Host "Cleaning \stable folder"
Write-Host "Copying folder \preview to \stable"
Copy-Item -Path "$preview\*" -Destination $stable -Recurse -Force
Write-Host "All items copied from \preview to \stable"
pause