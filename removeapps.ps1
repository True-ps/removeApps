#not the most elegant solution, but should work on all apps that have Uninstall keys in the registries below. 
$64bitregs = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$32bitregs = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"


$allregs = Get-ItemProperty $64bitregs, $32bitregs

$pappname = $args[0] #e.g. rcnas  to remove RCNas, Splashtop Streamer to remove Splashtop Streamer, etc.
$getConfirmation = $args[1] #e.g. yes to remove. empty parameter or something else will cancel the operation. 

#gets the OS architecture. can be used as condition.
#$osarch = (Get-WmiObject win32_operatingsystem).osarchitecture

#this function uses wmi to remove an app. it's much slower than the live one.
<#
function _getApp($pappname)
{
	$appAction = Get-WmiObject Win32_Product | Where-Object {$_.Name -like $pappname}	
	$appAction.Uninstall()
	$appAction | Format-List
}
#>
function _removeApp($allregs)
{
	if (-not [string]::IsNullOrEmpty($pappname))
	{
		
			foreach ($reg in $appVersion)
			{	
				
                if ($reg.DisplayName -eq $pappname)
				{
					Write-Host "I found the following program:`nName - " $reg.DisplayName "`nPublisher -" $reg.Publisher "`nUninstall String - " $reg.UninstallString
					if ($getConfirmation -eq "yes")
					{

						Write-host "I will try to silently remove it using the uninstall string"
					
						try
						{	#this will simply...attempt to remove the app. If there are no errors, it will still count as a success.
							$remove = Start-Process msiexec.exe -ArgumentList /x, $reg.PSChildName, /qn -Wait -NoNewWindow 
							$measure = Measure-Command -Expression { $remove }
							Write-Host $reg.DisplayName "successfully removed in " $measure.TotalSeconds "seconds"
							
						}
						catch { "Beep boop! Unable to compute! Beep! " }
					}
					elseif ([string]::IsNullOrEmpty($getConfirmation)) { Write-Host "To confirm the removal of the " $reg.DisplayName " application, you must first confirm by typing `"yes`" " }
					elseif ($getConfirmation -ne "yes")
								{ Write-Host "Incorrect confirmation assignment. I got a " $getConfirmation ". You need to say `"yes`"." }
				}
			}
       }
	   elseif ([string]::IsNullOrEmpty($pappname))
	   { Write-Host "Please specify the app you want to remove." }
	}

Write-Output "OS is $osarch"
_removeApp($allregs)

#_getApp($pappname)
