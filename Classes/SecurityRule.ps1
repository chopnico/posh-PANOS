class SecurityRule {
    [String]$Name
    [Object[]]$To
    [Object[]]$From
    [Object[]]$Source
    [Object[]]$Destination
    [String[]]$SourceUser
    [String[]]$Category
    [String[]]$Application
    [String[]]$Service
    [String[]]$HipProfiles
    [String]$Action
    [String]$Description
}
