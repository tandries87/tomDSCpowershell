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
        WindowsFeature dhcp-server
	    {
            Name = 'DHCP'
            Ensure = 'Present'
            DependsOn= '[ADDomain]shutterup.local'
        }
        WindowsFeature dhcp-server-tools
        {
            DependsON = '[WindowsFeature]dhcp-server'
            Name = 'RSAT-DHCP'
            Ensure = 'present'
        }
        xDhcpServerScope Scope
        {
            Ensure = 'present'
            Name = 'DHCPscope'
            ScopeID = '192.168.130.0'
            IPStartRange = '192.168.130.2'
            IPEndRange = '192.168.130.120'
            SubnetMask = '255.255.255.0'
            LeaseDuration = '00:30:00'
            State = 'Active'
            AddressFamily = 'IPv4'
            DependsOn= '[ADDomain]shutterup.local'
        }
        xDhcpServerOption options
        {
            Ensure = 'Present'
            DnsDomain = 'shutterupAD001.shutterup.local'
            router = '192.168.130.1'
            ScopeID = '192.168.130.0'
            DnsServerIPAddress = '192.168.130.130','8.8.8.8'
            AddressFamily = 'IPv4'
            DependsOn= '[ADDomain]shutterup.local'
        }
        xDhcpServerAuthorization authorization
        {
            Ensure = 'present'
            DnsName = 'shutterupAD001.shutterup.local'
            IPAddress = '192.168.130.130'
            DependsOn= '[ADDomain]shutterup.local'
        }
        WindowsFeature dnsserver
	    {
  	        Ensure = "Present"
   	        Name = "dns" 
            DependsOn= '[xDhcpServerOption]options'
	    }
        xDnsServerForwarder SetForwarders
        {
            IsSingleInstance = 'Yes'
            IPAddresses = '8.8.8.8','1.1.1.1'
            UseRootHint = $false
            DependsOn= '[xDhcpServerOption]options'
        }
        File HR
        {
            DestinationPath = 'C:\sambashare\HR'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        File Marketing
        {
            DestinationPath = 'C:\sambashare\Marketing'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        File Productie
        {
            DestinationPath = 'C:\sambashare\Productie'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        File Onderzoek
        {
            DestinationPath = 'C:\sambashare\Onderzoek'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        File Logistiek
        {
            DestinationPath = 'C:\sambashare\Logistiek'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        File web
        {
            DestinationPath = 'c:\inetpub\wwwroot\web'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn= '[WindowsFeature]dnsserver'
        }
        xSMBShare HR
        {
            Name = 'HR'
            Path = 'C:\sambashare\HR'
            FullAccess = 'Administrator'
            ReadAccess = 'shutterup.local\shutterupAD001$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]HR'
        }
        xSMBShare Marketing
        {
            Name = 'Marketing'
            Path = 'C:\sambashare\Marketing'
            FullAccess = 'Administrator'
            ReadAccess = 'shutterup.local\shutterupAD001$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]Marketing'
        }
        xSMBShare Productie
        {
            Name = 'Productie'
            Path = 'C:\sambashare\productie'
            FullAccess = 'Administrator'
            ReadAccess = 'shutterup.local\shutterupAD001$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]Productie'
        }
        xSMBShare Onderzoek
        {
            Name = 'Onderzoek'
            Path = 'C:\sambashare\Onderzoek'
            FullAccess = 'Administrator'
            ReadAccess = 'shutterup.local\shutterupAD001$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]Onderzoek'
        }
        xSMBShare Logistiek
        {
            Name = 'Logistiek'
            Path = 'C:\sambashare\Logistiek'
            FullAccess = 'Administrator'
            ReadAccess = 'shutterup.local\shutterupAD001$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]Logistiek'
        }
        WindowsFeature WebServer
        {
            Ensure = "Present"
            Name   = "Web-Server"
            dependson= '[ADDomain]shutterup.local'
        }
        File WebsiteContent 
        {
            Ensure = 'Present'
            SourcePath = 'C:\Users\Administrator\index.htm'
            DestinationPath = 'C:\inetpub\wwwroot\'
            DependsOn='[WindowsFeature]WebServer'
        }
        Firewall enablefirewallwebsite
        {
            Name= 'IIS-WebServerRole-HTTP-In-TCP'
            Ensure= 'Present'
            Enabled= 'True'
            DependsOn='[file]websitecontent'
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
ADDomain_NewForest_Config -ConfigurationData $cd -MachineName -wait -verbose -force



