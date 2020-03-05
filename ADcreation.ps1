Configuration ADDomain_NewForest_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SafeModePassword
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName xsmbshare
    Import-DscResource -ModuleName xComputermanagement
    Import-DscResource -ModuleName xDnsServer
    

    node $allnodes.nodename
    {   
        xComputer changecomputername
        {
            name = 'shutterupAD001'
        }
        xIPaddress staticipaddress
        {
            InterfaceAlias = 'Ethernet0' 
            IPAddress = '192.168.130.130/24'
            AddressFamily = 'IPV4'
        }
        xDefaultGatewayAddress Defaultgateway
        {
            Address = '192.168.130.1'
            InterFaceAlias = 'Ethernet0'
            AddressFamily = 'IPV4'
        }
        xDnsServerAddress DNSaddress
        {
            Address = '127.0.0.1'
            InterfaceAlias = 'Ethernet0'
            AddressFamily = 'IPV4'
            Validate = $true
        }
        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT'
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        ADDomain 'shutterup.local'
        {
            DomainName                    = 'shutterup.local'
            Credential                    = $Credential
            SafemodeAdministratorPassword = $SafeModePassword
            ForestMode                    = 'WinThreshold'
        }
    }
}
$cd = @{
    AllNodes = @(    
        @{  
            NodeName = "localhost"
            PsDscAllowPlainTextPassword = $true
        }
    ) 
}


ADDomain_NewForest_Config -ConfigurationData $cd -MachineName



