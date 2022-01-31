#Connect to azure

Connect-EXOPSSession -UserPrincipalName jan.desmet@sint-lievens-houtem.be
Connect-ExchangeOnline  -UserPrincipalName jan.desmet@sint-lievens-houtem.be

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