<#
.SYNOPSIS
    Splits the specified file into files of the specified size.

.DESCRIPTION
    Splits the specified file into files of the specified size.
    The resulting files will be output in the designated directory or the same directory as the source file,
    and named as <src_filename_with_ext>.NN..N where N is decimal digits.
    If only a portion from the beginning to the middle of the split files is needed,
    set the number of the resulting file to which you need as -To parameter.

.PARAMETER Path
    Path to the file to be splitted.

.PARAMETER Size
    Maximum size in bytes of resulting files. 

.PARAMETER Destination
    Path of the destination directory in which the resulting files will be output.
    If directory does not exists or path points a file, the destination will be automatically set.

.PARAMETER To
    The maximum number of the resulting file to be output actually.
    This parameter will be considered after the Size parameter, so it never adjusts the Size.
    
.EXAMPLE
    > . .\SplitFile.ps1; Split-File -Path README.md -Size 256

    # To split a file into files of 256 bytes.
    # Resulting files are output to the same directory as the source file.

.EXAMPLE
    > . .\SplitFile.ps1; Split-File -Path c:\some\README.md -Size 256 -Destination . -To 2
    
    # To split a file into files of 256 bytes.
    # Resulting files are output to the current directory.
    # If the number of the resulting files are greater than 2, only 1st and 2nd files will be output.
#>
function Split-File {
    param(
        [string][Parameter(Mandatory = $True)]
        $Path,
        [int][Parameter(Mandatory = $True)]
        $Size,
        [string]
        $Destination,
        [int]
        $To = 0
    )
    Write-Debug ">>> Split-File"
    Write-Debug "Path           :""$Path"""
    Write-Debug "Size           :$Size"
    Write-Debug "Destination    :""$Destination"""
    Write-Debug "To             :$To"

    # validating $Path file.
    if ( !(Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host "Path does not point a file: ""$Path""" -ForegroundColor Red
        exit 1
    }
    $src = Get-Item -LiteralPath $Path

    # validating $Destination folder.
    $dst = $null
    if ([System.String]::IsNullOrEmpty($Destination)) {
        Write-Host "Destination not designated. Set based on Path." `
            -ForegroundColor Yellow
        $dst = $src.Directory
    }
    elseif ( !(Test-Path -LiteralPath $Destination -PathType Container)) {
        Write-Host "Destination does not exist or points a file. Set based on Path." `
            -ForegroundColor Yellow
        $dst = $src.Directory
    }
    else {
        $dst = Get-Item -LiteralPath $Destination
    }

    # calcurating the number of result files and required digits.
    $fileCount = [Math]::Ceiling($src.Length / $Size)
    $digitCount = [Math]::Ceiling([Math]::log10($fileCount))

    # calcurating the number of result actually required to be output.
    $num = ($To -ne 0) -and ($To -le $fileCount) ? $To : $fileCount

    Write-Host "Source: ""$Path"""
    Write-Host "  total $($src.Length) [byte]"
    Write-Host "  to be split into $fileCount files."
    Write-Host "  actual output $num files, sized $Size [byte]."

    # check if dst-like files already exist and clean them if needed.
    $dstPattern = Join-Path $dst.FullName $($src.Name + ".*")
    Get-ChildItem -Path $dstPattern | Remove-Item -Confirm
    if ( Test-Path -Path $dstPattern ) {
        Write-Host "Destination files still exist." -ForegroundColor Red
        exit 1
    }

    $buff = New-Object byte[] $Size
    $srcFs = $src.OpenRead()
    try {
        for ($i = 1; $i -le $num; ++$i) {
            $dstFile = Join-Path $dst.FullName $($src.Name + ".{0:D$digitCount}" -f $i)
            Write-Host "Writing $dstFile"
            $dstFs = (New-Item -Path $dstFile).OpenWrite()
            try {        
                $count = $srcFs.Read($buff, 0, $Size)
                $dstFs.Write($buff, 0, $count)
            
            }
            finally {
                $dstFs.Close() 
            }
        }
    }
    finally {
        $srcFs.Close()
    }
    Write-Host "Splitting file completed." -ForegroundColor Cyan
    Write-Debug "<<< Split-File"
}

