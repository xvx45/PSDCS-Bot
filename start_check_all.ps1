<#
.SYNOPSIS
  Supervision, notifications et actions sur instances DCS World
.DESCRIPTION
  Supervision, notifications Discord et actions sur instances DCS World. Necessite PSDicord pour fonctionner
  Créé et testé sur Powershell 5.0 sous Windows 2012 R2
.NOTES
  Version:        2.5
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
$startupI1 = $conf.notifs.startupI1
$startupI2 = $conf.notifs.startupI2
$startupI3 = $conf.notifs.startupI3
$longI1 = $conf.notifs.longI1
$longI2 = $conf.notifs.longI2
$longI3 = $conf.notifs.longI3
$OnlineI1 = $conf.notifs.OnlineI1
$OnlineI2 = $conf.notifs.OnlineI2
$OnlineI3 = $conf.notifs.OnlineI3
$NoI1 = $conf.notifs.NoI1
$NoI2 = $conf.notifs.NoI2
$NoI3 = $conf.notifs.NoI3
$HangI1 = $conf.notifs.HangI1
$HangI2 = $conf.notifs.HangI2
$HangI3 = $conf.notifs.HangI3
$ChangeI1 = $conf.notifs.ChangeI1
$ChangeI2 = $conf.notifs.ChangeI2
$ChangeI3 = $conf.notifs.ChangeI3
$NoI_Reboot = $conf.notifs.NoI_Reboot
$DCSExePath = $conf.dcs.ExePath
$DCSPath = $conf.dcs.Path
$ipserver = $conf.dcs.server
$portI1 = $conf.dcs.port1
$portI2 = $conf.dcs.port2
$portI3 = $conf.dcs.port3
$UriProd = $conf.webhook.Prod
$UriDebug = $conf.webhook.Debug
$AvatarNameGreen = $conf.webhook.AvatarNameGreen
$AvatarNameOrange = $conf.webhook.AvatarNameOrange
$AvatarNameRed = $conf.webhook.AvatarNameRed
$AvatarNameBlue = $conf.webhook.AvatarNameBlue
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
# Fonction composition Facts
Function Facts($when)
{
    switch($when)
    {
        "startup" {
            $script:Fact = Invoke-Expression "$startupI1"
            $script:Fact2 = Invoke-Expression "$startupI2"
            $script:Fact3 = Invoke-Expression "$startupI3"
        }
        "long" {
            if($sI1 -eq 1) { $script:Fact = Invoke-Expression "$longI1" }
            if($sI2 -eq 1) { $script:Fact = Invoke-Expression "$longI2" }
            if($sI3 -eq 1) { $script:Fact = Invoke-Expression "$longI3" }
        }
        "online" {
            if($case -eq "all")
            {
                $getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		        $getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		        $getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
		        $script:MissionI1 = $getI1.mission.name
		        $script:MissionI2 = $getI2.mission.name
                $script:MissionI3 = $getI3.mission.name
                $script:Fact = Invoke-Exporession "$OnlineI1"
                $script:Fact2 = Invoke-Exporession "$OnlineI2"
                $script:Fact3 = Invoke-Exporession "$OnlineI3"
            }
            if($case -eq 1)
            {
                $getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
                $script:MissionI1 = $getI1.mission.name
                $script:Fact = Invoke-Exporession "$OnlineI1"
            }
            if($case -eq 2)
            {
                $getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
                $script:MissionI2 = $getI2.mission.name
                $script:Fact = Invoke-Exporession "$OnlineI2"
            }
            if($case -eq 3)
            {
                $getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
                $script:MissionI3 = $getI3.mission.name
                $script:Fact = Invoke-Expression "$OnlineI3"
            }
        }
        "NoI1" {
            $script:Fact = Invoke-Expression "$NoI1"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "NoI2" {
            $script:Fact = Invoke-Expression "$NoI2"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "NoI3" {
            $script:Fact = Invoke-Expression "$NoI3"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "HangI1" {
            $script:Fact = Invoke-Expression "$HangI1"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "HangI2" {
            $script:Fact = Invoke-Expression "$HangI2"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "HangI3" {
            $script:Fact = Invoke-Expression "$HangI3"
            $script:Fact2 = Invoke-Expression "$NoI_Reboot"
        }
        "ChangeI1" {
            $script:Fact = Invoke-Expression "$ChangeI1"
        }
        "ChangeI2" {
            $script:Fact = Invoke-Expression "$ChangeI2"
        }
        "ChangeI3" {
            $script:Fact = Invoke-Expression "$ChangeI3"
        }
    }
}


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
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarNameGreen -AvatarUrl $AvatarGreen
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameGreen -AvatarUrl $AvatarGreen
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameGreen -AvatarUrl $AvatarGreen
			}
		}
		"Orange" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarNameOrange -AvatarUrl $AvatarOrange
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameOrange -AvatarUrl $AvatarOrange
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameOrange -AvatarUrl $AvatarOrange
			}
		}
		"Red" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarNameRed -AvatarUrl $AvatarRed
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameRed -AvatarUrl $AvatarRed
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameRed -AvatarUrl $AvatarRed
			}
		}
		"Blue" {
			if(!($debug -eq 1)) {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author	
				Send-DiscordMessage -WebHookUrl $UriProd -Sections $Section -AvatarName $AvatarNameBlue -AvatarUrl $AvatarBlue
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameBlue -AvatarUrl $AvatarBlue
			} else {
				$Section = New-DiscordSection -Title $Se -Description '' -Facts $ct -Color $color -Author $Author	
				Send-DiscordMessage -WebHookUrl $UriDebug -Sections $Section -AvatarName $AvatarNameBlue -AvatarUrl $AvatarBlue
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
        Facts "startup"
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
            $sI1 = 1
            Facts "long"
            $sI1 = $null
		}
	}
	$connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
	if (!($connectionI2.tcpTestSucceeded -eq "True")) {
		Start-Sleep 30
		$connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
		if (!($connectionI2.tcpTestSucceeded -eq "True")) {
            $sI2 = 1
            Facts "long"
            $sI2 = $null
		}
	}
	$connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
	if (!($connectionI3.tcpTestSucceeded -eq "True")) {
		Start-Sleep 30
		$connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
		if (!($connectionI3.tcpTestSucceeded -eq "True")) {
            $sI3 = 1
            Facts "long"
            $sI3 = $null
		}
	}
