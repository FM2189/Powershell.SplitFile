# Powershell.SplitFile
Powershell function to split a file.

## Description

See the comment-based help.

```ps1
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
```
