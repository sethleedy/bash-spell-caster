#!/bin/bash

#Version .47
#Date: 2012/03/22

# SpellCast Linux Setup Script.

# Copy to new Linux (Currently tested -> Fedora,) install and run.

# Code Repository: https://code.google.com/p/linuxspellcaster
# Could also get from Test location: http://linuxspellcaster.googlecode.com/git/spellcast.sh
# Short URL: http://goo.gl/UEbtk

# Don't have wget ? Try curl;
# Type curl see if it works. Then:
# bash <(curl -s http://linuxspellcaster.googlecode.com/git/spellcast.sh)

###
# Create Vars; Configure below. May have to update some URLs.
###

# This is where the master copy of the script resides. This copy of the script can download the master copy to ensure it is up to date.
scripts_url="http://linuxspellcaster.googlecode.com/git/spellcast.sh"
script_file_name="spellcast.sh"

# The script will download things from a HTTP source. We can shortcut the URL for readability's sake.
#So if downloading things from public URL of dropbox. Eg: http://dl.dropbox.com/u/58771881/installs/Office-PCs/
#We can cutout the main URL path to a variable and all files will be the $variable + the path_and_filename
# Watch the slashes!
http_file_url_path="http://dl.dropbox.com/u/58771881/installs/Office-PCs/"

# This will create the ".forward" in the root account. /root/.forward
# It will allow any emails going to root to be forwarded to the system_email_monitor email address.
use_system_email_monitor=true
system_email_monitor="webmaster@example.com"

# What runlevel should this be ?
# system_runlevel="multiuser"
system_runlevel="graphical"

# Ok. What Graphical eviroment ?
system_graphical_desktop="kde"
# Future will be XFCE, Gnome, etc.
#system_graphical_desktop="gnome"

# Install List of programs:
# Basic OS stuff for running and this script.
system_install_list_basic="tail crontabs awk cut grep wget nano less tar gzip bzip2 chpasswd util-linux"

# Your desired tools and programs.
system_install_list_tools="inadyn-mt openssh-server rsync screen espeak htop iotop iftop fuse openssh-clients ntp ntpdate ntsysv glances ssh-copy-id chkconfig sendmail p7zip dkms"

# Desktop KDE Programs
system_install_list_desktop_kde_programs="firefox google-chrome-stable thunderbird libreoffice vlc cups cups-swat"

# Desktop Gnome Programs
#system_install_list_desktop_gnome_programs="firefox google-chrome-stable libreoffice vlc"

#Account Details:
# Your normal user account
account_user="tech"
account_user_password=""

# SSH key is required!
# SSH key setup is required AFTER setting up your account user! Not before.
# Set a url for downloading it. It will be added to the authorized_keys of your account user for you so you auto login

# !! Passwords will not work after reboot. !!

your_public_openssh_key_for_remote_access=""
# Personalized sshd_config file.
sshd_config=$http_file_url_path"root/etc/ssh/sshd_config"

# Use fail2ban ? Recommended!
use_fail2ban=true

# Is this a 64bit or 32bit ? What cpu type ?
cpubit=64
#cpubit=32

# Install Samba ?
use_samba=false

# Install WebMin ?
use_webmin=false

# Install ZFS-Fuse ?
use_zfs=false

# Install Java ?
use_java=false

# Install CrashPlan ?
use_crashplan=false
# Crashplan download URL
crashplan_url="http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.0.3_Linux.tgz"

# Install Dropbox ?
use_dropbox=false

# Install hekaFS ?
use_hekafs=false

# Install a LAMP system ? (Apache2, MySQL, PHP)
use_lamp=false
# Install all lamp or just something specific ?
use_all_lamp=true
#Incase just one item of a LAMP system
use_one_lamp_apache=false
use_one_lamp_mysql=false
use_one_lamp_php=false

# If importing a .sql file into MySQL. We will need a url, filename from url, username, password
#database name is needed if the .sql file cannot create the database. Make it easy on your self. Use that option on your backups!
use_mysql_import=false
mysql_import_url=$http_file_url_path"wp_sethleedy_name.sql"
mysql_use_import_database_name=false
mysql_import_database_name="wp_sethleedy_name"
mysql_import_username="root"
mysql_import_password="x86286123"
mysql_import_filename="mysql_backup.sql"

# Use inadyn-mt ?
#It allows you to update DYNDNS.Org with the computers IP address.
#Setup the information in the file beforehand of course.
use_inadyn=false
inadyn_url=$http_file_url_path"root-configs/etc/inadyn-mt.conf"

# This is the tar.bz (tar file with bzip(NOT bzip2) compression) file that we will extract a lot of files and from that, will populate the system starting from the / root directory.
#Like a whole bunch of website files. As such, the folder structure must be the same. A directory named var containing www holding all website files will be extracted to root and end up in /var/www/*
use_mass_files1=true
mass_files_url1=$http_file_url_path"mass_files1.tar.bz"
mass_file1_name="mass_files1.tar.bz"
use_mass_files2=true
mass_files_url2=$http_file_url_path"mass_files2.tar.bz"
mass_file2_name="mass_files2.tar.bz"

