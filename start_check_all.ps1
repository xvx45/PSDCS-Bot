<#
.SYNOPSIS
  Supervision, notifications et actions sur instances DCS World
.DESCRIPTION
  Supervision, notifications Discord et actions sur instances DCS World. Necessite PSDicord pour fonctionner
  Créé et testé sur Powershell 5.0 sous Windows 2012 R2
.NOTES
  Version:        2.0
  Author:         xvx45
  Creation Date:  11/05/2020
  Purpose/Change: Réecriture complète
#>


#----------------------------------------------------------[Declarations]----------------------------------------------------------
$here = $PSScriptRoot
$conf = (Get-Content "$here\config.json" -Raw -Encoding UTF8 | ConvertFrom-Json)

$itt = 0
$debug = $conf.notifs.debug
$SendStarup = $conf.notifs.startup
$DCSExePath = $conf.dcs.ExePath
$DCSPath = $conf.dcs.Path
$ipserver = $conf.dcs.server
$portI1 = $conf.dcs.port1
$portI2 = $conf.dcs.port2
$portI3 = $conf.dcs.port3
$UriProd = $conf.webhook.Prod | Out-String
$UriDebug = $conf.webhook.Debug
$AvatarName = $conf.webhook.AvatarName
$Author = Invoke-Expression $conf.webhook.Author
$AvatarGreen = $conf.webhook.Green
$AvatarOrange = $conf.webhook.Orange
$AvatarRed = $conf.webhook.Red
$AvatarBlue = $conf.webhook.Blue
$target1 = $conf.dcs.target1
$target2 = $conf.dcs.target2
$target3 = $conf.dcs.target3
$Json1 = $conf.JSON.json1
$Json2 = $conf.JSON.json2
$Json3 = $conf.JSON.json3


#-----------------------------------------------------------[Fonctions]------------------------------------------------------------
# Fonction d'envoi
Function Send($title, $nFacts)
{
	switch($title)
	{
		"evt" {
			$Se = "Evenements"
            $color = "Orange"
		}
		"up" {
			$Se = "Informations"
            $color = "Green"
		}
		"inf" {
			$Se = "Informations"
            $color = "Blue"
		}
		"err" {
			$Se = "Erreurs"
            $color = "Red"
		}
	}
	switch($nFacts)
	{
		"1" {
			$ct = $Fact
		}
		"2" {
			$ct = $Fact, $Fact2
		}
		"3" {
			$ct = $Fact, $Fact2, $Fact3
		}
	}
	switch($color)
	{
		"Green" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarGreen
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarGreen
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarGreen
			}
		}
		"Orange" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarOrange
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarOrange
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarOrange
			}
		}
		"Red" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarRed
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarRed
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarRed
			}
		}
		"Blue" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author	
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarBlue
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarBlue
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author	
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarBlue
			}
		}		
	}
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------
## DEMARRAGE DES INSTANCES
# Si aucun process DCS détécté
if(!(Get-Process -Name "DCS")) {

	if($SendStarup -eq 1) {
# Envoi notif Discord
		$Fact = New-DiscordFact -Name 'CAUCASE' -Value 'Demarrage' -Inline $false
		$Fact2 = New-DiscordFact -Name 'PG' -Value 'Demarrage' -Inline $false
		$Fact3 = New-DiscordFact -Name 'WWII' -Value 'Demarrage' -Inline $false
		Send "inf" "3"
	}
	
# Démarrage des instances DCS
	Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender"" -WorkingDirectory $DCSPath"
	start-sleep -s 60
	Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w $target2"" -WorkingDirectory $DCSPath"
	start-sleep -s 60
	Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w $target3"" -WorkingDirectory $DCSPath"
	start-sleep -s 60

# Vérification du démarrage des instances et création contenu notif Discord
	$sI1 = 0
	$sI2 = 0
	$sI3 = 0
	$connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
	if (!($connectionI1.tcpTestSucceeded -eq "True")) {
		Start-Sleep 30
		$connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
		if (!($connectionI1.tcpTestSucceeded -eq "True")) {
			$Fact = New-DiscordFact -Name 'CAUCASE' -Value 'L''instance reste hors-ligne depuis plusieurs minutes' -Inline $false
			$sI1 = 1
		}
	}
	$connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
	if (!($connectionI2.tcpTestSucceeded -eq "True")) {
		Start-Sleep 30
		$connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
		if (!($connectionI2.tcpTestSucceeded -eq "True")) {
			$Fact2 = New-DiscordFact -Name 'PG' -Value 'L''instance reste hors-ligne depuis plusieurs minutes' -Inline $false
			$sI2 = 1
		}
	}
	$connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
	if (!($connectionI3.tcpTestSucceeded -eq "True")) {
		Start-Sleep 30
		$connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
		if (!($connectionI3.tcpTestSucceeded -eq "True")) {
			$Fact3 = New-DiscordFact -Name 'WWII' -Value 'L''instance reste hors-ligne depuis plusieurs minutes' -Inline $false
			$sI3 = 1
		}
	}
	
# Composition et envoi notif Discord
	if($sI1 -eq 1 -or $sI2 -eq 1 -or $sI3 -eq 1) {
		Send "evt" "1"
	} else {
		$getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		$getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		$getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		$MissionI1 = $getI1.mission.name
		$MissionI2 = $getI2.mission.name
		$MissionI3 = $getI3.mission.name
		$Fact = New-DiscordFact -Name 'CAUCASE' -Value "En ligne
Mission actuelle : $MissionI1" -Inline $false
		$Fact2 = New-DiscordFact -Name 'PG' -Value "En ligne
Mission actuelle : $MissionI2" -Inline $false
		$Fact3 = New-DiscordFact -Name 'WWII' -Value "En ligne
Mission actuelle : $MissionI3" -Inline $false
		Send "up" "3"
	}
}


