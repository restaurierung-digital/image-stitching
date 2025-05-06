# Rename the individual shots that were used to stitch an image
# 
# Naming scheme:
# A letter indicates the row (ascending, starting with A)
# A consecutive number indicates the column
# The counting of the column starts again with each row
# 
# Example:
# A1 A2 A3 ...
# B1 B2 B3 ...
# C1 C2 C3 ...
# ...
#
# Date: 2025-02-25 | Version 1.0

# Functions
function print-error-end {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string]$error_message = "Unknown error"
	)

	Write-Host -ForegroundColor White -BackgroundColor Red "ERROR: $error_message"
	exit
}

# Welcome Message
Write-Host "Rename the individual shots that were used to create an image (stitching)"

# Prompt for the folder with the files
$filePath = Read-Host -Prompt "Path to the images"
if (-Not (Test-Path -Path "$filePath")) { print-error-end -error_message "Path not found" }

# Prompt for the number of files per row
$filesPerRow = Read-Host -Prompt "Files per row"
if ($filesPerRow -match "^[1-9]\d*$") {
	$filesPerRow = [int]$filesPerRow
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Prompt for prefix
$filenamePrefix = Read-Host -Prompt "File name prefix (can be empty)"
$filenamePrefix = $filenamePrefix.Trim()
if (-Not [string]::IsNullOrEmpty($filenamePrefix)) {
	if (-Not (Test-Path -IsValid "$filenamePrefix")) { print-error-end -error_message "Not a valid file name prefix" }
}

# Prompt for suffix
$filenameSuffix = Read-Host -Prompt "File name suffix (can be empty)"
$filenameSuffix = $filenameSuffix.Trim()
if (-Not [string]::IsNullOrEmpty($filenameSuffix)) {
	if (-Not (Test-Path -IsValid "$filenameSuffix")) { print-error-end -error_message "Not a valid file name prefix" }
}

# Get all files in the image directory
$files = Get-ChildItem -File -Path $filePath

# Check whether the naming scheme is sufficient for the number of files
if($files.Count / $filesPerRow -gt 26) {
	print-error-end -error_message "Too many files for the naming scheme"
}

# Check whether the files can be split without a remainder
if($files.Count % $filesPerRow -ne 0) {
	$message = "The files cannot be distributed uniformly: " + $files.Count + "/" + $filesPerRow + ", Remainder " + $files.Count % $filesPerRow
	print-error-end -error_message $message
}

# Initialize variables
$rowLetter = 65  # ASCII value for 'A'
$fileIndex = 1

# Loop through the files and rename them
foreach ($file in $files) {
	# Construct the new name based on the letter and number
	$letter = [char]$rowLetter
	$newName = "$filenamePrefix$letter$fileIndex$filenameSuffix$($file.Extension)"
    
	# Rename the file
	Rename-Item -Path $file.FullName -NewName $newName
    
	# Increment the file index
	$fileIndex++
    
	# Check if the number of files in the row is reached
	if ($fileIndex -gt $filesPerRow) {
		$fileIndex = 1
		$rowLetter++  # Move to the next letter in the alphabet
	}
}

# Finish
Write-Host "The files have been renamed"
