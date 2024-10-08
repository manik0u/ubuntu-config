#! /usr/bin/env bash

####################
### INTRODUCTION ###
####################
## Ce script a été mis en place pour automatiser l'installation d'un PC ubuntu
## Il est utilisé pour le Framework Laptop 13 (AMD Ryzen™ 7040 Series) mais peut convenir à tout PC sous distribution Ubuntu
## Les ressources suivantes ont été utilisées pour réaliser le script
## https://github.com/aaaaadrien/fedora-config 
## https://github.com/aaaaadrien/gnome-customization
########################
### FIN INTRODUCTION ###
########################

#################
### PREREQUIS ###
#################
## Le script a besoin des droits root pour s'exécuter ##
## Des tests sont effectués dans le script pour le vérifier ##
#####################
### FIN PREREQUIS ###
#####################


#################
### VARIABLES ###
#################
LOGFILE="$HOME/ubuntu-config.log"
REP_APPLICATIONS="$HOME/Applications"
REP_APPIMAGES="$REP_APPLICATIONS/AppImages"
REP_LOCALDEBS="$REP_APPLICATIONS/LocalDEBS"
#####################
### FIN VARIABLES ###
#####################

#################
### FONCTIONS ###
#################

function check_cmd() {
	if [[ $? -eq 0 ]]; then
		echo -e "\033[32mOK\033[0m"
	else
		echo -e "\033[31mERREUR\033[0m"
	fi
}


function check_repo_file() {
	if [[ -e "/etc/apt/sources.list.d/$1" ]]; then
		return 0
	else
		return 1
	fi
}

function check_folder() {
	if [[ -d "$1" ]]; then
		return 0
	else
		return 1
	fi
}

function check_pkg() {
	echo "- - Vérification paquet $1 : "  >> "$LOGFILE"  2>&1
	sudo apt list --installed "$1" 2>/dev/null | grep "$1" >> "$LOGFILE" 2>&1
}

function add_pkg() {
	echo -n "- - - Installation paquet $1 : "
	echo -n "- - - Installation paquet $1 : "  >> "$LOGFILE"  2>&1
	sudo apt install "$1" -y -q=4 2>/dev/null | grep "Paramétrage" >> "$LOGFILE" 2>&1
}

function del_pkg() {
	echo -n "- - - Suppression paquet $1 : "
	echo -n "- - - Suppression paquet $1 : "  >> "$LOGFILE"  2>&1
	sudo apt remove "$1" -y -q=4 2>/dev/null | grep "Suppression" >> "$LOGFILE" 2>&1
}

function check_flatpak() {
	echo "- - Vérification flatpak $1 : "  >> "$LOGFILE"  2>&1
	sudo flatpak info "$1" 2>/dev/null | grep "ID" >> "$LOGFILE" 2>&1
}

function add_flatpak() {
	echo -n "- - - Installation flatpak $1 : "
	echo -n "- - - Installation flatpak $1 : "  >> "$LOGFILE"  2>&1
	sudo flatpak install flathub "$1" -y  >> "$LOGFILE" 2>&1
}

function del_flatpak() {
	echo -n "- - - Suppression flatpak $1 : "
	echo -n "- - - Suppression flatpak $1 : "  >> "$LOGFILE"  2>&1
	sudo flatpak uninstall -y "$1" >> "$LOGFILE" 2>&1
}

function check_snap() {
	echo "- - Vérification snap $1 : "  >> "$LOGFILE"  2>&1
	sudo snap info "$1" | grep "installed" >> "$LOGFILE" 2>&1
}

function add_snap() {
	echo -n "- - - Installation snap $1 : "
	echo -n "- - - Installation snap $1 : "  >> "$LOGFILE"  2>&1
	sudo snap install "$1" --classic >> "$LOGFILE" 2>&1
}

function del_snap() {
	echo -n "- - - Suppression snap $1 : "
	echo -n "- - - Suppression snap $1 : "  >> "$LOGFILE"  2>&1
	sudo snap remove "$1" >> "$LOGFILE" 2>&1
}

function check_appimage() {
	if [[ -e "$REP_APPIMAGES/$1" ]]; then
		echo -e "\nles fichiers suivants sont déjà présents : " >> "$LOGFILE"  2>&1
		sudo find "$REP_APPIMAGES/" -name "$1*" >> "$LOGFILE" 2>&1
		return 0
	else
		return 1
	fi
}

