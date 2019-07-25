$classes = Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1
ForEach($class in $classes){
    Write-Verbose "Importing classs $($class)"
    . $class.FullName
}
