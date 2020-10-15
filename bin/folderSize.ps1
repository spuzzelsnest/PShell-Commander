param([string] $dir = "C:\Temp", 
      [int32] $size = 20000)
$files = Get-ChildItem $dir
foreach ($file in $files)
{
    if ($file.length -gt $size)
    {
        Write-Output $file
    }
} 