# TESTS DES INSTANCES
while(1) {

#Definition des process
    $ProcessI1 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target1 }
    $ProcessI2 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target2 }
    $ProcessI3 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target3 }
#Definition des CPU par process
    $ProcessI1.ProcessorAffinity=9
    $ProcessI2.ProcessorAffinity=2
    $ProcessI3.ProcessorAffinity=4


# Test process CAUCASE et reboot si absent
    if (!($ProcessI1.Id)) { 
        $Fact = New-DiscordFact -Name 'CAUCASE' -Value 'Instance introuvable' -Inline $false
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender"" -WorkingDirectory $DCSPath"
        $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
        Send "err" "2"
        Start-Sleep 60
        $ProcessI1 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target1 }
# Test disponibilité CAUCASE après reboot = 
        $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
        if ($connectionI1.tcpTestSucceeded -eq "True") {
			$getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
			$MissionI1 = $getI1.mission.name
            $Fact = New-DiscordFact -Name 'CAUCASE' -Value "En ligne
Mission actuelle : $MissionI1" -Inline $false
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $Fact = New-DiscordFact -Name 'CAUCASE' -Value 'L''instance est toujours hors ligne apres 2mn un probleme arrive' -Inline $false
                    break
                }
                else {
                    $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
                    if ($connectionI1.tcpTestSucceeded -eq "True") {
                        $Co = 1
                        $getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
			            $MissionI1 = $getI1.mission.name
						$Fact = New-DiscordFact -Name 'CAUCASE' -Value "En ligne
Mission actuelle : $MissionI1" -Inline $false
                    }
                    else {
                        Start-Sleep 5
                        $Co = 0
                        $tent++
                    }
                }
            }
        }
# Envoi notif Discord
        Send "up" "1"
    }

	
# Test process PG et reboot si absent
    if (!($ProcessI2.Id)) { 
        $Fact = New-DiscordFact -Name 'PG' -Value 'Instance introuvable' -Inline $false
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w PG"" -WorkingDirectory $DCSPath"
        $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
        Send "err" "2"
        Start-Sleep 60
        $ProcessI2 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target2 }
