class AnyAddress {
    [String]$Name
    [String]$Address
    [String]$Description
    [String]$Type
    [Array]$Tags

    AnyAddress(){
        $this.Name = "any"
        $this.Address = "0.0.0.0/0"
        $this.Description = "any"
        $this.Type = "ip-netmask"
        $this.Tags = "any"
    }
}