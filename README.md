# Ubuntu-config
My ubuntu config (from Ubuntu Desktop). Configure & Update Ubuntu

**Works only with Ubuntu Desktop with GNOME desktop environment.**


Ma configuration de Ubuntu (base Ubuntu Desktop). Configure & Met à jour Ubuntu

**Ne fonctionne qu'avec Ubuntu Desktop disposant de l'environnement de bureau GNOME.**



# Manuel FRANÇAIS

## Liste des fichiers

 **ubuntu-config.sh** : Script principal 
 
 **gnome.list** : Fichier de paquets à ajouter ou retirer pour personnaliser GNOME (thèmes et extensions)

 **packages.list** : Fichier de paquets à ajouter ou retirer du système

 **flatpak.list** : Fichier de flatpak à ajouter ou retirer du système

 **snap.list** : Fichier de snap à ajouter ou retirer du système

 **appimage.list** : Fichier de appimage à ajouter ou retirer du système


## Fonctionnement

Tous les fichiers mentionnés ci-dessus doivent être dans le même dossier.

Exécuter avec les droits de super-utilisateur le scipt principal :

    ./ubuntu-config.sh

Celui-ci peut être exécuté plusieurs fois de suite. Si des étapes sont déjà configurées, elles ne le seront pas à nouveau. De fait, le script peut être utilisé pour : 

 - Réaliser la configuration initiale du système
 - Mettre à jour la configuration du système
 - Effectuer les mises à jour des paquets

Il est possible de faire uniquement une vérification des mises à jour (listing des paquets et flatpak à mettre à jour sans appliquer de modifications) via l'option check : 

    ./ubuntu-config.sh check


## Opérations réalisées par le script

Le script lancé va effectuer les opérations suivantes : 

 1. Refresh du cache apt
 2. Vérification de Mises à jour disponibles DEB
 3. Vérification de Mises à jour les paquets flatpak + *Proposition de redémarrage du système si nécessaire*
 4. Mise à jour du système de paquets
 5. Mise à jour du système SNAP
 6. Mise à jour du système FLATPAK
 7. Vérification configuration des dépôts et répertoires
 8. Vérification composants GNOME
 9. Gestion des paquets SNAP
 10. Gestion des paquets DEB
 11. Gestion des paquets FLATPAK
 12. Gestion des paquets APPIMAGE
 13. Configuration générale de GNOME
 14. Nettoyage + *Proposition de redémarrage du système si nécessaire*