# Composition et envoi notif Discord
	if($sI1 -eq 1 -or $sI2 -eq 1 -or $sI3 -eq 1) {
		Send "evt" "1"
	} else {
        $case = "all"
        Facts "online"
        Send "up" "3"
        $case = $null
	}
}
$getI1 = Invoke-Expression "(Get-Content $Json1 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
$getI2 = Invoke-Expression "(Get-Content $Json2 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
$getI3 = Invoke-Expression "(Get-Content $Json3 -Raw -Encoding UTF8 | ConvertFrom-Json).2"
$MissionI1 = $getI1.mission.name
$MissionI2 = $getI2.mission.name
$MissionI3 = $getI3.mission.name

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
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender"" -WorkingDirectory $DCSPath"
        Facts "NoI1"
        Send "err" "2"
        Start-Sleep 60
        $ProcessI1 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target1 }
# Test disponibilité CAUCASE après reboot
        $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
        if ($connectionI1.tcpTestSucceeded -eq "True") {
            $case = 1
            Facts "online"
            $case = $null
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $sI1 = 1
                    Facts "long"
                    $sI1 = $null
                    break
                }
                else {
                    $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
                    if ($connectionI1.tcpTestSucceeded -eq "True") {
                        $Co = 1
                        $case = 1
                        Facts "online"
                        $case = $null
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
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w PG"" -WorkingDirectory $DCSPath"
        Facts "NoI2"
        Send "err" "2"
        Start-Sleep 60
        $ProcessI2 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target2 }
# Test disponibilité PG après reboot
        $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
        if ($connectionI2.tcpTestSucceeded -eq "True") {
            $case = 2
            Facts "online"
            $case = $null
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $sI2 = 1
                    Facts "long"
                    $sI2 = $null
                    break
                }
                else {
                    $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
                    if ($connectionI2.tcpTestSucceeded -eq "True") {
                        $Co = 1
						$case = 2
                        Facts "online"
                        $case = $null
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
        Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w wwii"" -WorkingDirectory $DCSPath"
        Facts "NoI3"
        Send "err" "2"
        Start-Sleep 60
        $ProcessI3 = Get-Process | Where-Object { $_.MainWindowTitle -eq $target3 }
# Test disponibilité WWII après reboot
        $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI2
        if ($connectionI3.tcpTestSucceeded -eq "True") {
			$case = 3
            Facts "online"
            $case = $null
        }
        else {
            $Co = 0
            $tent = 0
            While($Co -eq 0)
                {
                if($tent -eq 10) {
                    $sI3 = 1
                    Facts "long"
                    $sI3 = $null
                    break
                }
                else {
                    $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
                    if ($connectionI3.tcpTestSucceeded -eq "True") {
                        $Co = 1
                        $case = 3
                        Facts "online"
                        $case = $null
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
            $ProcessI1.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender"" -WorkingDirectory $DCSPath"
            Facts "HangI1"
            Send "evt" "2"
            Start-Sleep 60
# Test disponibilité CAUCASE après reboot
            $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
            if ($connectionI1.tcpTestSucceeded -eq "True") 
            {
                $case = 1
                Facts "online"
                $case = $null
            }
            else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $sI1 = 1
                        Facts "long"
                        $sI1 = $null
                        break
                    }
                    else {
                        $connectionI1 = Test-NetConnection -ComputerName $ipserver -Port $portI1
                        if ($connectionI1.tcpTestSucceeded -eq "True") {
                            $Co = 1
                            $case = 1
                            Facts "online"
                            $case = $null
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
            $ProcessI2.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w PG"" -WorkingDirectory $DCSPath"
            Facts "HangI2"
            Send "evt" "2"
            Start-Sleep 60
# Test disponibilité PG après reboot
            $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
            if ($connectionI2.tcpTestSucceeded -eq "True") 
            {
				$case = 2
                Facts "online"
                $case = $null
            }
            else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $sI2 = 1
                        Facts "long"
                        $sI2 = $null
                        break
                    }
                    else {
                        $connectionI2 = Test-NetConnection -ComputerName $ipserver -Port $portI2
                        if ($connectionI2.tcpTestSucceeded -eq "True") {
                            $Co = 1
                            $case = 2
                            Facts "online"
                            $case = $null
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
            $ProcessI3.Kill()
            Invoke-Expression "Start-Process -FilePath $DCSExePath -ArgumentList ""--server --norender -w wwii"" -WorkingDirectory $DCSPath"
            Facts "HangI3"
            Send "evt" "2"
            Start-Sleep 60
# Test disponibilité WWII après reboot
            $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI2
            if ($connectionI3.tcpTestSucceeded -eq "True") {
				$case = 3
                Facts "online"
                $case = $null
            } else {
                $Co = 0
                $tent = 0
                While($Co -eq 0)
                {
                    if($tent -eq 10) {
                        $sI3 = 1
                        Facts "long"
                        $sI3 = $null
                        break
                    }
                    else {
                        $connectionI3 = Test-NetConnection -ComputerName $ipserver -Port $portI3
                        if ($connectionI3.tcpTestSucceeded -eq "True") {
                            $Co = 1
                            $case = 3
                            Facts "online"
                            $case = $null
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
            Facts "ChangeI1"
            Send "inf" "1"
            $MissionI1 = $MissionI1comp
        }
        if(!($MissionI2comp -eq $MissionI2))
        {
            Facts "ChangeI2"
            Send "inf" "1"
            $MissionI2 = $MissionI2comp
        }
        if(!($MissionI3comp -eq $MissionI3))
        {
            Facts "ChangeI3"
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
}