# Test disponibilité PG après reboot
        $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
        if ($connectionI2.tcpTestSucceeded -eq "True") {
			$getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
			$MissionI2 = $getI2.mission.name
            $Fact = New-DiscordFact -Name 'PG' -Value "En ligne
Mission actuelle : $MissionI2" -Inline $false
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $Fact = New-DiscordFact -Name 'PG' -Value 'L''instance est toujours hors ligne apres 2mn un probleme arrive' -Inline $false
                    break
                }
                else {
                    $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
                    if ($connectionI2.tcpTestSucceeded -eq "True") {
                        $Co = 1
						$getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
						$MissionI2 = $getI2.mission.name
                        $Fact = New-DiscordFact -Name 'PG' -Value "En ligne
Mission actuelle : $MissionI2" -Inline $false
                    }
                    else {
                        Start-Sleep 5
                        $Co = 0
                        $tent++
                    }
                }
            }
        }
# Envoi notif Discord
        Send "up" "1"
    }


# Test process WWII et reboot si absent
    if (!($ProcessI3.Id)) { 
        $Fact = New-DiscordFact -Name 'WWII' -Value 'Instance introuvable' -Inline $false
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w wwii"" -WorkingDirectory $DCSPath"
        $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
        . Send "err" "2"
        Start-Sleep 60
        $ProcessI3 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target3 }
		
# Test disponibilité WWII après reboot
        $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI2
        if ($connectionI3.tcpTestSucceeded -eq "True") {
			$getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
			$MissionI3 = $getI3.mission.name
            $Fact = New-DiscordFact -Name 'WWII' -Value "En ligne
Mission actuelle : $MissionI3" -Inline $false
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $Fact = New-DiscordFact -Name 'WWII' -Value 'L''instance est toujours hors ligne apres 2mn un probleme arrive' -Inline $false
                    break
                }
                else {
                    $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
                    if ($connectionI3.tcpTestSucceeded -eq "True") {
                        $Co = 1
                        $getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
						$MissionI3 = $getI3.mission.name
						$Fact = New-DiscordFact -Name 'WWII' -Value "En ligne
Mission actuelle : $MissionI3" -Inline $false
                    }
                    else {
                        Start-Sleep 5
                        $Co = 0
                        $tent++
                    }
                }
            }
        }
		
# Envoi notif Discord
        Send "up" "1"
    }
	

# Test Ne Répond Pas et recheck après 30s et reboot
    if( -not ($ProcessI1.MainWindowHandle -and $ProcessI1.Responding)) {
		Start-Sleep 30
		if( -not ($ProcessI1.MainWindowHandle -and $ProcessI1.Responding)) {
            $Fact = New-DiscordFact -Name 'CAUCASE' -Value 'Instance figee, force kill' -Inline $false
            $ProcessI1.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender"" -WorkingDirectory $DCSPath"
            $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
            Send "evt" "2"
            Start-Sleep 60
			
# Test disponibilité CAUCASE après reboot
            $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
            if ($connectionI1.tcpTestSucceeded -eq "True") 
            {
				$getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
				$MissionI1 = $getI1.mission.name
                $Fact = New-DiscordFact -Name 'CAUCASE' -Value "En ligne
Mission actuelle : $MissionI1" -Inline $false
            }
            else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $Fact = New-DiscordFact -Name 'CAUCASE' -Value 'L''instance est toujours hors ligne apres 2mn un probleme est arrive' -Inline $false
                        break
                    }
                    else {
                        $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
                        if ($connectionI1.tcpTestSucceeded -eq "True") {
                            $Co = 1
                         	$getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
							$MissionI1 = $getI1.mission.name
							$Fact = New-DiscordFact -Name 'CAUCASE' -Value "En ligne
Mission actuelle : $MissionI1" -Inline $false
                        }
                        else {
                            Start-Sleep 5
                            $Co = 0
                            $tent++
                        }
                    }
                }
            }
			
# Envoi notif Discord
			Send "up" "1"
		}
    }

	
