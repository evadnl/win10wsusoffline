########################################################################################
# Windows 10 offline update script
# Purpose:
# Manually updating the .wim image captured via MDT.
# Steps in this script:
# 1. Create a copy of the .wim file by copying it and renaming it to .wim.old
# 2. Mount the image via DISM
# 3. Add .cab files of already downloaded Windows updates via /add-package with DISM
# 4. Commit changes and unmount WIM image
#
# MUST BE RUN WITH ELEVATED RIGHTS
#
# VARIABLES
$imagefile = "D:\DeploymentShare\Operating Systems\Windows 10 Enterprise LTSC 2019 x64 (1809)\Sources\install.wim"
$backupfile = "D:\DeploymentShare\Operating Systems\Windows 10 Enterprise LTSC 2019 x64 (1809)\Sources\install.wim.old"
$mountlocation = "D:\WindowsUpdates\mnt"
$packagepath = "D:\WindowsUpdates\wsusoffline\client\w100-x64\glb"
$logpath = "D:\WindowsUpdates\logs\update.log"
# /VARIABLES
# FUNCTIONS
# /FUNCTIONS
# IMPORT MODULES
Import-Module BitsTransfer # used to show a progress bar for the copy/backup.
$env:path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
import-module "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM"
#/IMPORT MODULES
########################################################################################

Write-host "You are about to update the WIM image." -ForegroundColor red -BackgroundColor black

# Ask user to continue or not
$confirmation = Read-Host "Are you sure? [y/n]"
if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    # User confirmed
        Write-host "Continuing process" -ForegroundColor Green -BackgroundColor black
        Write-host "Now creating backup of WIM image located at '$imagefile'" -ForegroundColor Green -BackgroundColor Black
            # Copy the .wim image file and create .wim.old
            Start-BitsTransfer -Source $imagefile -Destination $backupfile -Description "Creating backup of WIM file" -DisplayName "Backup"     
        Write-host "Backup finished, file created at '$backupfile'" -ForegroundColor Green -BackgroundColor Black
        Write-host "Now mounting WIM image to '$mountlocation'" -ForegroundColor Green -BackgroundColor Black
            #mount .wim file to specified location in variables
            Start-Sleep -S 10        
            Mount-WindowsImage -ImagePath "$imagefile" -Path "$mountlocation" -Index 1
        Write-host "Image mounted successfully." -ForegroundColor Green -BackgroundColor Black 
        Write-host "Adding .cab files to mounted image" -ForegroundColor Green -BackgroundColor Black
            #append image with cab/msu files downloaded with wsus offline
            Add-WindowsPackage -Path "$mountlocation" -PackagePath "$packagepath" -LogPath "$logpath"
        Write-host "Adding packages finished. Check the logs at '$logpath'."  -ForegroundColor Green -BackgroundColor Black
            #unmount .wim file and commit changes
            Dismount-WindowsImage -Path "$mountlocation" -Save
        Write-host "Dismounting image finished."  -ForegroundColor Green -BackgroundColor Black
}
else {
 Write-host "Terminating process" -ForegroundColor Red -BackgroundColor black
 exit;
 }
