﻿#VMware SQL Data Importer
 #$cred = Get-Credential
 #Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
 #$vcname = ""
 #$vconn = connect-viserver rbvcenter2.nthgen.nth.com -Credential $cred


$HostInfo = Get-VMHost #get-vmhostfirmware, get-vmhosthardware
$numHosts = $HostInfo.count
$ClusterCPUCount = 0
$ClusterMemTotal = 0
$ClusterDatastoreCount = 0
$VMInfo = Get-VM #get-vmguest gets ip, os, disks,
$VMCount = $VMInfo.count
$Datastores = Get-Datastore
$Datacenters = Get-Datacenter
$Clusters = Get-Cluster
$Templates = Get-Template
$Switches = Get-VirtualSwitch 
$datetime = Get-Date

Foreach ($H in $HostInfo) {
    $clusterCPUCount += $H.NumCpu
    $clusterMemTotal += $H.MemoryTotalGB
    $ClusterDatastoreCount += ($H |Select -ExpandProperty DatastoreIdList).count
    }

Set-Location SQLSERVER:\SQL\$computername\DEFAULT\databases\$dbname 

#Import VMWareHost Table
ForEach ($VMHost in $HostInfo) {
    $host_name = $VMhost.Name
    $host_power = $VMhost.State
    $connected = $VMHost.ConnectionState
    $manufacturer = $VMHost.Manufacturer
    $model = $VMHost.Model
    $num_cpu = $VMHost.NumCpu
    $MemTotalGB = $VMHost.MemoryTotalGB
    $ProcType = $VMHost.ProcessorType
    $HyperThreading = $VMHost.HyperthreadingActive
    $VMversion = $VMHost.version
    $VMBuild = $VMHost.Build
    $VMParent = $VMHost.parent
    $Net_info = $VMHost.NetworkInfo
    $DatastoreCount = ($VMHost |Select -ExpandProperty DatastoreIdList).count
    Invoke-Sqlcmd -Query "INSERT INTO vmware_hosts (host_name, power, connected, manufacturer, model, num_cpu, mem_totalgb, proc_type, hyper_threading, version, build, parent, net_info, datastore_count) 
VALUES('$host_name','$host_power','$connected','$manufacturer','$model','$num_cpu','$MemTotalGB','$ProcType','$HyperThreading','$VMversion','$VMBuild','$VMParent','$Net_info','$DatastoreCount')"
    }

#Load VMGuest Table
ForEach ($VMGuest in $VMInfo) {
    $vm_name = $VMGuest.Name
    $vm_power = $VMGuest.PowerState
    $vm_notes = $VMGuest.Notes
    $guest = $VMGuest.Guest
    $num_cpu = $VMGuest.NumCpu
    $MemTotalGB = $VMGuest.MemoryGB
    $VMHost = $VMGuest.VMHost
    $VMFolder = $VMGuest.Folder
    $VMversion = $VMGuest.Version
    $DatastoreCount = ($VMHost |Select -ExpandProperty DatastoreIdList).count
    $VMProvisionedSpace = $VMGuest.ProvisionedSpaceGB
    $VMUsedSpace = $VMGuest.UsedSpaceGB
    $VMToolsVersion =  Get-VM rbhelpdesk | Get-VMguest | select -ExpandProperty ToolsVersion
    Invoke-Sqlcmd -Query "INSERT INTO vmware_guests (host_name,power,notes,guest,num_cpu,mem_totalgb,vm_host,folder,version,datastore_count,provisioned_space,used_space,tools_version) 
VALUES('$vm_name','$vm_power','$vm_notes','$guest','$num_cpu','$MemTotalGB','$VMHost','$VMFolder','$VMversion','$DatastoreCount','$VMProvisionedSpace','$VMUsedSpace','$VMToolsVersion')"
    }

#Load VMWare Summary Table
Invoke-SqlCmd -Query "INSERT INTO vmware_summary (date, num_hosts, num_vms, num_cpu, mem_totalgb, datastore_count)
VALUES('$datetime','$numHosts','$VMCount','$clusterCPUCount','$clusterMemTotal','$ClusterDatastoreCount');"