function add_appimage() {
	sudo find "$REP_APPIMAGES/" -name "$1" -exec chmod +x {} \; >> "$LOGFILE" 2>&1
	sudo find "$REP_APPIMAGES/" -name "$1" -exec chown -R $USER:$USER {} \; >> "$LOGFILE" 2>&1
}

function dl_appimage() {
	sudo wget -nd -nc -q -P "$REP_APPIMAGES" "$1" >> "$LOGFILE" 2>&1
}

function del_appimage() {
	sudo find "$REP_APPIMAGES/" -name "$1" -exec rm -rfv {} \; >> "$LOGFILE" 2>&1
}

function check_localdeb() {
	if [[ -e "$REP_LOCALDEBS/$1" ]]; then
		echo -e "\nles fichiers suivants sont déjà présents : " >> "$LOGFILE"  2>&1
		sudo find "$REP_LOCALDEBS/" -name "$1*" >> "$LOGFILE" 2>&1
		return 0
	else
		return 1
	fi
}

function add_localdeb() {
	sudo find "$REP_LOCALDEBS/" -name "$1" -exec chown -R $USER:$USER {} \; >> "$LOGFILE" 2>&1
	sudo apt install "$REP_LOCALDEBS/$1" -y -q=4 2>/dev/null | grep "Paramétrage" >> "$LOGFILE" 2>&1
}

function dl_localdeb() {
	sudo wget -nd -nc -q -P "$REP_LOCALDEBS" "$1" >> "$LOGFILE" 2>&1
}

function del_localdeb() {
	
	sudo apt remove "$1" -y -q=4 2>/dev/null | grep "Suppression" >> "$LOGFILE" 2>&1
	sudo find "$REP_LOCALDEBS/" -name "$1" -exec rm -rfv {} \; >> "$LOGFILE" 2>&1
}

function refresh_cache() {
	sudo apt update -q=2 2>/dev/null 1>> "$LOGFILE"
}

function upgrade_deb() {
	sudo apt upgrade -y -q=2 2>/dev/null 1>> "$LOGFILE"
}

function check_updates_deb() {
	sudo apt list --upgradable 2>/dev/null 1>> "$LOGFILE"
}

function clean_deb() {
	sudo apt autoremove -y -q=4 2>/dev/null | grep "Suppression" || echo "Rien à Nettoyer" >> "$LOGFILE" 2>&1
}

function check_updates_flatpak() {
	yes n | sudo flatpak update >> "$LOGFILE" 2>&1
}

function upgrade_flatpak() {
	sudo flatpak update -y >> "$LOGFILE" 2>&1
}

function upgrade_snap() {
	sudo snap refresh >> "$LOGFILE" 2>&1
}

function need_reboot() {
	if [[ -e "/var/run/reboot-required" ]]; then
		return 0
	else
		return 1
	fi
}

function ask_reboot() {
	echo -n -e "\033[5;33m/\ REDÉMARRAGE NÉCESSAIRE\033[0m\033[33m : Voulez-vous redémarrer le système maintenant ? [y/N] : \033[0m"
	read rebootuser
	rebootuser=${rebootuser:-n}
	if [[ ${rebootuser,,} == "y" ]]; then
		echo -e "\n\033[0;35m Reboot via systemd ... \033[0m"
		sleep 2
		sudo systemctl reboot
		exit
	fi
}

function ask_maj() {
	echo -n -e "\n\033[36mVoulez-vous lancer les MàJ maintenant ? [y/N] : \033[0m"
	read startupdate
	startupdate=${startupdate:-n}
	echo ""
	if [[ ${startupdate,,} == "y" ]]; then
		bash "$0"
	fi

}

function debut_script() {
	echo -e "\n##################################################################" >> "$LOGFILE"  2>&1
	echo -e "################# DEBUT : "`date +%c`" ############" >> "$LOGFILE"  2>&1
	echo -e "##################################################################" >> "$LOGFILE"  2>&1
	echo " " >> "$LOGFILE"  2>&1
}

function fin_script() {
	echo -e "\n##################################################################" >> "$LOGFILE"  2>&1
	echo -e "################# FIN : "`date +%c`" ##############" >> "$LOGFILE"  2>&1
	echo -e "##################################################################" >> "$LOGFILE"  2>&1
	echo " " >> "$LOGFILE"  2>&1

}
#####################
### FIN FONCTIONS ###
#####################


####################
### DEBUT SCRIPT ###
####################
debut_script

# Verif option
if [[ -z "$1" ]]; then
	echo "OK" > /dev/null