# Wipe the firewall clean and add; or just append to it.
wipe_firewall=true
# Should we be able to ping the machine or not.
firewall_allow_ping_in=true
# The programs can open the firewall within their functions.
#What if we only want SSH 22 ? Everything can be accessed via ssh port forwarding.
# So this exists. Ask for port opening ? If true, will ask each time a port will be opened.
# This can be ovided if the script is adjusted to NOT open ports for the programs being installed.
firewall_question_port_open=false

# Do the crontab function that puts entries into crontab ?
use_crontab=true

# I am setting this to default so I can get installs done quicker.
#You can set it so you do not have to do updates later.
system_yum_update_skip=true

# After this script runs, it would have downloaded some files.
# List the files to rm -f after the script is done.
cleanup_script_files="java.bin jre-* $mass_file1_name $mass_file2_name webmin.rpm google.repo* $mysql_import_filename atrpms* CrashPlan* crashplan*"

###
# Some functions that may need specific setting up.
###

function do_crontab {

  # I need to set some cron items

  log_and_echo " "
  log_and_echo "Set CRON items "

  # MySQL backup of entire DB Server so this script can auto restore it. Script does rotation of entries. Located in /root/scripts/
  #crontab_add_item "@hourly /root/scripts/backup_mysql.sh    #Backs up the entire MySQL Database Server for restore with my SpellCast script."
  # Webmin backup of MySQL. Does one database at a time.
  #crontab_add_item "@daily /etc/webmin/mysql/backup.pl --all"

  # Mirror the /var/www/html/ into Dropbox account to keep an up to date copy as a backup.
  # Allows restore via this script.
  #crontab_add_item "@hourly /root/scripts/sync_www_data.sh"

  

}

function auto_starts {

  chkconfig network on
  chkconfig sshd on
  chkconfig iptables on
  chkconfig xrdp on
  chkconfig webmin on

  chkconfig httpd on
  chkconfig mysqld on

}

