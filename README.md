# CleanupKubernetesContexts
A PowerShell script that removes old contexts from your kubectl config file. It will back up your existing config file, iterate through every cluster, 
try and run a command on the cluster in question and remove it from your config file if it can't.

If you need to be on a VPN etc to be able to access your clusters, do it first before running this script. 

A transcript is provided after execution which contains everything that was done.

## Configuration
Just one param for the script, which probably won't need to be changed. 

| Variable | Default | Description |
|-|-|-|
| `ContextPath` | `$env:HOMEDRIVE + $env:HOMEPATH + "\.kube\config"` | Location of your kubectl config file on disk. This default will work for Windows |

## How to run

Download the script and run `.\CleanupKubernetesContexts.ps1` or open in VSCode/PowerShell ISE and run that way if you prefer.

# Examples
Cut down snippets from the output transcript available after execution:

```
Backing-up existing config
Existing config backed up to C:\Users\username\.kube\config.backup
Loading contexts from kubeconfig file
There are a total of 65 contexts present in your config file, checking each
Setting context to testcluster0
Switched to context "testcluster0".
Attempting connection
Unable to connect to the server: dial tcp: lookup testcluster0-a98cc717.etc...: no such host
testcluster0 could not be reached. Removing it from config file
Setting context to testcluster1
Switched to context "testcluster1".
Attempting connection
Context testcluster1 is accessible, it will be left in config
...
...
A total of 52 inaccessible cluster(s) were removed from your config file. There were 65 prior to cleanup, a reduction of 80%!
The full list is below:
testcluster0
...
...
```
