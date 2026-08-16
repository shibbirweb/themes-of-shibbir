<#
.SYNOPSIS
    PowerShell sample: cmdlets, parameters, pipelines, hashtables.

.DESCRIPTION
    Comment-based help blocks use their own scopes, so this header should
    render differently from the code below it.

.EXAMPLE
    ./sample.ps1 -Path ../themes -Verbose
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [Parameter()]
    [ValidateSet('vs', 'vs-dark')]
    [string] $UiTheme = 'vs-dark',

    [Parameter()]
    [ValidateRange(1, 8)]
    [int] $MaxDepth = 8,

    [switch] $Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DefaultHex = '#EEFFFF'
$HexPattern = '^#(?:[0-9a-fA-F]{3}){1,2}$'

$Palette = @{
    background = '#263238'
    foreground = '#EEFFFF'
    keyword    = '#C792EA'
    string     = '#C3E88D'
}

function Get-Luminance {
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Hex
    )

    process {
        if ($Hex -notmatch $HexPattern) {
            Write-Warning "Invalid hex value: $Hex"
            return [double]::NaN
        }

        $red   = [Convert]::ToInt32($Hex.Substring(1, 2), 16)
        $green = [Convert]::ToInt32($Hex.Substring(3, 2), 16)
        $blue  = [Convert]::ToInt32($Hex.Substring(5, 2), 16)

        return (0.2126 * $red + 0.7152 * $green + 0.0722 * $blue) / 255
    }
}

function New-Swatch {
    param(
        [string] $Label,
        [string] $Hex = $DefaultHex
    )

    [PSCustomObject]@{
        Label     = $Label
        Hex       = $Hex
        Luminance = Get-Luminance -Hex $Hex
        Tone      = if ((Get-Luminance -Hex $Hex) -lt 0.5) { 'dark' } else { 'light' }
    }
}

try {
    if (-not (Test-Path -Path $Path -PathType Container)) {
        throw "Directory not found: $Path"
    }

    $swatches = foreach ($entry in $Palette.GetEnumerator()) {
        New-Swatch -Label $entry.Key -Hex $entry.Value
    }

    $swatches |
        Where-Object { $_.Hex -ne $DefaultHex } |
        Sort-Object -Property Luminance -Descending |
        Format-Table -AutoSize -Property Label, Hex, @{
            Name       = 'Luminance'
            Expression = { '{0:N4}' -f $_.Luminance }
        }, Tone

    $themeFiles = Get-ChildItem -Path $Path -Filter '*.json' -Recurse |
        Select-Object -First $MaxDepth

    Write-Verbose "Found $($themeFiles.Count) theme files under $Path"

    $summary = @"
Theme:    Themes of Shibbir
UiTheme:  $UiTheme
Swatches: $($swatches.Count)
Strict:   $($Strict.IsPresent)
"@

    Write-Output $summary
}
catch [System.IO.DirectoryNotFoundException] {
    Write-Error "Path problem: $($_.Exception.Message)"
    exit 1
}
catch {
    Write-Error "Unexpected: $($_.Exception.Message)"
    exit 1
}
finally {
    Write-Verbose 'Done'
}
