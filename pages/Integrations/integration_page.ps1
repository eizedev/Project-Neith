﻿$ADCard =  New-UDInput -Title "AD Info" -Content {
                New-UDInputField -type textbox -Name DomainName -Placeholder "Domain Name"
                New-UDInputField -type textbox -Name Username -Placeholder "Username"
                New-UDInputField -type textbox -Name Password -Placeholder "Password"
    } -Endpoint {
            param($DomainName,$Username,$Password)
            $TemplateType = "AD"
            $Varname = "ADPage"
            New-UDInputAction -Content @(
                Invoke-Sqlcmd -ServerInstance 'localhost' -Database 'ultimateDashboard' -Query "update template_configs set active = 'yes', variablename = '$Varname', username = '$Username', password = '$Password', domainname = '$Domainname' where template_name = '$TemplateType'"
                New-UDCard -Title "New Pages Generated" -Text "$DomainName, $Username, $Password"
     )}

$CylanceCard =  New-UDInput -Title "Cylance Info" -Content {
                New-UDInputField -type textbox -Name APIkey -Placeholder "API Key"
    } -Endpoint {
            param($apikey,$secretkey)
            $TemplateType = "Cylance"
            $Varname = "CylancePage"
            New-UDInputAction -Content @(
                Invoke-Sqlcmd -ServerInstance 'localhost' -Database 'ultimateDashboard' -Query "UPDATE template_configs SET active = 'yes', variablename = '$Varname', apikey = '$apikey'  WHERE template_name = '$TemplateType'"
                New-UDCard -Title "Data Saved to Database" -Text "$apikey, CylanceCard"
     )}

$VMwareCard =  New-UDInput -Title "VMWare Info" -Content {
                New-UDInputField -type textbox -Name UserName -Placeholder "Username"
                New-UDInputField -type textbox -Name Password -Placeholder "Password"
                New-UDInputField -type textbox -Name ClusterName -Placeholder "vCenterName"
    } -Endpoint {
            param($UserName,$Password,$ClusterName)
            $TemplateType = "VMware"
            $Varname = "VMwarePage"
            New-UDInputAction -Content @(
                Invoke-Sqlcmd -ServerInstance 'localhost' -Database 'ultimateDashboard' -Query "update template_configs set active = 'yes', username = '$Username', variablename = '$Varname', password = '$Password', clustername = '$vCenterName' where template_name = '$TemplateType'"
                New-UDCard -Title "New Pages Generated" -Text "$UserName, $Password, $vCenterName"
     )}

$Integrations= @{AD=@('integration for active directory domain');Cylance=@('integration for cylance tenant');VMWare=@('Integration for VMware technology.')} #Select integration_names from integrations
$templateArray = $Integrations.keys
$pageArray = @{AD=$ADCard;Cylance=$CylanceCard;VMware=$VMwareCard}


$TemplatePage = New-UDPage -Name "Configure New Integration" -Content {
    New-UDInput -Title "Template Selector" -Content {
        New-UDInputField -type select -Name TemplateType -Values @($Integrations.keys) -DefaultValue "AD"
    } -Endpoint {
        param($TemplateType) 
        New-UDInputAction -Content @(
            $pageArray.item($TemplateType)
        )
    }
}