elif [[ "$1" == "coffee" ]] || [[ "$1" == "check" ]]; then
	echo "OK" > /dev/null
else
	echo "Usage incorrect du script :"
	echo "- $(basename $0)         : Lance la config et/ou les mises à jour"
	echo "- $(basename $0) check   : Vérifie les mises à jour disponibles et propose de les lancer"
	fin_script
	exit 1;
fi

# Easter Egg
if [[ "$1" = "coffee" ]]; then
	echo "Oui ce script fait aussi le café !"
	echo ""
	echo '    (  )   (   )  )'
	echo '     ) (   )  (  ('
	echo '     ( )  (    ) )'
	echo '     _____________'
	echo '    <_____________> ___'
	echo '    |             |/ _ \'
	echo '    |               | | |'
	echo '    |               |_| |'
	echo ' ___|             |\___/'
	echo '/    \___________/    \'
	echo '\_____________________/'
	echo ""
	echo "Impressionnant n'est ce pas !?"

	fin_script
	exit 0;
fi

# Tester si bien Ubuntu Desktop Minimal
echo -n "Vérification OS : "
echo -e "\nVérification OS"  >> "$LOGFILE" 2>&1
if ! check_pkg ubuntu-desktop-minimal; then
	check_cmd
	echo -e "\033[31mERREUR\033[0m Seul l'OS Ubuntu Destop Minimal (GNOME) est supporté !"
	echo -e "\033[31mERREUR\033[0m Seul l'OS Ubuntu Destop Minimal (GNOME) est supporté !" >> "$LOGFILE" 2>&1
	fin_script
	exit 2;
else
	check_pkg ubuntu-desktop-minimal
	check_cmd
fi

# Infos fichier log
echo -e "\033[36m"
echo "Pour suivre la progression des mises à jour : tail -f $LOGFILE"
echo -e "\033[0m"

# Date dans le log
echo '-------------------' >> "$LOGFILE"
date >> "$LOGFILE"


#################
### PROGRAMME ###
#################
ICI=$(dirname "$0")


## CAS CHECK-UPDATES
if [[ "$1" = "check" ]]; then
	echo -n "01- - Refresh du cache : "
	echo -e "\n01- - Refresh du cache : "  >> "$LOGFILE" 2>&1
	refresh_cache
	check_cmd

	echo -n "02- - Mises à jour disponibles DEB : "
	echo -e "\n02- - Mises à jour disponibles DEB : "  >> "$LOGFILE" 2>&1
	check_updates_deb
	check_cmd

	echo -n "03- - Mises à jour disponibles FLATPAK : "
	echo -e "\n03- - Mises à jour disponibles FLATPAK : "  >> "$LOGFILE" 2>&1
	check_updates_flatpak
	check_cmd

	ask_maj

	fin_script
	exit;
fi

### MAJ APT
echo -n "04- Mise à jour du système de paquets : "
echo -e "\n04- Mise à jour du système de paquets : "  >> "$LOGFILE" 2>&1
refresh_cache
upgrade_deb
check_cmd

### MAJ SNAP
echo -n "05- Mise à jour du système SNAP : "
echo -e "\n05- Mise à jour du système SNAP : " >> "$LOGFILE"  2>&1
upgrade_snap
check_cmd

### MAJ FP
echo -n "06- Mise à jour du système FLATPAK : "
echo -e "\n06- Mise à jour du système FLATPAK : "  >> "$LOGFILE"  2>&1
upgrade_flatpak
check_cmd

# Verif si reboot nécessaire
if ! need_reboot; then
	ask_reboot
fi


### CONFIG DEPOTS & Répertoires
echo "07- Vérification configuration des dépôts et répertoires"
echo -e "\n07- Vérification configuration des dépôts et répertoires"   >> "$LOGFILE"  2>&1

## Désactiver les "phases Update" https://ubuntu.com/server/docs/about-apt-upgrade-and-phased-updates 
echo -n "- - - Désactivation des phases Update : "
echo -e "\n- - - Désactivation des phases Update : "  >> "$LOGFILE"  2>&1
echo '
Update-Manager::Always-Include-Phased-Updates true;
APT::Get::Always-Include-Phased-Updates true;
' | sudo tee /etc/apt/apt.conf.d/99-Phased-Updates  >> "$LOGFILE"  2>&1
check_cmd

## SOLAAR
echo -n "- - - Installation repo SOLAAR : "
echo -e "\n- - - Installation repo SOLAAR : "  >> "$LOGFILE"  2>&1
sudo add-apt-repository -y ppa:solaar-unifying/stable | grep "sources" >> "$LOGFILE"  2>&1
check_cmd

