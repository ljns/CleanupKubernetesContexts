<#
This script can be used to clean-up old contexts from your Kubernetes config file. 

It will back up your existing config file, iterate through everything in your config file, 
try and run a command on the cluster in question and remove it from your config file if it can't.

Has one defined param of ContextPath, has a set default that will work on windows but can be provided on execution with:

    .\CleanupKubernetesContexts.ps1 -ContextPath "<path_here>"

If you need to be on a VPN etc to be able to access a cluster, do it first before running this script. 
#>

param
(
    [Parameter(Mandatory = $false, Position = 0)]
    $ContextPath = $env:HOMEDRIVE + $env:HOMEPATH + "\.kube\config"
)

Start-Transcript

Write-Host "Backing-up existing config"
Copy-Item -Path $ContextPath -Destination ($ContextPath + ".backup")
Write-Host "Existing config backed up to $ContextPath.backup"
    
Write-Host "Loading contexts from kubeconfig file"
$contexts = kubectl config get-contexts --output "name" --no-headers

# Create a list to add anything we remove for a summary at the end
$removedContexts = [System.Collections.Generic.List[string]]::new()

Write-Host "There are a total of $($contexts.Count) contexts present in your config file, checking each"
foreach ($context in $contexts)
{
    Write-Host "Setting context to $context"
    kubectl config use-context $context

    Write-Host "Attempting connection"
    kubectl get nodes *>output.txt

    if ((Get-Content output.txt) -match 'Unable to connect')
    {
        Write-Host "$context could not be reached. Removing it from config file"
        kubectl config delete-context $context
        kubectl config delete-cluster $context
        $removedContexts.Add($context)
    }
    else 
    {
        Write-Host "Context $context is accessible, it will be left in config"
    }
}

if ($removedContexts.Count -gt 0)
{
    Write-Host "A total of $($removedContexts.Count) inaccessible cluster(s) were removed from your config file. There were $($contexts.Count) prior to cleanup, a reduction of $([math]::Round((($removedContexts.Count / $contexts.Count) * 100),2))%!"
    Write-Host "The full list is below: `n"

    $removedContexts
}
else 
{
    Write-Host "There was nothing to clean up"    
}

Stop-Transcript
