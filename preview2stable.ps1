 
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
# Compress-Archive $stable "$parent\backups\stable $((Get-Date).ToString('yyyy-MM-dd HHmmss')).zip"

Write-Host "Cleaning \stable folder"

# Get all items in the folder recursively
Get-ChildItem -Path $stable -Recurse -Force | ForEach-Object {
    # Skip the .git folder
    if (($_.PSIsContainer -and $_.Name -eq ".git") `
        -or (-not $_.PSIsContainer -and $_.Name -eq "README.md")) {
        Write-Host "Skipping deletion of" $_
        return
    } 

    # Delete files and folders
    if ($_.PSIsContainer) {
        Write-Host "deleteing folder" $_
        # Remove empty folders after processing
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "deleting file" $_
        # Remove individual files
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    }
}

pause
Write-Host "Copying folder \preview to \stable"
# Copy-Item -Path "$preview\*" -Destination $stable -Recurse -Force
# Define the source and destination paths
$SourcePath = $preview
$DestinationPath = $stable

# Copy the entire folder structure, excluding the .git folder and README.md file
Get-ChildItem -Path $SourcePath -Recurse -Force | ForEach-Object {

    $skip = ($_.PSIsContainer -and $_.Name -eq ".git") `
    -or ($_.FullName -like "*\.git\*") `
    -or (-not $_.PSIsContainer -and $_.Name -eq "README.md") `
    -or (-not $_.PSIsContainer -and $_.Name -eq "preview*stable.ps1")

    if (-not $skip) {
        
        # Calculate the destination path
        $TargetPath = Join-Path -Path $DestinationPath -ChildPath ($_.FullName.Substring($SourcePath.Length).TrimStart('\'))

        # Create directories if needed
        if ($_.PSIsContainer) {
            if (-not (Test-Path -Path $TargetPath)) {
                New-Item -ItemType Directory -Path $TargetPath -Force
            }
        } else {
            # Copy files
            Copy-Item -Path $_.FullName -Destination $TargetPath -Force
        }
    }
}

Write-Host "All items copied from \preview to \stable"
pause