## MOZILLA
if ! check_repo_file mozilla.list; then
	echo -n "- - - Installation Mozilla Repo : "
	sudo apt install wget -y -q=2 >> "$LOGFILE"  2>&1
	sudo install -d -m 0755 /etc/apt/keyrings >> "$LOGFILE"  2>&1
	sudo wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc  >> "$LOGFILE"  2>&1
	sudo gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}' >> "$LOGFILE"  2>&1
	echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list  >> "$LOGFILE"  2>&1
	echo -e 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla  >> "$LOGFILE"  2>&1
	check_cmd
fi

## FLATHUB
if [[ $(flatpak remotes | grep -c flathub) -ne 1 ]]; then
	echo -n "- - - Installation Flathub : "
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo  >> "$LOGFILE"  2>&1
	check_cmd
fi

## DISPLAYPORT DRIVERS
if ! check_repo_file synaptics.list; then
	echo -n "- - - Installation Synaptics Repo (Display ports drivers): "
	sudo wget -O  ./Téléchargements/synaptics-repository-keyring.deb https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb  >> "$LOGFILE"  2>&1
	sudo apt -y install ./Téléchargements/synaptics-repository-keyring.deb -q=2 >> "$LOGFILE"  2>&1
	check_cmd
fi

## Répertoires
echo -n "- - - Vérification du répertoire APPLICATIONS : "
echo -e "\n- - - Vérification du répertoire APPLICATIONS : "  >> "$LOGFILE"  2>&1
if ! check_folder $REP_APPLICATIONS; then
	echo -n "Le répertoire $REP_APPLICATIONS n'existe pas! Création : "
	echo -e "\nLe répertoire $REP_APPLICATIONS n'existe pas! Création : " >> "$LOGFILE"  2>&1
	sudo mkdir -p "$REP_APPLICATIONS" && sudo chown $USER:$USER "$REP_APPLICATIONS" && echo "Le répertoire $REP_APPLICATIONS a été créé !" >> "$LOGFILE" 2>&1
	check_cmd
else 
	echo -n "Le répertoire $REP_APPLICATIONS existe ! Rien à faire : "
	echo -e "\nLe répertoire $REP_APPLICATIONS existe ! Rien à faire : "  >> "$LOGFILE"  2>&1
	check_cmd
fi
echo -n "- - - Vérification du répertoire APPIMAGE : "
echo -e "\n- - - Vérification du répertoire APPIMAGE : "  >> "$LOGFILE"  2>&1
if ! check_folder $REP_APPIMAGES; then
	echo -n "Le répertoire $REP_APPIMAGES n'existe pas! Création : "
	echo -e "\nLe répertoire $REP_APPIMAGES n'existe pas! Création : " >> "$LOGFILE"  2>&1
	sudo mkdir -p "$REP_APPIMAGES" && sudo chown $USER:$USER "$REP_APPIMAGES" && echo "Le répertoire $REP_APPIMAGES a été créé !" >> "$LOGFILE" 2>&1
	check_cmd
else 
	echo -n "Le répertoire $REP_APPIMAGES existe ! Rien à faire : "
	echo -e "\nLe répertoire $REP_APPIMAGES existe ! Rien à faire : "  >> "$LOGFILE"  2>&1
	check_cmd
fi
echo -n "- - - Vérification du répertoire LOCALDEBS : "
echo -e "\n- - - Vérification du répertoire LOCALDEBS : "  >> "$LOGFILE"  2>&1
if ! check_folder $REP_LOCALDEBS; then
	echo -n "Le répertoire $REP_LOCALDEBS n'existe pas! Création : "
	echo -e "\nLe répertoire $REP_LOCALDEBS n'existe pas! Création : " >> "$LOGFILE"  2>&1
	sudo mkdir -p "$REP_LOCALDEBS" && sudo chown $USER:$USER "$REP_LOCALDEBS" && echo "Le répertoire $REP_LOCALDEBS a été créé !" >> "$LOGFILE" 2>&1
	check_cmd
else 
	echo -n "Le répertoire $REP_LOCALDEBS existe ! Rien à faire : "
	echo -e "\nLe répertoire $REP_LOCALDEBS existe ! Rien à faire : "  >> "$LOGFILE"  2>&1
	check_cmd
fi

## Refresh Cache
refresh_cache

