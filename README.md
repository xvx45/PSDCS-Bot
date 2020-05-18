# PSDCS_Bot

## Description
Petit script Powershell pour automatiser sur DCS World :
* Lancement des instances
* Vérification régulière de :
** Crash de l'instance
** Hang de l'instance
** Changement de mission
* Notifications Discord des événements. 
Un crash ou un Hang amène au redémarrage de l'instance concernée. 




## Prérequis : 
* Powershell 5
* Module PSDiscord (https://github.com/EvotecIT/PSDiscord)
* Perun for DCS World (https://github.com/szporwolik/perun) ou sa version moddée disponible dans le Folder DCS si vous n'utilisez pas cette solution. 


## Remarques :
Uniquement testé et utilisé sous Windows Server 2012 Std# PSDCS_Bot

## Description :
Petit script Powershell pour automatiser sur DCS World :
* Lancement des instances
* Vérification régulière de :
  * Crash de l'instance
  * Hang de l'instance
  * Changement de mission
* Notifications Discord des événements. 
Un crash ou un Hang amène au redémarrage de l'instance concernée. 


## Prérequis : 
* Powershell 5
* Module PSDiscord (https://github.com/EvotecIT/PSDiscord)
* Perun for DCS World (https://github.com/szporwolik/perun) ou sa version moddée disponible dans le Folder DCS si vous n'utilisez pas cette solution. 


## Mise en place :
Après avoir remplis tous les pré-requis 
* Autoriser l'exécution des scripts Powershell non signés
* Automatiser l'ouverture de session Windows
* Lancer le script à l'ouverture de session
* Programmer un kill de dcs.exe ou redémarrer l'hôte régulièrement pour devancer les plantages liés aux fuites mémoire du serveur DCS


## Remarques :
Uniquement testé et utilisé sous Windows Server 2012 Std
