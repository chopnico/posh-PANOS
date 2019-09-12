class SecurityRule {
    [String]$Name
    [Address[]]$To
    [Address[]]$From
    [Address[]]$Source
    [Address[]]$Destination
    [String[]]$SourceUser
    [String[]]$Category
    [String[]]$Application
    [String[]]$Service
    [String[]]$HipProfiles
    [String]$Action
    [String]$Description
}
