<#
.SYNOPSIS
    Switch-Name

    Takes a string of space separated words and turns it around.
.DESCRIPTION
    Switch-Name's intended use is to take a name, like 'Charlie Brown' and return it as 'Brown Charlie'.
    However, it is designed to take any space separated string and reverse the word order.
.EXAMPLE
    Standard usage:

    Switch-Name -Name 'Charlie Brown'

    Output: 'Brown Charlie'
.EXAMPLE
    Pipeline usage:
    
    'Charlie Brown' | Switch-Name

    Output: 'Brown Charlie'
.EXAMPLE
    Empty input objects or multiple spaces between words will be ignored:

    [string[]]$Names = @(
        'Marty McFly'
        'Jennifer McFly'
        ''
        'George   McFly'
    )
    $Names | Switch-Name

    Output:
    McFly Marty
    McFly Jennifer
    McFly George

.NOTES
    by Maximilian Otter, 2019
#>
function Switch-Name {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )
    
    process {
        if ($Name -match '\w+ +\w+') {
            $Splits = $Name -split ' +' 
            $Result = for ($i = $Splits.Count; $i -ge 0; $i--) {
                $Splits[$i]
            }
            ($Result -join ' ').trim(' ')
        }
    }
}