# Test Ne Répond Pas et recheck après 30s et reboot
    if( -not($ProcessI2.MainWindowHandle -and $ProcessI2.Responding)) {
		Start-Sleep 30
		if( -not($ProcessI2.MainWindowHandle -and $ProcessI2.Responding)) {
            $Fact = New-DiscordFact -Name 'PG' -Value 'Instance figee, force kill' -Inline $false
            $ProcessI2.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w PG"" -WorkingDirectory $DCSPath"
            $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
            Send "evt" "2"
            Start-Sleep 60
			
# Test disponibilité PG après reboot
            $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
            if ($connectionI2.tcpTestSucceeded -eq "True") 
            {
				$getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
				$MissionI2 = $getI2.mission.name
                $Fact = New-DiscordFact -Name 'PG' -Value "En ligne
Mission actuelle : $MissionI2" -Inline $false
            }
            else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $Fact = New-DiscordFact -Name 'PG' -Value 'L''instance est toujours hors ligne apres 2mn un probleme arrive' -Inline $false
                        break
                    }
                    else {
                        $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
                        if ($connectionI2.tcpTestSucceeded -eq "True") {
                            $Co = 1
                            $getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
							$MissionI2 = $getI2.mission.name
							$Fact = New-DiscordFact -Name 'PG' -Value "En ligne
Mission actuelle : $MissionI2" -Inline $false
                        }
                        else {
                            Start-Sleep 5
                            $Co = 0
                            $tent++
                        }
                    }
                }
            }
			
# Envoi notif Discord
        Send "up" "1"
		}
	}
	

# Test Ne Répond Pas, recheck après 30s et reboot
    if( -not($ProcessI3.MainWindowHandle -and $ProcessI3.Responding)) {
		Start-Sleep 30
		if( -not($ProcessI3.MainWindowHandle -and $ProcessI3.Responding)) {
            $Fact = New-DiscordFact -Name 'WWII' -Value 'Instance figee, force kill' -Inline $false
            $ProcessI3.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w wwii"" -WorkingDirectory $DCSPath"
            $Fact2 = New-DiscordFact -Name 'reboot' -Value 'Redemarrage de l''instance' -Inline $false
            Send "evt" "2"
            Start-Sleep 60
			
# Test disponibilité WWII après reboot
            $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI2
            if ($connectionI3.tcpTestSucceeded -eq "True") {
				$getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
				$MissionI3 = $getI3.mission.name
                $Fact = New-DiscordFact -Name 'WWII' -Value "En ligne
Mission actuelle : $MissionI3" -Inline $false
            } else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $Fact = New-DiscordFact -Name 'WWII' -Value 'L''instance est toujours hors ligne apres 2mn un probleme arrive' -Inline $false
                        break
                    }
                    else {
                        $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
                        if ($connectionI3.tcpTestSucceeded -eq "True") {
                            $Co = 1
                            $getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
							$MissionI3 = $getI3.mission.name
							$Fact = New-DiscordFact -Name 'WWII' -Value "En ligne
Mission actuelle : $MissionI3" -Inline $false
                        }
                        else {
                            Start-Sleep 5
                            $Co = 0
                            $tent++
                        }
                    }
                }
            }
			
# Envoi notif Discord
        Send "up" "1"
		}
	}
	

# Détéction changement de mission
    $getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
    $getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
    $getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
    $MissionI1comp = $getI1.mission.name
    $MissionI2comp = $getI2.mission.name
    $MissionI3comp = $getI3.mission.name
    if(!($itt -eq 0))
    {
        if(!($MissionI1comp -eq $MissionI1))
        {
            $Fact = New-DiscordFact -Name 'CAUCASE : Changement de mission' -Value "Ancienne mission : $MissionI1
Nouvelle mission : $MissionI1comp" -Inline $false
            Send "inf" "1"
            $MissionI1 = $MissionI1comp
        }
        if(!($MissionI2comp -eq $MissionI2))
        {
            $Fact = New-DiscordFact -Name 'PG : Changement de mission' -Value "Ancienne mission : $MissionI2
Nouvelle mission : $MissionI2comp" -Inline $false
            Send "inf" "1"
            $MissionI2 = $MissionI2comp
        }
        if(!($MissionI3comp -eq $MissionI3))
        {
            $Fact = New-DiscordFact -Name 'WWII : Changement de mission' -Value "Ancienne mission : $MissionI3
Nouvelle mission : $MissionI3comp" -Inline $false
            Send "inf" "1"
            $MissionI3 = $MissionI3comp
        }
    } else {
        $MissionI1 = $MissionI1comp
        $MissionI2 = $MissionI2comp
        $MissionI3 = $MissionI3comp
    }

# TEMPORISATION BOUCLE
$itt++
Start-Sleep 30
}$Uri