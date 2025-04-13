<#
.SYNOPSIS
    Generates an authentication methods report from Microsoft Graph and exports it to CSV.

.DESCRIPTION
    Connects to Microsoft Graph, retrieves user authentication method details, and exports the report
    to a specified directory. Ensures required folder paths exist.

.NOTES
    Script Name    : Export-AuthMethodsReport.ps1
    Version        : 0.1
    Author         : Bhuvaneshwari
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : To generate and export a report of user authentication methods in the tenant.

.PREREQUISITES
    - Microsoft.Graph module installed and connected with appropriate permissions.
    - Required folders: C:\Scripts, C:\Scripts\Reports, C:\Scripts\Creds

.PARAMETERS
    None

.EXAMPLE
    .\Export-AuthMethodsReport.ps1
#>

# Start of Script

# Define required folders
@(
    "C:\Scripts",
    "C:\Scripts\Reports",
    "C:\Scripts\Creds"
) | ForEach-Object { New-Item -Path $_ -ItemType Directory -Force | Out-Null }

# Change to script directory
Set-Location -Path "C:\Scripts"

# Load stored credential functions
. .\Functions-PSStoredCredentials.ps1

# Keypath
$Keypath = "C:\Scripts\Creds"

# Retrieve stored credentials
$cred = Get-StoredCredential -UserName Jonathan.Preetham@contoso.com

# Define CSV Path
$CSVPath = "C:\Scripts\Reports\AuthMethodsReport.csv"

# Connect to Microsoft Graph with necessary scopes
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All", "Group.Read.All", "UserAuthenticationMethod.Read.All"

# Fetch user registration detail report from Microsoft Graph
$Users = Get-MgBetaReportAuthenticationMethodUserRegistrationDetail -All


    # Fetch user registration detail report from Microsoft Graph
    $Users = Get-MgBetaReportAuthenticationMethodUserRegistrationDetail -All

    # Create custom PowerShell object and populate it with the desired properties
    $Report = foreach ($User in $Users) {
        # Fetch additional user details
        $MgUser = Get-MgUser -UserId $User.Id -Property "DisplayName,OfficeLocation,MobilePhone"
        
        # Fetch phone authentication method details
        $PhoneMethods = Get-MgUserAuthenticationPhoneMethod -UserId $User.Id
        $PhoneNumber = ($PhoneMethods | Where-Object { $_.PhoneType -eq "mobile" }).PhoneNumber

        [PSCustomObject]@{
            Id                                           = $User.Id
            UserPrincipalName                            = $User.UserPrincipalName
            UserDisplayName                              = $User.UserDisplayName
            IsAdmin                                      = $User.IsAdmin
            DefaultMfaMethod                             = $User.DefaultMfaMethod
            MethodsRegistered                            = $User.MethodsRegistered -join ','
            IsMfaCapable                                 = $User.IsMfaCapable
            IsMfaRegistered                              = $User.IsMfaRegistered
            IsPasswordlessCapable                        = $User.IsPasswordlessCapable
            IsSsprCapable                                = $User.IsSsprCapable
            IsSsprEnabled                                = $User.IsSsprEnabled
            IsSsprRegistered                             = $User.IsSsprRegistered
            IsSystemPreferredAuthenticationMethodEnabled = $User.IsSystemPreferredAuthenticationMethodEnabled
            LastUpdatedDateTime                          = $User.LastUpdatedDateTime
            OfficeLocation                               = $MgUser.OfficeLocation
            MobilePhone                                  = $MgUser.MobilePhone
            AuthPhoneNumber                              = $PhoneNumber
        }
    }


    # Export custom object to CSV file
    $Report | Export-Csv -Path $CSVPath -NoTypeInformation -Encoding utf8


# End of Script