### INSTALL/SUPPRESSION DEB LOCAUX SELON LISTE
echo "08- Gestion des paquets locaux DEB"
echo -e "\n08 bis- Gestion des paquets locaux DEB"  >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		url=${line#add:}
		app=${url##http*://*/}
		if ! check_localdeb "$app"; then
			echo -n "- - - Installation paquet local $app via l'url $url : "
			echo -e "\n- - - Installation paquet local $app via l'url $url : "  >> "$LOGFILE"  2>&1
			dl_localdeb "$url"
			add_localdeb "$app"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]; then
		url=${line#del:}
		app=${url##http*://*/}
		package_name=$(sudo dpkg-deb --field $REP_LOCALDEBS/$app package)
		if check_localdeb "$app"; then
			echo -n "- - - Suppression paquet local $package_name (fichier $app) via l'url $url : "
			echo -e "\n- - - Suppression paquet local $package_name (fichier $app) via l'url $url : "  >> "$LOGFILE"  2>&1
			del_localdeb "$package_name"
			check_cmd
		fi
	fi
done < "$ICI/localdeb.list"

### INSTALL/SUPPRESSION SNAP SELON LISTE
echo "09- Gestion des paquets SNAP"
echo -e "\n09- Gestion des paquets SNAP" >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		p=${line#add:}
		if ! check_snap "$p"; then
			add_snap "$p"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]; then
		p=${line#del:}
		if check_snap "$p"; then
			del_snap "$p"
			check_cmd
		fi
	fi
done < "$ICI/snap.list"

### INSTALL/SUPPRESSION DEB SELON LISTE
echo "10- Gestion des paquets DEB"
echo -e "\n10- Gestion des paquets DEB" >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		p=${line#add:}
		if ! check_pkg "$p"; then
			add_pkg "$p"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]; then
		p=${line#del:}
		if check_pkg "$p"; then
			del_pkg "$p"
			check_cmd
		fi
	fi
done < "$ICI/packages.list"
#  Ajout d'un espace pour les logs
echo -e "\n"  >> "$LOGFILE"  2>&1

### INSTALL/SUPPRESSION FLATPAK SELON LISTE
echo "11- Gestion des paquets FLATPAK"
echo -e "\n11- Gestion des paquets FLATPAK"  >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		p=${line#add:}
		if ! check_flatpak "$p"; then
			add_flatpak "$p"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]; then
		p=${line#del:}
		if check_flatpak "$p"; then
			del_flatpak "$p"
			check_cmd
		fi
	fi
done < "$ICI/flatpak.list"

### TELECHARGEMENT APPIMAGE SELON LISTE
echo "12- Gestion des paquets APPIMAGE"
echo -e "\n12- Gestion des paquets APPIMAGE"  >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		url=${line#add:}
		app=${url##http*://*/}
		if ! check_appimage "$app"; then
			echo -n "- - - Installation appimage $app via l'url $url : "
			echo -e "\n- - - Installation appimage $app via l'url $url : "  >> "$LOGFILE"  2>&1
			dl_appimage "$url"
			add_appimage "$app"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]; then
		url=${line#del:}
		app=${url##http*://*/}
		if check_appimage "$app"; then
			echo -n "- - - Suppression appimage $app via l'url $url : "
			echo -e "\n- - - Suppression appimage $app via l'url $url : "  >> "$LOGFILE"  2>&1
			del_appimage "$app"
			check_cmd
		fi
	fi
done < "$ICI/appimage.list"

### Vérif configuration système
echo "13- Configuration générale de GNOME"
echo -e "\n13- Configuration générale de GNOME"  >> "$LOGFILE"  2>&1
while read -r line
do
	if [[ "$line" == add:* ]]; then
		p=${line#add:}
		if ! check_pkg "$p"; then
			echo -n "- - - Application du paramètre GNOME - $p - : "
			$p   >> "$LOGFILE"  2>&1
			check_cmd
		fi
	fi
done < "$ICI/gnome.list"
echo "Personnalisation terminée."
echo -e "\nPersonnalisation terminée."  >> "$LOGFILE"  2>&1

### NETTOYAGE
echo "14- Nettoyage"
echo -e "\n14- Nettoyage"  >> "$LOGFILE"  2>&1

echo -n "- Nettoyage des paquets .DEB : "
echo -e "\n- Nettoyage des paquets .DEB : "  >> "$LOGFILE"  2>&1
clean_deb
check_cmd

# Verif si reboot nécessaire
if ! need_reboot; then
	ask_reboot
fi

fin_script