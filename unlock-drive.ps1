$ErrorActionPreference = 'Stop'

# Prompt the user to enter the drive letter they want to unlock
$driveLetter = Read-Host -Prompt "Enter the drive letter:"

# Infinite loop to generate and try recovery keys
while ($true) {
    # Generate a random recovery key
    $recoveryKey = -join ((1..47) | ForEach-Object {
        $randomDigit = Get-Random -Minimum 0 -Maximum 10

        if ($_ -eq 6 -or $_ -eq 12 -or $_ -eq 18 -or $_ -eq 24 -or $_ -eq 30 -or $_ -eq 36) {
            '-'
        }

        $randomDigit
    })

    # Remove the extra dash at the end
    $recoveryKey = $recoveryKey.Substring(0, $recoveryKey.Length - 1)

    # Print the recovery key that will be attempted
    Write-Host "Trying recovery key: $recoveryKey"

    # Check if BitLocker is accessible
    $bitLockerStatus = manage-bde -status $driveLetter | Select-String -Pattern "BitLocker"
    if (-not $bitLockerStatus) {
        Write-Host "BitLocker is not accessible for drive $driveLetter."
        Pause
        Exit
    }

    # Check if the recovery key has been used before
    $usedPasswordsFile = Join-Path $env:userprofile "Desktop\used_passwords.txt"
    $isRecoveryKeyUsed = Select-String -Path $usedPasswordsFile -Pattern $recoveryKey
    if ($isRecoveryKeyUsed) {
        # If the recovery key has been used, generate a new one
        Write-Host "Recovery key already used. Generating a new one..."
        Continue
    }
    else {
        # Save the recovery key in the used_passwords.txt file
        Add-Content -Path $usedPasswordsFile -Value $recoveryKey

        # Attempt to unlock the drive using the recovery key
        try {
            manage-bde -unlock $driveLetter -RecoveryKey $recoveryKey
            # If the drive is unlocked successfully, display a success message and exit
            Write-Host "Drive $driveLetter unlocked successfully using recovery key: $recoveryKey"
            Pause
            Exit
        }
        catch {
            # An error occurred while attempting to unlock the drive
            $errorCode = $_.Exception.ErrorCode
            switch ($errorCode) {
                2 {
                    # An error occurred while reading the key from disk, generate a new recovery key
                    Write-Host "An error occurred while attempting to read the key from disk."
                    Write-Host "Generating a new recovery key..."
                    Continue
                }
                default {
                    # Display the error message and exit
                    Write-Host "An error occurred while attempting to unlock the drive."
                    Write-Host "Error code: $errorCode"
                    Pause
                    Exit
                }
            }
        }
    }
}
