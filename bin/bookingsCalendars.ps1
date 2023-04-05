<#
.SYNOPSIS
    bookingsCalendars.ps1
 
.DESCRIPTION
    This program looks for a list of pcnames which it wil check for .
 
.NOTES
       VERSION HISTORY:
       1.0     07-05-2021  - Checking bookingsCalender permissions
 
.COMPONENT 
    Exchange Modules
    Azure Modules
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>
#Connect to azure

$operator = Read-Host "Whats your E-Mail Address? "
Connect-EXOPSSession -UserPrincipalName $operator
Connect-ExchangeOnline  -UserPrincipalName $operator

# prerequisite: Exchange Online v2 PowerShell module, must be connected to the service

$BookingsMailboxesWithPermissions = New-Object 'System.Collections.Generic.List[System.Object]'
# Get all Booking Mailboxes
$allBookingsMailboxes = Get-ExoMailbox -RecipientTypeDetails SchedulingMailbox -ResultSize:Unlimited

# Loop through the list of Mailboxes
$BookingsMailboxesWithPermissions = foreach($bookingsMailbox in $allBookingsMailboxes) {
    # Get Permissions for this Mailbox
    $allPermissionsForThisMailbox = Get-ExoMailboxPermission -UserPrincipalName $bookingsMailbox.UserPrincipalName -ResultSize:Unlimited | Where-Object {($_.User -like '*@*') -and ($_.AccessRights -eq "FullAccess")}
    foreach($permission in $allPermissionsForThisMailbox) {
        # Output PSCustomObject with infos to the foreach loop, so it gets saved into $BookingsMailboxesWithPermissions
        [PSCustomObject]@{
            'Bookings Mailbox DisplayName' = $bookingsMailbox.DisplayName
            'Bookings Mailbox E-Mail-Address' = $bookingsMailbox.PrimarySmtpAddress
            'User' = $permission.User
            'AccessRights' = "Administrator"
            }
    }
}
$BookingsMailboxesWithPermissions | Export-Csv C:\temp\bookings-permissions.csv -Encoding utf8