# Used to move files around after the extraction-Logic Use
function mass_copy_system_files_arrange {

  if [ "$system_runlevel" == "graphical" ] ; then
    # moves the icon to access the program into the account users Desktop.
    cd /home/

    wget -O CrashPlan.desktop $http_file_url_path"root-configs/home/CrashPlan.desktop"
    mv /home/CrashPlan.desktop /home/$account_user/Desktop/

    cd ~
  fi

  # My Tails script.
  chown root:root /var/log/tails.sh
  chmod u+x /var/log/tails.sh

  if $use_lamp ; then
    # Proper ownership for Apache files.
    chown -R apache:apache /var/www/html/*
  fi

  # The permissions need adjusted on some files.
  chmod 0755 /etc/X11/xinit/Xsession
  chown -R root:root /etc/X11/xinit

}

###
# End - Some functions that may need specific setting up.
###

###
# End - configuring of Vars
###

###
# Functions
###

function system_yum_update {
  # Use a up to date system
  log_and_echo  " " 
  log_and_echo  "Update System before using."
  yum -y clean all

  # RPM Fusion for non free packages.
  yum -y localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm
  # RPM Fusion for free packages
  rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
  
  # DVD PlayBack
  wget http://www.mjmwired.net/resources/files/atrpms.repo
  mv -f ./atrpms.repo /etc/yum.repos.d/atrpms.repo
  rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms

  # Google Chrome webbrowser
  if [ "$cpubit" == "32" ] ; then
    wget $http_file_url_path"root/etc/yum.repos.d/google.repo.32"
    mv -f ./google.repo.32 /etc/yum.repos.d/google.repo
  fi
  if [ "$cpubit" == "64" ] ; then
    wget $http_file_url_path"root/etc/yum.repos.d/google.repo.64"
    mv -f ./google.repo.64 /etc/yum.repos.d/google.repo
  fi

  # For faster installs, we can skip system updates.
  if $system_yum_update_skip ; then
    log_and_echo "Skipping yum update and upgrade"
  else
    yum -y update
    yum -y upgrade
  fi

}

# Remove some programs.
#Usage: remove_programs "openoffice vi etc"
function remove_programs {
  yum -y remove $1
}

# Add some programs.
#Usage: add_programs "openoffice vi etc"
function add_programs {
  
  # If not set, set to install.
  if [[ -z "$2" ]] ; then
    install_type="install"
  else
    proto_type="$2"
  fi

  yum -y $install_type $1
}

# Utility to log all echos AND display to screen
function log_and_echo {
  echo $1 >> $LOG_FILE
  echo $1
}

# iptables stuff. $1 is port $2 is udp or tcp
# Open port in iptables
# Port ranges are just like iptables input; open_iptables_port lownumber1:highnumber2 tcp
function open_iptables_port {

temp_var_firewall=true

  # If not set, set to tcp.
  if [ "$2" == "" ] ; then
    proto_type="tcp"
  else
    proto_type="$2"
  fi

if $firewall_question_port_open ; then
  read_question "Open firewall port: $1 ? [true/false] " temp_var_firewall $temp_var_firewall
fi
if $temp_var_firewall ; then
  log_and_echo "Opening Port $1"
  iptables -A INPUT -p $proto_type --dport $1 -j ACCEPT
fi

}


# Add string to Crontab
function crontab_add_item {
  
  crontab -l > temp_crontab.txt
  echo "$1" >> temp_crontab.txt
  crontab temp_crontab.txt
  rm -f temp_crontab.txt

}

# inadyn tool setup
function setup_inadyn {

  log_and_echo " "
  log_and_echo "Setting up inadyn-mt."
  log_and_echo "You have set up the inadyn-mt.conf file right ?"
  cd /etc/
  wget $inadyn_url
  chkconfig inadyn on
  # Got not supported message on inadyn, so...
  chkconfig inadyn-mt on
  #echo "inadyn &" >> /etc/rc.local

  cd ~

}

# Webmin
function install_webmin {
  log_and_echo  " " 
  log_and_echo  "Installing Webmin and HTTPS add-on."
  cd ~

  # For HTTPS
  #If Webmin is not installed yet, install it. If you install SSL support first, when Webmin's setup.sh script is run it will ask you if you want to enable SSL. Just enter y. The RPM version of Webmin will always automaticlly use SSL mode if possible.
  #If Webmin is already installed, turn on SSL. In the Webmin Configuration module (under the Webmin category) an icon for SSL Encryption should appear. Click on it, and change the SSL option from Disabled to Enabled.
  yum -y install perl-Net-SSLeay
  # Webmin
  wget -O webmin.rpm http://prdownloads.sourceforge.net/webadmin/webmin-1.580-1.noarch.rpm
  # Webmin has a auto update function. Don't worry too much if the link is to a outdated version. 
  rpm -i webmin.rpm
  
  # Information for ports found here: http://doxfer.webmin.com/Webmin/WebminServersIndex
  log_and_echo "Open Firewall Port for browser access"
  open_iptables_port 10000 "tcp"
  log_and_echo "Open Firewall Port for Webmins Cluster Network scanning for other webmins"
  open_iptables_port 10000 "udp"
  log_and_echo "Open additional ports for RPC connections" # Hate to do this. Any way of restraining them to just 1 or lesser amount of ports ?
  open_iptables_port 10001:10100 "tcp"

}

# If using ZFS-Fuse
function install_zfs-fuse {
  log_and_echo  "Install ZFS-Fuse. "
  yum -y install fuse zfs-fuse

  # AutoStart
  chkconfig zfs-fuse on

}

# SSH Setup
function setup_ssh {
  log_and_echo  " " 
  log_and_echo  "SSH Server Setup."
  # 1. Personal Access
  wget -O my_public.key "$your_public_openssh_key_for_remote_access"
  # Make key, root user
  log_and_echo  "Make roots key."
  ssh-keygen -t dsa
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  
  # Copy downloaded public keys for remote access
  log_and_echo "Copy downloaded public keys for remote access to new user $account_user"
  mkdir -p /home/$account_user/.ssh/  
  touch /home/$account_user/.ssh/authorized_keys
  cat my_public.key >> /home/$account_user/.ssh/authorized_keys
  chmod 600 /home/$account_user/.ssh/authorized_keys
  chmod 700 /home/$account_user/.ssh
  chown -R $account_user:$account_user /home/$account_user/.ssh
  # Remove excess files
  log_and_echo  "Remove excess files" 
  rm -f my_public.key

  # Open Firewall Port
  open_iptables_port 22 "tcp"

  cd ~
}

# Now that the keys are there, we need to tell the new machine to accept keys instead of passwords.
#Adjust:
# RSAAuthentication no (Since we are using DSA) Also: http://www.grc.com/sn/sn-340.txt RSA not so secure anymore.
# PubkeyAuthentication yes
# AuthorizedKeysFile .ssh/authorized_keys
# and if you no longer want passwords to be used: PasswordAuthentication no
# and if you want to allow root user login: PermitRootLogin yes
function setup_ssh_keys {
  log_and_echo  "Now that the keys are there, we need to tell the new machine to accept keys instead of passwords."
  cd /etc/ssh

  wget -O new_sshd_config $sshd_config
  mv -f new_sshd_config sshd_config
  chmod 600 /etc/ssh/sshd_config
  chmod go-w ~ ~/.ssh ~/.ssh/authorized_keys /home/$account_user/.ssh/authorized_keys

  cd ~
}

# Setup fail2ban program. Allows you to ban ipaddresses via iptables temporarly that fail to login properly.
function setup_fail2ban {
  log_and_echo " "
  log_and_echo "Setting up fail2ban program."
  yum -y install fail2ban

  log_and_echo "Downloading config file for fail2ban."
  log_and_echo "You did set it up right ? jail.local within /etc/fail2ban/"
  cd /etc/fail2ban/
  wget -O jail.local $http_file_url_path"root-configs/etc/fail2ban/jail.local"
  log_and_echo "Replacing the email address with $system_email_monitor"
  sed -i 's/webmaster@example.com/'$system_email_monitor'/g' jail.local

  chown root:root jail.local
  chkconfig fail2ban on

  cd ~
}

# Setup My Personal User
function setup_personal_account {
  log_and_echo  " " 
  log_and_echo  "Setting up my user account."
  useradd $account_user
  echo "$account_user:$account_user_password" | chpasswd
}

# Forward all emails going to root to a email address
function setup_root_email_forwarding {
  log_and_echo  " " 
  log_and_echo  "Setup .forward on root account to forward all root emails to my email address.(Requires sendmail)" 

  echo $system_email_monitor > ~/.forward
}

# Setup some auto running scripts/programs on console login
function setup_personal_account_bash_profile {
  log_and_echo  " " 
  log_and_echo  "Setup .bash_profile to run things when logging in."
  
  echo $1 >> /home/$account_user/.bash_profile
}

# Setup some auto running scripts/programs on console login
function setup_root_account_bash_profile {
  log_and_echo  " " 
  log_and_echo  "Setup .bash_profile to run things when logging in."

  echo $1 >> ~/.bash_profile
}

# Dropbox account for personal user
#If you're running Dropbox on your server for the first time, you'll be asked to copy and paste a link in a working browser to create a new account or add your server to an existing account. Once you do, your Dropbox folder will be created in your home directory.
function install_dropbox_for_your_account {
  log_and_echo  " " 
  log_and_echo "Install DropBox program. You must link it to your account as soon as you can. Just copy the URL that pops up during install and paste it into a web browser. Then login with the account you wish to link."
  if [ $cpubit == "64" ] ; then
    cd /home/$account_user && wget -O - http://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -
  fi
  if [ $cpubit == "32" ] ; then
    cd /home/$account_user && wget -O - http://www.dropbox.com/download?plat=lnx.x86 | tar xzf -
  fi
  chown -R $account_user:$account_user /home/$account_user/.dropbox-dist
  #sudo -u $account_user /home/$account_user/.dropbox-dist/dropboxd &

  cd ~

  if [ "$system_runlevel" == "graphical" ] ; then
    if [ "$system_graphical_desktop" == "kde" ] ; then
      mkdir -p /home/$account_user/.kde/Autostart/
      ln -s /home/$account_user/.dropbox-dist/dropboxd /home/$account_user/.kde/Autostart/dropboxd
      chown -R $account_user:$account_user /home/$account_user/.kde

    fi
  elif [ "$system_runlevel" == "multiuser" ] ; then
    # Download and turn on the dropbox service scripts
    mkdir -p /etc/sysconfig
    cd /etc/sysconfig/
    
	touch /etc/sysconfig/dropbox
	chmod 0644 /etc/sysconfig/dropbox

    # This is what Dropbox looks at for which users have accounts active.
    #If the other accounts listed are not set up for Dropbox, it will complain. Should work though.
	#Eg: ->  echo "DROPBOX_USERS='root $account_user'" >> /etc/sysconfig/dropbox
	echo "DROPBOX_USERS='$account_user'" >> /etc/sysconfig/dropbox
	
    cd /etc/init.d/
    wget $http_file_url_path"root-configs/etc/rc.d/init.d/dropboxd"
    chmod 0755 /etc/init.d/dropboxd

    chkconfig dropboxd on
    
  fi
	
  # This is the only port we may desire open.
  #It will allow LAN Sync to work. Otherwise, a straight download
  #off the Dropbox servers is required.
  open_iptables_port 17500 "udp"
  cd ~

}

# Dropbox account for all future users
#If you're running Dropbox on your server for the first time, you'll be asked to copy and paste a link in a working browser to create a new account or add your server to an existing account. Once you do, your Dropbox folder will be created in your home directory.
function install_dropbox_for_all_users {
  log_and_echo " "
  log_and_echo "Install DropBox program for all future users by using the /etc/skel/ directory. Creating a new user should put a new .dropbox directory in the users home directory. You must link it to your account as soon as you can. Just copy the URL and paste it into a web browser. Then login with the account you wish to link."
  cp -r /home/$account_user/.dropbox-dist /etc/skel/
  chown -R root:root /etc/skel/.dropbox-dist

}

# Install GlusterFS/HekaFS
function install_hekafs {
  log_and_echo  " " 
  log_and_echo  "Install GlusterFS/HekaFS."
  add_programs "glusterfs glusterfs-server glusterfs-fuse hekafs nano openssh-clients lynx"

}
function setup_hekafs {
  log_and_echo  " " 
  log_and_echo  "Setup GlusterFS/HekaFS."

  # Open port 8080 for web admin access
  open_iptables_port 8080 tcp
  # The program ports
  open_iptables_port 24007:24029 tcp

  # For storage bricks
  chkconfig glusterfsd on
  chkconfig glusterd on
  chkconfig hekafsd on

  log_and_echo  "Access port 8080 for setup of GlusterFS/HekaFS"
}

# Used to mass copy many files to proper places.
# Such as a scp transfer of website or config files or a backup of /etc or something.
function mass_copy_system_files {
  log_and_echo  " "

  if $use_mass_files1 ; then
    log_and_echo  "Mass copy files to / (root) for OS setup"
    rm -f $mass_file1_name
    wget $mass_files_url1

    # Issue: Ownership of the extracted files are whatever they were on the Linux system that created the file.
    tar --overwrite --owner root -xf $mass_file1_name -C /
  fi
  if $use_mass_files2 ; then
    log_and_echo  "Mass copy files to / (root) for Customization setup"
    rm -f $mass_file2_name
    wget $mass_files_url2

    # Issue: Ownership of the extracted files are whatever they were on the Linux system that created the file.
    tar --overwrite --owner root -xf $mass_file2_name -C /
  fi

  cd ~

  mass_copy_system_files_arrange
}


# Install Crashplan ?
function install_crashplan {
  log_and_echo  " "
  wget -O crashplan.tgz $crashplan_url

  # Extract and run its install script.
  tar -zxvf crashplan.tgz
  cd CrashPlan-install
  ./install.sh

  # Open the ports!
    #What ports does CrashPlan use?
    #TCP 4242: listening port for computer to computer connections, can be configured under Settings > Backup > Inbound backup from other computers (required for computer to computer backup)
    #TCP 4243: used by the CrashPlan application to connect to the CrashPlan backup service (required)
    #TCP 443: for connecting the CrashPlan backup service to CrashPlan Central (required)
    #TCP > 50000: NAT traversal for connecting between computers (optional)
    #Standard UPnP and NAT-PMP ports: for connecting between computers (optional)
  open_iptables_port 4242
  open_iptables_port 4243
  open_iptables_port 443
  open_iptables_port 50002
  open_iptables_port 50003
  
  # AutoStart? Not sure this is needed.
  chkconfig crashplan on

  # To be able to watch files in realtime
  add_programs "inotify-tools"
  # Up the amount of files that can be watched
  echo "# Up the ionotify amount to watch" >> /etc/sysctl.conf
  echo "fs.inotify.max_user_watches=100000" >> /etc/sysctl.conf

  # Back to root
  cd ~
}

# Install Java Support for WebBrowsers (Any direct URLs out there ?)
function install_java {
  log_and_echo " " 
  log_and_echo "Install Java Support for WebBrowsers."
  wget -O java.bin http://javadl.sun.com/webapps/download/AutoDL?BundleId=59622
  chmod u+x java.bin
  ./java.bin
  # Link the browser to it.
  log_and_echo "You may have to open another console and create this link."
  log_and_echo "ln -s /usr/java/jre1.6.0_##/lib/i386/libnpjp2.so /usr/lib/mozilla/plugins/libnpjp2.so" 
  
  mkdir -p /usr/lib/mozilla/plugins/libnpjp2.so
  if [ "$cpubit" -eq 32 ] ; then
    ln -s /usr/java/jre1.6.0_31/lib/i386/libnpjp2.so /usr/lib/mozilla/plugins/libnpjp2.so
  fi
  if [ "$cpubit" -eq 64 ] ; then
    ln -s /usr/java/jre1.6.0_31/lib/amd64/libnpjp2.so /usr/lib/mozilla/plugins/libnpjp2.so
  fi
  log_and_echo "Test if Java is working here: http://www.java.com/en/download/testjava.jsp" 
}

# Install Apache ?
function install_apache {

  add_programs "httpd"
  open_iptables_port 80

}

# Install MySQL ?
function install_mysql {

  add_programs "mysql-server mysql"
  # Secure the install with passwords
  # Have to start the service to use it
  service mysqld start
  mysql_secure_installation

}

# Install PHP and PHP for Apache.
function install_php {

  add_programs "php php-mysql php-pdo"

}

# Install a complete LAMP system
function install_linux_apache_mysql_php {

  install_apache
  install_mysql
  install_php

}

# Import MySQL ?
function mysql_import_data {

  log_and_echo "Downloading MySQL file "
  wget -O $mysql_import_filename $mysql_import_url

  log_and_echo "Importing MySQL file "
  # mysql -u USERNAME -p DATABASENAME < FILENAME.sql
  if $mysql_use_import_database_name ; then
    mysql -u $mysql_import_username -p$mysql_import_password $mysql_import_database_name < $mysql_import_filename
  else
    mysql -u $mysql_import_username -p$mysql_import_password < $mysql_import_filename
  fi

}


# End of Script Cleanup
function end_script_cleanup {
  log_and_echo " " 
  log_and_echo "Cleaning up leftover files."
  mv $0 $script_file_name
  rm -f old_install_script.sh
  
  # Remove downloaded files.
  rm -f $cleanup_script_files

  # Finalize the Firewall
  # Allow Ping response ?
  if $firewall_allow_ping_in ; then
    iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
  fi
  # Stop any other packets coming in through the firewall
  iptables -A INPUT -j DROP
  iptables -P FORWARD DROP
  # Save the rules. 
  #To restore use "iptables-restore < /root/iptables.rules"
  log_and_echo "Saving the rules. To restore use 'iptables-restore < /root/iptables.rules'"
  iptables-save > /root/iptables.rules

  # Make sure it is all written to disk before rebooting.
  sync
}

# End of Script notes
function end_script_notes {

# Desktop
if [ "$system_runlevel" == "graphical" ] ; then
  if [ "$system_graphical_desktop" == "kde" ] ; then
    log_and_echo " " 
    log_and_echo "If installed, once the computer is booted into KDE, it will go through a small setup."
    log_and_echo "Your account, $account_user, is already created. So skip that part unless you are adding more."
  fi
fi
  log_and_echo " "
  log_and_echo "IP Addresses:" 
  log_and_echo "`ifconfig`"
  log_and_echo " "
  echo "Remember to consult the Log file this script created, $LOG_FILE"
  log_and_echo " "
  log_and_echo "Reboot to apply all updates and changes."
  
  log_and_echo "SpellCaster script has Ended at: `date "+%F %T"`" 
  
  # What test can I use to know if the sound card is there ? Errors on the screen if it cannot work.
  # Maybe I should run this in the background so it cannot spit errors to the console...
  espeak "Spell Casting is complete." 2>/dev/null

}

# Fedora ?,16,? uses systemd to manage the runlevel. So use this function to set it.
# multi-user
# graphical
function set_runlevel_in_fedora_systemd {

  if [ "$1" == "multiuser" ] ; then
    rm -f /etc/systemd/system/default.target
    ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
  fi

  if [ "$1" == "graphical" ] ; then
    rm -f /etc/systemd/system/default.target
    ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
  fi
}


function ask_install_script_questions {

  if [[ $0 != $script_file_name".new" ]] ; then
    read_question "Check for update on this script ? " chk_update true
  else
    read_question "Check for update on this script ? " chk_update false
  fi

  if $chk_update ; then
    read_question "Different script URL ? " scripts_url $scripts_url
    read_question "Exact script file name. " script_file_name $script_file_name

    #Run as root user
    if [ "$UID" -ne "0" ] ; then
﻿      log_and_echo "[`date "+%F %T"`] Error: You must run this script as root!"
﻿      exit 67
    fi
    log_and_echo "[`date "+%F %T"`] User id check successful" 

    if [ "$0" != "$script_file_name.new" ] ; then

      cp $0 old_install_script.sh
      wget -O $script_file_name.new $scripts_url
      chmod u+x $script_file_name.new
      log_and_echo "Executing...$script_file_name.new"
      /bin/bash $script_file_name.new
      wait
﻿     exit
    else
﻿     rm -f $script_file_name*      
      log_and_echo "Running Newest version now."
    fi
    
  fi
  
  read_question "Forward emails addressed to root account to email address ? " use_system_email_monitor true
  if $use_system_email_monitor ; then
    read_question "The email address ? " system_email_monitor $system_email_monitor
  fi

  read_question "The admin account user name. " account_user $account_user
  read_question "The admin account $account_user password. " account_user_password $account_user_password

  read_question "URL to your PUBLIC openssh key. This will be the only method of ssh access after reboot. " your_public_openssh_key_for_remote_access $your_public_openssh_key_for_remote_access
  read_question "Use a custom sshd_config ? It could also be put in the mass files download. URL please: " sshd_config $sshd_config
  
  read_question "CPU type. 32 or 64 ? " cpubit "64"
  # Arch maybe in the future ?

  log_and_echo "What run level should the system boot into ? "
  read_question "graphical or multiuser ? " system_runlevel $system_runlevel

  if [ "$system_runlevel" == "graphical" ] ; then
    log_and_echo "What desktop system ? "
    read_question "KDE Only right now. " system_graphical_desktop $system_graphical_desktop
  fi
  
  read_question "Install Samba ? " use_samba $use_samba
  read_question "Install Webmin ? " use_webmin $use_webmin
  read_question "Install ZFS-FUSE ? " use_zfs $use_zfs
  read_question "Install JAVA Platform and browser access ? " use_java $use_java
  read_question "Install Crashplan ? " use_crashplan $use_crashplan
  if $use_crashplan ; then
    read_question "The URL to download Crashplan from: " crashplan_url $crashplan_url
  fi
  read_question "Install Dropbox for account user $account_user ? " use_dropbox $use_dropbox
  read_question "Install HekaFS ? " use_hekafs $use_hekafs

  read_question "Install a LAMP system ? " use_lamp $use_lamp
  if $use_lamp ; then
    read_question "Install a complete LAMP system ? " use_all_lamp $use_all_lamp
    
    if ! $use_all_lamp ; then
      read_question "Install Apache2 ? " use_one_lamp_apache $use_one_lamp_apache
      
      read_question "Install MySQL ? " use_one_lamp_mysql $use_one_lamp_mysql
      
      read_question "Install PHP ? " use_one_lamp_php $use_one_lamp_php
      
    fi

    # Import a MySQL file from URL ?
    read_question "Import a MySQL .sql file into the database from URL ? " use_mysql_import $use_mysql_import
    if $use_mysql_import ; then
      read_question "URL to MySQL import file: " mysql_import_url $mysql_import_url
    fi
  fi

  read_question "Install inadyn-mt ? This allows you to update DYNDNS.Org DNS entries with the computers IP address. " use_inadyn $use_inadyn

  read_question "Install fail2ban ? It is recommended! It will stop people from trying to login for 5 mins if they fail 5 times. " use_fail2ban $use_fail2ban

  log_and_echo "Mass Files refers to downloading a tar.bz file with proper paths to copy a lot of files into the system."
  log_and_echo "Such as all the website files in /var/www/html/. The tar.bz would contain a directory of var and another inside it of www which has all the files."
  log_and_echo "Mass files 1 is for the OS specific files to get the system going. The 'Default' files are in here."
  log_and_echo "Mass files 2 is for the customization of the computer. Like a template. The webserver would have the apache http.conf files in this one and the /var/www/html/ files."
  log_and_echo "Another type of machine would have its custom files in a different mass_files2.tar.bz file."
  read_question "Download and extract mass files for populating the OS with normal files ? " use_mass_files1 $use_mass_files1
  read_question "Download and extract mass files for populating the OS with customization files ? " use_mass_files2 $use_mass_files2
  if $use_mass_files1 ; then
    read_question "Mass Files 1 URL please: " mass_files_url1 $mass_files_url1
    read_question "Mass Files 1 Exact filename please: " mass_file1_name $mass_file1_name
  fi
  if $use_mass_files2 ; then
    read_question "Mass Files 2 URL please: " mass_files_url2 $mass_files_url2
    read_question "Mass Files 2 Exact filename please: " mass_file2_name $mass_file2_name
  fi

  log_and_echo "Wipe clean the iptables so we can start adding things fresh ?"
  read_question "If not, things will be added to the bottom of the list. Please adjust it all yourself. Wipe ? " wipe_firewall $wipe_firewall
  read_question "Firewall: Allow ping responses on the machine ? " firewall_allow_ping_in $firewall_allow_ping_in
  read_question "Firewall: Ask each time a port is going to be opened, if allowed ? " firewall_question_port_open $firewall_question_port_open

  log_and_echo "We can skip the system update in order to get installed faster. Just do the update {yum|aptitude} at a later time if you wish."
  read_question "Skip update ? " system_yum_update_skip $system_yum_update_skip

  read_question "List the files to rm -f after the script is done. /root is current directory. " cleanup_script_files "$cleanup_script_files" # Qoutes needed to pass something with spaces.

  read_question "Press Enter to start installing or control-c the script to cancel. " nothing $nothing
}

# $1 will be the text before the answer.
# $2 is the variable that must be filled. Use after the function call.
# $3 is the default is supplied.
# Used like this: read_question "Update Script ?" ans true
#or: read_question "What is your name ?" name "Bob"
function read_question {

if [ -n "$3" ] ; then
  log_and_echo "###"
  read -e -i "$3" -p "# $1 " $2
  log_and_echo "# $1 -> ${!2} "
  log_and_echo "###"
else
  log_and_echo "###"
  read -p "# $1 " $2
  log_and_echo "# $1 -> ${!2} "
  log_and_echo "###"
fi
 
} # Please do not edit the function 'read_question' unless you KNOW what you are doing!

###
# End Functions
###

###
# Code Execution
###

# Asking for script help ?
# Ask questions about what to install
if [ "$1" == "help" ] ; then
  echo "You have command options 'help' and 'skip-questions'"
  echo "skip-questions: will NOT ask for input. It will use the default values and run with them. Good for SSH installs. Not in use yet."
  exit
fi

# Create Log file
LOG_FILE="/root/install-script.log"

#Run as root user
if [ "$UID" -ne "0" ] ; then
  echo "[`date "+%F %T"`] Error: You must run this script as root!"
  exit 67
fi
log_and_echo "[`date "+%F %T"`] User id check successful" 

cd ~
touch $LOG_FILE
clear
log_and_echo "SpellCaster install script has started at: `date "+%F %T"`"
log_and_echo  " " 

log_and_echo "You can watch the install log on another console if you wish. Just wait for the tail program to get installed and 'tail -f ~/install-script.log'"
log_and_echo " "

# Ask questions about what to install
if [ "$1" == "skip-questions" ] ; then
  log_and_echo "Skipping setup question."
else
  ask_install_script_questions
fi

# Run yum update program and add other repo's
system_yum_update

# Install some utils and then my programs
log_and_echo " " 
log_and_echo "Install some utils and then desired programs."
# Basics
add_programs "$system_install_list_basic"

# Set the monitor to NOT turn off on us during the install
setterm -blank 0 -powersave off -powerdown 0
xset s off

# Tools
add_programs "$system_install_list_tools"

# Samba ?
if $use_samba ; then
  add_programs "samba samba-common"
  open_iptables_port 137
  open_iptables_port 138
  open_iptables_port 139
  open_iptables_port 445
fi

# Desktop
if [ "$system_runlevel" == "graphical" ] ; then
  if [ "$system_graphical_desktop" == "kde" ] ; then
    # Group installing works better on KDE installs. Can't seem to script this in a function too.
    
    # The following was working fine until a PC I came across. Should still work.
    #I'm switching to the other one "yum groupinstall "KDE Software Compilation"" because of some reading I did.
    #yum -y groupinstall 'X Window System' 'KDE (K Desktop Environment)' kde
    yum -y groupinstall "X Window System" "KDE Software Compilation"

    # User Programs
    add_programs "$system_install_list_desktop_kde_programs"

    # Remote Access
    add_programs "xrdp"
    
    open_iptables_port 3389

  fi

  if [ "$system_graphical_desktop" == "gnome" ] ; then
    # Group installing works better on KDE installs. Can't seem to script this in a function too.
    #yum -y groupinstall 'X Window System' 'KDE (K Desktop Environment)' kde
    # User Programs
    #add_programs "$system_install_list_desktop_gnome_programs"
    log_and_echo "Gnome Install ?"

    # Remote Access
    #add_programs "xrdp"
    #open_iptables_port 3389

  fi

else
  # MultiUser Install. No Desktop evironment.
  log_and_echo "Multi User"

fi

# Remove some built in programs.
remove_programs "openoffice evolution"

# Fanagle the Firewall - Wipe it clean and start new.
if $wipe_firewall ; then
  iptables --flush
  # Save the rules.
  iptables-save > /root/iptables.rules

  iptables -A INPUT -i lo -j ACCEPT
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -P OUTPUT ACCEPT
fi

# Set this before installing other programs. Some need the correct runlevel to install the scripts.
# If fedora
set_runlevel_in_fedora_systemd $system_runlevel
# if uBuntu
#set_runlevel_in_ubuntu_systemd $system_runlevel

if $use_webmin ; then
  install_webmin
fi

if $use_zfs ; then
  install_zfs-fuse
fi

setup_personal_account
setup_personal_account_bash_profile "screen -DR"

setup_ssh
setup_ssh_keys

if $use_system_email_monitor ; then
  setup_root_email_forwarding
fi

if $use_dropbox ; then
  install_dropbox_for_your_account
  install_dropbox_for_all_users
fi

if $use_hekafs ; then
  install_hekafs
  setup_hekafs
fi

if $use_java ; then
  install_java
fi

if $use_crashplan ; then
  install_crashplan
fi


# Install a LAMP ?
if $use_lamp ; then
    # Install a complete LAMP package ?
    if $use_all_lamp ; then
      install_linux_apache_mysql_php
    else
      # Must only want specific services

      if $use_one_lamp_apache ; then
	install_apache
      fi
      
      if $use_one_lamp_mysql ; then
	install_mysql
      fi
      
      if $use_one_lamp_php ; then
	install_php
      fi
    fi
    if $use_mysql_import ; then
      mysql_import_data
    fi
fi

# inadyn-mt setup
if $use_inadyn ; then
  setup_inadyn
fi

# Fail2ban setup
if $use_fail2ban ; then
  setup_fail2ban
fi

# Mass copy mass_file1 and mass_file2
mass_copy_system_files

# Call crontab to add things ?
if $use_crontab ; then
  do_crontab
fi

# Final Check
if $system_yum_update_skip ; then
  log_and_echo "Skipping yum update and upgrade"
else
  yum -y update
  yum -y upgrade
fi

# If fedora
set_runlevel_in_fedora_systemd $system_runlevel
# if uBuntu
#set_runlevel_in_ubuntu_systemd $system_runlevel

auto_starts

end_script_cleanup
end_script_notes

###
# End Code Execution
###
