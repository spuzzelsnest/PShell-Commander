$source = Get-content -Path "_dumpFiles\dotNetVersion.cs"

Add-Type -TypeDefinition "$source"

# Call a static method
[dotNetVersion]::Add(4, 3)

# Create an instance and call an instance method
$basicTestObject = New-Object BasicTest
$basicTestObject.Multiply(5, 2)