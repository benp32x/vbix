#!/usr/bin/bash

# Copyright (C) 2014,2024 Ben Pekarek
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# -----------------------------------------------------------------------------
# FLAGS:
# -----------------------------------------------------------------------------

while getopts chilmnpx-: name
do
	case $name in
		-)
			case "${OPTARG}" in
				# -- VM configurations options --------------------------------

				name)        opt_name="${!OPTIND}";    OPTIND=$(( $OPTIND + 1 ));;
				install)     opt_install="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ));; # see /storage
				cpu)         opt_cpu="${!OPTIND}";     OPTIND=$(( $OPTIND + 1 ));;
				ram)         opt_ram="${!OPTIND}";     OPTIND=$(( $OPTIND + 1 ));;
				hdsize)      opt_hdsize="${!OPTIND}";  OPTIND=$(( $OPTIND + 1 ));; # required if using iso (TODO: write condition)
				nic)         opt_nic="${!OPTIND}";     OPTIND=$(( $OPTIND + 1 ));;
				rdp)         opt_rdp="${!OPTIND}";     OPTIND=$(( $OPTIND + 1 ));; # required if not using port management (TODO: write condition)
				ports)       opt_ports="${!OPTIND}";   OPTIND=$(( $OPTIND + 1 ));;
				ostype)      opt_ostype="${!OPTIND}";  OPTIND=$(( $OPTIND + 1 ));;

				name=*)      opt_name=${OPTARG#*=};;
				install=*)   opt_install=${OPTARG#*=};;
				cpu=*)       opt_cpu=${OPTARG#*=};;
				ram=*)       opt_ram=${OPTARG#*=};;
				hdsize=*)    opt_hdsize=${OPTARG#*=};;
				nic=*)       opt_nic=${OPTARG#*=};;
				rdp=*)       opt_rdp=${OPTARG#*=};;
				ports=*)     opt_ports=${OPTARG#*=};;
				ostype=*)    opt_ostype=${OPTARG#*=};;

				# -- execution options ----------------------------------------

				run)         opt_run="${!OPTIND}";       OPTIND=$(( $OPTIND + 1 ));;
				poweroff)    opt_poweroff="${!OPTIND}";  OPTIND=$(( $OPTIND + 1 ));;
				restart)     opt_restart="${!OPTIND}";   OPTIND=$(( $OPTIND + 1 ));;
				savestate)   opt_savestate="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ));;
				vmexport)    opt_vmexport="${!OPTIND}";  OPTIND=$(( $OPTIND + 1 ));;
				#hostsync)    opt_hostsync="${!OPTIND}";  OPTIND=$(( $OPTIND + 1 ));;
				#ramconfig)   opt_ramconfig="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ));;

				run=*)       opt_run=${OPTARG#*=};;
				poweroff=*)  opt_poweroff=${OPTARG#*=};;
				restart=*)   opt_restart=${OPTARG#*=};;
				savestate=*) opt_savestate=${OPTARG#*=};;
				vmexport=*)  opt_vmexport=${OPTARG#*=};;
				#hostsync=*)  opt_hostsync=${OPTARG#*=};;
				#ramconfig=*) opt_ramconfig=${OPTARG#*=};;

				*)echo "Invalid DASH arg";;
			esac;;
		c)copt=1;; # create
		h)hopt=1;; # help
		i)iopt=1;; # info
		l)lopt=1;; # logging
		m)mopt=1;; # manage
		n)nopt=1;; # non-interactive mode
		p)popt=1;; # list ports
		x)xopt=1;; # disable colors
		*)echo "Invalid arg";;
	esac
done

# flag flush to make ready for real arguments
shift $(($OPTIND -1))

# -----------------------------------------------------------------------------
# VERSION:
# -----------------------------------------------------------------------------

if [ ! -z $hopt ]
then
	echo "vbix v0.6.0, Sept 10th, 2024"
#	echo "vbix v0.5.3, June 14th, 2021"
#	echo "vbix v0.5.2, January 29th, 2021"
#	echo "vbix v0.5.1, October 10th, 2017"
#	echo "vbix v0.5.0, October 6th, 2017"
#	echo "vbix v0.4.4, January 26th, 2017"
#	echo "vbix v0.4.3, October 27th, 2016"
#	echo "vbix v0.4.2, August 3rd, 2016"
#	echo "vbix v0.4.1, June 3rd, 2016"
#	echo "vbix v0.4.0, May 24th, 2016"
#	echo "vbix v0.3.0, May 13th, 2016"
#	echo "vbix v0.2.9, January 2nd, 2015"
#	echo "vbix v0.2.8, November 2nd, 2015"
#	echo "vbix v0.2.5, October 6th, 2015"
#	echo "vbix v0.1.5, June 2015"
#	echo "vbix v0.1.1, April 2015"
#	echo "vbix v0.0.1, December 2014"
fi

# -----------------------------------------------------------------------------
# HELP:
# -----------------------------------------------------------------------------

if [ ! -z $hopt ]
then
	echo 'Usage: bash vbix.sh [OPTION] -or- vbix [OPTION]'
	echo 
	echo 'Startup:'
	echo '  -h  help'
	echo '  -x  disable colored text'
	echo 
	echo 'Options:'
	echo '  -c  create vm'
	echo '  -m  manage vm'
	echo '  -i  vm information'
	echo '  -l  enable logging'
	echo '  -p  list global vm ports usage'
	echo 
	echo 'Non-interactive Options:'
	echo '  -c -n  create vm'
	echo '    --name=<name>'
	echo '    --install=<file_name_only>.ovf|.iso'
	echo '    --ostype=<ostype>'
	echo '    --cpu=1|2|3|4'
	echo '    --ram=256MB|512MB|768MB|1GB|2GB|3GB|4GB'
	echo '    --hdsize=5GB|8GB|10GB|20GB|30GB|40GB'
	echo '    --nic=nat|bridged'
	echo '    --rdp=1024-65000'
	echo '    --ports=auto|auto22|none|custom|custom22'
	echo '  -m -n  manage vm'
	echo '    --run=<vmname>'
	echo '    --poweroff=<vmname>'
	echo '    --restart=<vmname>'
	echo '    --savestate=<vmname>'
#	echo '    --hostsync=<vmname>'
#	echo '    --ramconfig=<name>:<val> (TODO: support coming soon!)'
	echo '    --vmexport=<vmname>:<exported_img_name>'
	echo '  Example: -c -n --name=coolstuff --cpu=1 ...'
	echo 
fi

# -----------------------------------------------------------------------------
# HELP (extended):
# -----------------------------------------------------------------------------

if [ ! -z $hopt ]
then
#	echo 'Post VM Install:'
#	echo 
#	echo '  While guest system is powered down'
#	echo '  $ vboxmanage modifyvm "Debian" --dvd none'
#	echo '  While guest system is running run this command on the host terminal'
#	echo '  $ vboxmanage controlvm "Debian" dvdattach none'
#	echo 
	echo 'Post VM Install:'
	echo '  (Use "List Drives" option under -m to query storage controllers)'
	echo 
	echo '  Ejecting the DVD Drive:'
	echo '  vboxmanage storageattach "<vm_name>" --storagectl "IDE Controller" --port "0" --device "1" --type dvddrive --medium "emptydrive"'
#	echo '  IDE Controller (0, 1): Empty (ejected)'
	echo 
	echo '  Inserting a DVD:'
	echo '  vboxmanage storageattach "<vm_name>" --storagectl "IDE Controller" --port "0" --device "1" --type dvddrive --medium "/home/<user>/Win_Ent_8.1_64BIT.ISO"'
#	echo '  IDE Controller (0, 1): /home/<user>/Win_Ent_8.1_64BIT.ISO (UUID: c94b1200-8301-4913-938b-f56d06ead0ee)'
	echo 
	echo 'Remote Desktop Tips:'
	# TODO: These are old notes, I need to refactor or remove them:
	# ---
#	echo '  Sets proper VRDE RDP rather than the default unencrypted VNC. If you are '
#	echo '  running into problems, try connecting to the set RDP port over '
#	echo '  unencrypted VNC.'
#	echo 
#	echo '    $ wget -nd http://download.virtualbox.org/virtualbox/4.3.14/Oracle_VM_VirtualBox_Extension_Pack-4.3.14.vbox-extpack'
#	echo '    $ vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.3.14.vbox-extpack'
#	echo 
#	echo '    GLOBAL : $ vboxmanage setproperty vrdeextpack "Oracle VM VirtualBox Extension Pack"'
#	echo '    PER VM : $ vboxmanage managevm <vm_name> --vrdeextpack "Oracle VM VirtualBox Extension Pack"'
	# ---
	echo '  Access to the VNC port for a VM is restricted by this script, '
	echo '  requiring an SSH Tunnel for encryption:'
	echo 
	echo '  ssh -p <host_ssh_port> -N -v -L <local_port>:<host_ip_address>:<vm_rdp_port> <host_user>@<host_ip_address>'
	echo 
	echo '  guest extras to get better VM remote desktop performance in a GUI:'
	echo 
	echo '  If using a GUI via RDP, install "guest additions", and the run the following:'
	echo '  $ vboxmanage modifyvm <vm_name> --vram 256'
	echo 
	echo '  If needed, you can force monitor resolution with the following:'
	echo '  $ vboxmanage setextradata <vm_name> CustomVideoMode1 1920x1080x32'
	echo '  $ vboxmanage setextradata <vm_name> CustomVideoMode1 1440x900x32'
	echo 
fi

#---

if [ -z $hopt ]; then

# -----------------------------------------------------------------------------
# FLAG CHECK:
# -----------------------------------------------------------------------------

if [ ! -z $copt ] && [ ! -z $mopt ]
then
	echo "error: -c and -m cannot be used together. Please run separately."
	echo "bash vbix.sh -h for help"
	exit 1
fi

# -----------------------------------------------------------------------------
# RUN FROM LOCAL or SYSTEM:
# -----------------------------------------------------------------------------

# NOTE: Manually change this if needed PRIOR to executing vbix_ins.sh.

# > config_sh_local:
#   ---
#   We need this information immediately, as it configures the paths 
#   (see "paths main" below).
# 
#   This parameter determines where the conf file is read from. So there is 
#   no way we can store this configuration option in the conf file.
# 
#   If running vbix_ins.sh to install vbix, a sed expression will match and 
#   replace this value according to the desired configuration during install.
config_sh_local='YES' # (YES)|NO

# -----------------------------------------------------------------------------
# CONFIG (defaults):
# -----------------------------------------------------------------------------

# These are defaults and should not be changed here. They are configurable 
# via vbix.conf in the conf directory which is generated during the 
# install process.

# () = default value

# This script assumes the use of the 'Oracle VM Virtualbox Extension Pack', 
# as VMs are being accessed remotely and use of VRDE is required to access the 
# VM to install the OS. See vbix -h for help, and optional auto install via 
# vbix_ins.sh

# -------------------------------------

# > config_port_manage:
#   ---
#   If disabled the user is on their own and all ports must be assigned 
#   manually using vboxmanage.
# 
#   related to: rdp, nat port mapping, and port block checkout
config_port_manage='YES' # (YES)|NO

# > config_ext_pack_vnc:
#   ---
#   To use a VNC connection for VRDE, a flag needs to be set in the build 
#   files for VirtualBox itself during compile. Over the years, this feature 
#   has been available/absent depending on the build settings chosen by the 
#   maintainer. 
#   
#   Debian's build (at one point) had VNC enabled, and Oracle has often 
#   disabled it. So we have to count on the possibility of VNC support 
#   NOT being available by default.
#   
#   To run a fully open source Virtualbox setup, you need to use VNC, as the 
#   Proprietary 'Oracle VM Virtualbox Extension Pack' is not open source 
#   (and carries with it a licensing requirement at the enterprise level).
#   
#   Note: Virtualbox VNC does not use local user credentials for 
#         authentication like Oracle's Extension Pack in conjunction with 
#         RDP. (--vrdeauthtype external)
#   
#   For VNC, a plain text password is possible via vboxmanage, however as we 
#   are using an SSH tunnel to connect, it isn't required and probably not 
#   desired as the password is stored in plain text. The default here, is for 
#   no password to be required when using VNC.
config_ext_pack_vnc='NO' # YES|(NO)

#   GODZILLA!: using config_ext_pack_vnc='YES' 
#              with config_vrde_private='NO' 
#              with no password set
#              would be bad on a public server!

# > config_vrde_private:
#   ---
#   Forces RDP/VNC clients to connect via 127.0.0.1, requiring a local system 
#   account and SSH tunnel for encryption:
#   
#   $ ssh -p <host_ssh_port> -N -v -L <local_port>:<host_ip_address>:<vm_rdp_port> <host_user>@<host_ip_address>
#   
#   Setting this to 'NO' will allow public access to the VRDE port for RDP/VNC.
config_vrde_private='YES' # (YES)|NO

# config_vrde_tls:
#   ---
#   TLS Encryption Settings for native Virtualbox VRDE RDP Access (not VNC). 
#   This only applies if using the 'Oracle VM Virtualbox Extension Pack'. 
#   It has no affect when using the VNC extensions pack.
#   
#   Setting config_vrde_private='YES' and tunneling over SSH to connect, 
#   means vrde_tls is no longer required for your connection to be encrypted. 
#   However, one may still want to enable vrde_tls to troubleshoot the RDP 
#   TLS cert process over a private connection, as opposed to performing 
#   this troubleshooting on an exposed port.
#   
#   Note: Currently this is set to 'NO' by default, due to issues with the 
#   TLS certs having problems with Windows 7 clients in VirtualBox 6.1. More 
#   troubleshooting is needed to determine why TLS was breaking the 
#   connection for a legacy and/or unpatched version of Windows 7.
config_vrde_tls='NO' # YES|(NO)

# -----------------------------------------------------------------------------
# PATHS:
# -----------------------------------------------------------------------------

# build path to users home dir
v_pwd=$(pwd); cd ~/; path_user_home=$(pwd); cd "$v_pwd";

# logs
log_file="$path_user_home"'/vbix.log'

# default VMs folder name generated by virtualbox
fn_vbox_vms="VirtualBox VMs"

# path for local vm installs: [ /home/<user>/VirtualBox VMs ]
path_vbox_vms="$path_user_home/$fn_vbox_vms"
rx_path_vbox_vms=$(echo "$path_vbox_vms" | sed -r 's/\//\\\//g;')

file_conf='vbix.conf'
file_csv='vbix_ports.csv'
file_md5='vbix_ports.md5'

# paths main
if [ $config_sh_local == 'YES' ]
then
	path_iso="$path_user_home/vbix/vbix_iso"    # iso storage for creating VMs
	path_img="$path_user_home/vbix/vbix_img"    # img storage for creating VMs from ready-made's
	path_conf="$path_user_home/vbix/vbix_conf"  # ports csv/md5 stored here
	path_cert="$path_conf/cert"                 # location for TLS Certificates generated during install
else
	path_iso='/storage/vbix_iso'                # iso storage for creating VMs
	path_img='/storage/vbix_img'                # img storage for creating VMs from ready-made's
	path_conf='/usr/local/conf/vbix'            # ports csv/md5 stored here
	path_cert="$path_conf/cert"                 # location for TLS Certificates generated during install
fi

# -----------------------------------------------------------------------------
# CONFIG (.conf file):
# -----------------------------------------------------------------------------

# parse blah from <var>=blah in a .rc file format
function parse_meta() {
	local arg1=$1 # file
	local arg2=$2 # value

	grep "$arg2" "$arg1" | sed -r 's/'"$arg2"'(.*)/\1/g;'
}

function validate_yn() {
	local arg1=$1

	if [[ "$arg1" =~ ^(YES|NO|Yes|No|Y|N)$ ]]
	then
		echo "OK"
	fi
}

# If a .rc file exists in the users local directory, and the values are not 
# empty, and validate as YES|NO, they will override the defaults.
if [ -f "$path_conf/$file_conf" ]
then
#	rc_sh_local=$(parse_meta "$path_conf/$file_conf" 'sh_local=')
	rc_port_manage=$(parse_meta "$path_conf/$file_conf" 'port_manage=')
	rc_ext_pack_vnc=$(parse_meta "$path_conf/$file_conf" 'ext_pack_vnc=')
	rc_vrde_private=$(parse_meta "$path_conf/$file_conf" 'vrde_private=')
	rc_vrde_tls=$(parse_meta "$path_conf/$file_conf" 'vrde_tls=')

#	if [ "$rc_sh_local" != '' ] && [ "$(validate_yn "$rc_sh_local")" == 'OK' ]
#	then
#		config_sh_local="$rc_sh_local"
#	fi

	if [ "$rc_port_manage" != '' ] && \
	   [ "$(validate_yn "$rc_port_manage")" == 'OK' ]
	then
		config_port_manage="$rc_port_manage"
	fi

	if [ "$rc_ext_pack_vnc" != '' ] && \
	   [ "$(validate_yn "$rc_ext_pack_vnc")" == 'OK' ]
	then
		config_ext_pack_vnc="$rc_ext_pack_vnc"
	fi

	if [ "$rc_vrde_private" != '' ] && \
	   [ "$(validate_yn "$rc_vrde_private")" == 'OK' ]
	then
		config_vrde_private="$rc_vrde_private"
	fi

	if [ "$rc_vrde_tls" != '' ] && \
	   [ "$(validate_yn "$rc_vrde_tls")" == 'OK' ]
	then
		config_vrde_tls="$rc_vrde_tls"
	fi
fi

# -----------------------------------------------------------------------------
# VARS:
# -----------------------------------------------------------------------------

vbox_version=$(vboxmanage -v)

script_version='v0.6.0'

# list vm's as sorted, parse name, read as array named "arr_created"
# reference: https://www.baeldung.com/linux/reading-output-into-array
# man: https://helpmanual.io/builtin/readarray/
readarray -O 1 -t arr_created < <(vboxmanage list vms -s | cut -d '"' -f 2)

# -----------------------------------------------------------------------------
# GLOBAL FUNCTIONS:
# -----------------------------------------------------------------------------

# -------------------------------
# PUBLIC DOMAIN CODE - START:

# The following functions are released into the PUBLIC DOMAIN:
# 
#   pad_stuff()
#   chk_color()
#   label_*() [all label_ functions]
# 
# These functions are used across many of my bash scripts for simple color 
# formatting. To avoid open source licensing conflicts, these functions are 
# released into the public domain. 
# 
# You have permission to use/modify the code within this specific code block.
# For the rest of the code in this project, you must adhere to the parent 
# project's open source license.
# 
# TIP: Drop the $xopt condition if don't use a -x flag in your script.

function pad_stuff() {
	local arg1=$1 # string length
	local arg2=$2 # to pad

	# pad columns
	# http://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
	for ((i=0; i < ("$arg2" - "$arg1"); i++)) {
		echo -en " ";
	}
}

# COLOR CODE: START
# these are color labels, with the option to disable the colors permanently 
# via a nocolor mode or via the -x flag
nocolor="NO" # YES|NO

function chk_color() {
	local arg1=$1

	if [ $nocolor == "YES" ] || [ ! -z $xopt ]
	then
		c_start=''
		c_end=''
	else
		c_start="$arg1"
		c_end='\e[0m'
	fi
}

function label_banner() {
	local arg1=$1;
	local arg1_pad=$(pad_stuff "${#arg1}" '80')
	chk_color '\e[1;37;104m'
	printf "$c_start"'%s'"$c_end"'\n' "$arg1$arg1_pad"
}
function label_step()    { local arg1=$1; chk_color '\e[1;35m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_title()   { local arg1=$1; chk_color '\e[1;36m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_null()    { local arg1=$1; chk_color '\e[1;30m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_good()    { local arg1=$1; chk_color '\e[0;32m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_bad()     { local arg1=$1; chk_color '\e[0;31m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_success() { local arg1=$1; chk_color '\e[1;32m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_error()   { local arg1=$1; chk_color '\e[1;37;41m'; printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_warn()    { local arg1=$1; chk_color '\e[1;33m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
function label_note()    { local arg1=$1; chk_color '\e[0;33m';    printf "$c_start"'%s'"$c_end"'\n' "$arg1"; }
# COLOR CODE: END

# PUBLIC DOMAIN CODE - END
# -------------------------------

function proceed_or_exit() {
	read -p "Press Enter to proceed, or ^C to exit"
}

# -----------------------------------------------------------------------------
# LOCAL FUNCTIONS:
# -----------------------------------------------------------------------------

# check_md5 is related to ports management
function check_md5() {
	local arg1=$1 # filename

	md5sum -c "$arg1"

	# note: $? variable = exit status of previously run command (md5sum)
	if [ $? == '1' ]
	then
		label_error 'error: '"$arg1"' checksum invalid'
		exit 1
	else
		label_good "$arg1"' checksum OK'
	fi
}

# verify a manually typed VM name exists before proceeding
# note: used primarily in non-interactive mode
function chk_vmname() {
	local arg1=$1 # vm name
	local arg2=$2 # ?!?!
	local chk_vmname_return=$(echo "${arr_created[@]}" | grep -o "$arg1")

	# TODO: This function seems half baked
	# No second arguement is being passed into this function anywhere in the code, so the second half of the condition will fail
	# The user will enter a wrong vm name, and the script will continue on (it should bail, with exit 1)
	if [ "$chk_vmname_return" != "$arg1" ] && [ "$arg2" == 'should_exist' ]
	then
		label_error 'Error: vm_name ('"$arg1"') does not exist, exiting'
		if [ ! -z $lopt ]; then echo 'Error: vm_name ('"$arg1"') does not exist, exiting' >> "$log_file"; fi
		exit 1
	fi
}

function show_storagectrl_info() {
	local arg1=$1 # vm_to_manage
	local info4controller=$(vboxmanage showvminfo "$arg1")
	local controller_list=$(echo "$info4controller" | grep -i "\(Storage Controller Name\)" | sed -r "s/^.+:\s+(.+)$/\1/g; s/ /@/g;")

	label_step 'Querying drive info...'
	for ctrlr in `echo "$controller_list"`
	do
		# TODO: spcfix is too vague, clarify var name
		spcfix=$(echo "$ctrlr" | sed -r "s/@/ /g;")
		echo "$info4controller" | grep -i "\($spcfix\)"
	done
}

function filter_list() {
	local arg1=$1 # list
	local arg2=$2 # number

	echo "$arg1" | head -n "$arg2" | tail -n 1
}

# -----------------------------------------------------------------------------
# TRIGGERS
# -----------------------------------------------------------------------------

# info
trig01="YES" # PORTS MANAGE PRE-FLIGHT
trig02="YES" # LIST GLOBAL PORT USAGE
trig03="YES" # VM INFORMATION

# create vm (settings)
trig04="YES" # CREATE A VM: INTERACTIVE MODE
trig05="YES" # CREATE A VM: NON-INTERACTIVE MODE
trig06="YES" # CREATE A VM: PORT MAPPINGS
trig07="YES" # CREATE A VM: VERIFY BEFORE CREATION

# create vm
trig08="YES" # CREATE A VM: EXECUTIONS
  trig08a="YES" # BUILD VM SHELL
  trig08b="YES" # CPU + RAM
  trig08c="YES" # STORAGE DEVICES
  trig08d="YES" # NETWORKING
  trig08e="YES" # VRDE SETTINGS (RDP or VNC)
  trig08f="YES" # FINALIZE VM CREATION

# manage vm
trig09="YES" # MANAGE A VM

# -----------------------------------------------------------------------------
# PORTS MANAGE PRE-FLIGHT:
# -----------------------------------------------------------------------------

if [ $trig01 == "YES" ] && [ $config_port_manage == "YES" ]
then
	# confirm ports csv/md5 exist
	if [ ! -f "$path_conf/$file_csv" ] && \
	   [ ! -f "$path_conf/$file_md5" ]
	then
		label_error 'Error: required files missing ('"$file_csv"', '"$file_md5"')'
		exit 1
	fi

	# this has to happen first prior to create, in order to check the md5 of the csv
	# if it verification fails, then the VM should not be created
	if [ ! -z $copt ]
	then
		check_md5 "$path_conf/$file_md5"
	fi
fi

# -----------------------------------------------------------------------------
# LIST GLOBAL PORT USAGE (vbix -p)
# -----------------------------------------------------------------------------

if [ $trig02 == "YES" ] && [ ! -z $popt ]
then
	cat "$path_conf/$file_csv" | less
fi

# -----------------------------------------------------------------------------
# VM INFORMATION (vbix -i)
# -----------------------------------------------------------------------------

if [ $trig03 == "YES" ] && [ ! -z $iopt ]
then
	label_banner 'VM INFORMATION'
	if [ -d "$path_vbox_vms" ]
	then
		echo 'Currently running: VirtualBox '"$vbox_version"' / vbix.sh '"$script_version"

		total_created="${#arr_created[@]}"
		total_running=$(vboxmanage list runningvms | wc -l)

		if (( "$total_created" >= 1 ))
		then
			label_note 'VMs created: '"$total_created"
			if (( "$total_running" == 0 ))
			then label_good 'VMs running: 0'
			else label_good 'VMs running: '"$total_running"
			fi
			label_null '--------------------------------------------------------------------------------'
			label_null 'NAME               RAM     CPU STATE                           RDP   OSTYPE     '
			label_null '--------------------------------------------------------------------------------'

			for i in "${!arr_created[@]}"
			do
				vm_item="${arr_created[$i]}"
				vmstats=$(vboxmanage showvminfo "$vm_item")
				function parse_vmstats() {
					local arg1=$1
					# Bug in output of vboxmanage showvminfo, Memory size has no : after it anymore, so we have this conditional crap in here:
					if [ "$arg1" == 'Memory size' ]
					then echo "$vmstats" | grep "$arg1" | sed -r 's/[^:]+:?\s+(.+)/\1/g; s/T([0-9]{2}:[0-9]{2}):[0-9]+\.[0-9]+/ \1/g;'
					else echo "$vmstats" | grep "$arg1:" | sed -r 's/[^:]+:\s+(.+)/\1/g; s/T([0-9]{2}:[0-9]{2}):[0-9]+\.[0-9]+/ \1/g;'
					fi
				}

				vmstat_memory=$(parse_vmstats 'Memory size')
				vmstat_cpus=$(parse_vmstats 'Number of CPUs')
				vmstat_state=$(parse_vmstats 'State' | sed -r 's/since //g;')
				vmstat_vrde=$(parse_vmstats 'VRDE port')
				vmstat_ostype=$(parse_vmstats 'OS type')

				vmname_pad=$(pad_stuff ${#vm_item} '18')
				vmstat_memory_pad=$(pad_stuff ${#vmstat_memory} '8')
				vmstat_cpus_pad=$(pad_stuff ${#vmstat_cpus} '2')
				vmstat_state_pad=$(pad_stuff ${#vmstat_state} '31')
				vmstat_vrde_pad=$(pad_stuff ${#vmstat_vrde} '4')
				vmstat_ostype_pad=$(pad_stuff ${#vmstat_ostype} '12')

				chk_vmstat_state_saved=$(echo "$vmstat_state" | grep "^saved")
				chk_vmstat_state_running=$(echo "$vmstat_state" | grep "^running")
				chk_vmstat_state_poweredoff=$(echo "$vmstat_state" | grep "^powered off")

				if [ "$chk_vmstat_state_saved" != '' ] && [ -z $xopt ]
				then
					echo -e "$vm_item$vmname_pad" "$vmstat_memory$vmstat_memory_pad" "$vmstat_cpus$vmstat_cpus_pad" '\e[1;36m'"$vmstat_state"'\e[0m'"$vmstat_state_pad" "$vmstat_vrde$vmstat_vrde_pad" "$vmstat_ostype$vmstat_ostype_pad"
				elif [ "$chk_vmstat_state_running" != '' ] && [ -z $xopt ]
				then
					echo -e "$vm_item$vmname_pad" "$vmstat_memory$vmstat_memory_pad" "$vmstat_cpus$vmstat_cpus_pad" '\e[1;32m'"$vmstat_state"'\e[0m'"$vmstat_state_pad" "$vmstat_vrde$vmstat_vrde_pad" "$vmstat_ostype$vmstat_ostype_pad"
				elif [ "$chk_vmstat_state_poweredoff" != '' ] && [ -z $xopt ]
				then
					echo -e "$vm_item$vmname_pad" "$vmstat_memory$vmstat_memory_pad" "$vmstat_cpus$vmstat_cpus_pad" '\e[1;31m'"$vmstat_state"'\e[0m'"$vmstat_state_pad" "$vmstat_vrde$vmstat_vrde_pad" "$vmstat_ostype$vmstat_ostype_pad"
				else
					echo "$vm_item$vmname_pad" "$vmstat_memory$vmstat_memory_pad" "$vmstat_cpus$vmstat_cpus_pad" "$vmstat_state$vmstat_state_pad" "$vmstat_vrde$vmstat_vrde_pad" "$vmstat_ostype$vmstat_ostype_pad"
				fi
			done
			label_null '--------------------------------------------------------------------------------'
		else
			label_note 'VMs created: 0'
		fi
	else
		label_note 'VMs created: 0'
		echo 'note: [ '"$path_vbox_vms"' ] directory not available yet.'
	fi

	label_null 'Type "bash vbix.sh -h" or "vbix -h" for help'
fi

# -----------------------------------------------------------------------------
# CREATE A VM: INTERACTIVE MODE (vbix -c)
# -----------------------------------------------------------------------------

if [ $trig04 == "YES" ] && [ ! -z $copt ] && [ -z $nopt ]
then
	label_banner 'CREATE A VM: CHOOSE SETTINGS'

	# C1: ISO or IMG?
	label_title 'Choose source media for VM:'
	echo 
	echo ' [1] Installing from scratch using an ISO'
	echo ' [2] Importing a base VM Image, with a pre-installed OS'
	echo 
	read -p "Enter number : " select_source
	echo 

	if [ $select_source == "1" ]; then vbox_source="iso"; fi
	if [ $select_source == "2" ]; then vbox_source="img"; fi

	label_null '-------------------------------------------------------------'

	# C2: VM Name
	label_title 'Choose a name for your VM:'
	echo 
	echo ' Tips:'
	echo ' * Avoid using spaces or special chars'
	echo ' * Avoid naming it like the OS (such as only CentOS as the VM Name)'
	echo 

	function name_your_vm() {
		read -p "Enter name : " manual_vm_name

		# support use of pre-created symlink as vmname
		# sometimes you may want to create a VM at an alternate location (like a tmpfs RAMDisk)
		# this lets you create the symlink manually, and as long as the destination is "empty", it will proceed with vm creation

		# a vm exists, if it has files in the dir/symlink
		local chk_vm_exists=$(find -L "$path_vbox_vms/$manual_vm_name" -type f | wc -l)

		if [[ "$manual_vm_name" =~ ([ \&\:\*\(\)\#\@\!\^\+\?]) ]]
		then
			label_error 'Error: spaces or special chars detected, try again'
			name_your_vm
		elif [ -d "$path_vbox_vms/$manual_vm_name" ] && [ "$chk_vm_exists" != 0 ]
		then
			label_error 'Error: this vm already exists'
			name_your_vm
		else
			vbox_name="$manual_vm_name"
		fi
	}
	name_your_vm

	label_null '-------------------------------------------------------------'

	# ---------------------------------------
	# C3: ISO ASSIGNMENT
	# ---------------------------------------
	if [ $vbox_source == 'iso' ]
	then
		function iso_assignment() {
			local arg1=$1 # iso file
			local arg2=$2 # ostype

			if [ -f "$arg1" ]
			then
				vbox_iso_install="$arg1"
				vbox_ostype="$arg2"
			else
				echo 'Unavailable VM selected... exiting script.'
				exit 1
			fi
		}

		# OPTION 1: Select ISO from List
		label_title 'Which OS would you like to install?'
		echo 

		# Generate a sorted list of ISOs with a full path:
		#   /storage/vbix_iso/debian-10.10.0-amd64-netinst.iso
		stored_isos_as_paths=$(find -L "$path_iso" -type f \( -name "*.iso" \) | sort)   # TODO: SPACES could break this
		# Shorten the list to unique titles:
		#   debian-10.10.0-amd64-netinst
		stored_isos_as_titles=$(echo "$stored_isos_as_paths" | sed -r 's/.+\/(.+)\.iso/\1/g;') # TODO: SPACES could break this

		# ------
		# START : list out available iso's for selection

		stored_iso_num=1

		label_success ' [0] manual entry'

		if [ "$stored_isos_as_titles" == '' ]
		then
			echo 
			label_note ' (no ISOs in storage directory)'
		else
			# TODO: SPACES could break this
			for iso in $stored_isos_as_titles
			do
				if [ -f "$path_iso/${iso}.metacache" ]
				then
					# highlight entry if os_name/os_type are cached:
					#label_good ' ['"$stored_iso_num"'] '"$(parse_meta "$path_iso/${iso}.metacache" 'os_name=')"
					label_good  ' ['"$stored_iso_num"'] '"$iso"'.iso'
				else
					echo ' ['"$stored_iso_num"'] '"$iso"'.iso'
				fi

				stored_iso_num=$(expr $stored_iso_num + 1)
			done
		fi

		echo 
		read -p "Installer : " select_iso
		echo 

		# END : list out available iso's for selection
		# ------

		# OPTION 2: Manual ISO entry (full path)
		if [ $select_iso == "0" ]
		then
			label_title 'Provide complete path to the .iso file'
			echo 
			read -p "Full ISO path : " manual_iso_path
			echo 

			label_title 'Provide ostype, as per Virtualbox'\''s OSTypes'
			echo 
			label_warn 'Tip: enter the following command to see available options:'
			label_warn '     $ vboxmanage list ostypes | less'
			echo 
			read -p "OStype : " manual_iso_ostype
			echo 

			# Final Assignment for ISO and OS Type, based on manual input
			iso_assignment "$manual_iso_path" "$manual_iso_ostype"
		fi

		if [ $select_iso != "0" ]
		then
			# prep data for the if condition that follows
			# note: these are used in both the 'then' and 'else' sections
			filtered_iso_path=$(filter_list "$stored_isos_as_paths" "$select_iso")
			filtered_iso_title=$(filter_list "$stored_isos_as_titles" "$select_iso")
		fi

		# -------------------
		# Virtualbox OS Types
		# -------------------
		if [ $select_iso != "0" ]
		then
			if [ -f "$path_iso/${filtered_iso_title}.metacache" ]
			then
				# Final Assignment for ISO and OS Type, based on metacache
				iso_assignment "$filtered_iso_path" "$(parse_meta "$path_iso/${filtered_iso_title}.metacache" 'os_type=')"
			else
				# --- OS Type : START -----------------------------------------

				# -------------------
				# OS TYPES CODE
				# -------------------
				# Sections include:
				#   Choose OS family / bit type
				#   32-bit OS Type Options
				#   64-bit OS Type Options
				#   EXECUTE: Select OS Type
				#   EXECUTE: Map OS Type Selection
				# The following vars above are required:
				#   select_os_bit
				#   select_os_family
				# In the end, the following vars should be populated:
				#   os_name
				#   os_type

				# Choose OS family / bit type:
				label_title 'Choose OS family'

				echo 
				echo ' [1] BSD'
				echo ' [2] Linux'
				echo ' [3] MacOS'
				echo ' [4] IBM OS2'
				echo ' [5] Solaris'
				echo ' [6] Windows'
				echo ' [7] Other'
				echo 
				read -p "Family : " select_os_family
				echo 

				label_title 'Is your OS 32-bit or 64-bit ?'

				echo 
				echo ' [1] 32-bit'
				echo ' [2] 64-bit'
				echo 
				read -p "Bit-type of OS : " select_os_bit
				echo 

				label_title 'Provide ostype, as per Virtualbox'\''s OSTypes'
				echo 

				# 32-bit OS Type Options:
				if [ "$select_os_bit" == "1" ]
				then
					if [ "$select_os_family" == "1" ]
					then
						echo ' [1] FreeBSD (32-bit)'
						echo ' [2] OpenBSD (32-bit)'
						echo ' [3] NetBSD (32-bit)'
					fi

					if [ "$select_os_family" == "2" ]
					then
						echo ' [ 1] Arch Linux (32-bit)     [ 9] Oracle (32-bit)'
						echo ' [ 2] Debian (32-bit)         [10] openSUSE (32-bit)'
						echo ' [ 3] Fedora (32-bit)         [11] Red Hat (32-bit)'
						echo ' [ 4] Gentoo (32-bit)         [12] Turbolinux (32-bit)'
						echo ' [ 5] Linux 2.2               [13] Ubuntu (32-bit)'
						echo ' [ 6] Linux 2.4 (32-bit)      [14] Xandros (32-bit)'
						echo ' [ 7] Linux 2.6/3.x (32-bit)  [15] Other Linux (32-bit)'
						echo ' [ 8] Mandriva (32-bit)'
					fi

					if [ "$select_os_family" == "3" ]
					then
						echo ' [1] Mac OS X (32 bit)'
						echo ' [2] Mac OS X 10.6 Snow Leopard (32-bit)'
					fi

					if [ "$select_os_family" == "4" ]
					then
						echo ' [1] OS/2 Warp 3'
						echo ' [2] OS/2 Warp 4'
						echo ' [3] OS/2 Warp 4.5'
						echo ' [4] eComStation'
						echo ' [5] Other OS/2'
					fi

					if [ "$select_os_family" == "5" ]
					then
						echo ' [1] Solaris 10 5/09 and earlier (32-bit)'
						echo ' [2] Solaris 10 10/09 and later (32-bit)'
					fi

					if [ "$select_os_family" == "6" ]
					then
						echo ' [1] Windows 3.1            [ 9] Windows Vista (32-bit)'
						echo ' [2] Windows 95             [10] Windows 2008 (32-bit)'
						echo ' [3] Windows 98             [11] Windows 7 (32-bit)'
						echo ' [4] Windows ME             [12] Windows 8 (32-bit)'
						echo ' [5] Windows NT 4           [13] Windows 8.1 (32-bit)'
						echo ' [6] Windows 2000           [14] Other Windows (32-bit)'
						echo ' [7] Windows XP (32-bit)'
						echo ' [8] Windows 2003 (32-bit)'
					fi

					if [ "$select_os_family" == "7" ]
					then
						echo ' [1] Other/Unknown'
						echo ' [2] DOS'
						echo ' [3] Netware'
						echo ' [4] L4'
						echo ' [5] QNX'
						echo ' [6] JRockitVE'
					fi
				fi

				# 64-bit OS Type Options:
				if [ "$select_os_bit" == "2" ]
				then
					if [ "$select_os_family" == "1" ]
					then
						echo ' [1] FreeBSD (64-bit)'
						echo ' [2] OpenBSD (64-bit)'
						echo ' [3] NetBSD (64-bit)'
					fi

					if [ "$select_os_family" == "2" ]
					then
						echo ' [1] Arch Linux (64-bit)     [ 9] Oracle (64-bit)'
						echo ' [2] Debian (64-bit)         [10] Red Hat (64-bit)'
						echo ' [3] Fedora (64-bit)         [11] Turbolinux (64-bit)'
						echo ' [4] Gentoo (64-bit)         [12] Ubuntu (64-bit)'
						echo ' [5] Linux 2.4 (64-bit)      [13] Xandros (64-bit)'
						echo ' [6] Linux 2.6/3.x (64-bit)  [14] Other Linux (64-bit)'
						echo ' [7] Mandriva (64-bit)'
						echo ' [8] openSUSE (64-bit)'
					fi

					if [ "$select_os_family" == "3" ]
					then
						echo ' [1] Mac OS X (64-bit)'
						echo ' [2] Mac OS X 10.6 Snow Leopard (64-bit)'
						echo ' [3] Mac OS X 10.7 Lion (64-bit)'
						echo ' [4] Mac OS X 10.8 Mountain Lion (64-bit)'
						echo ' [5] Mac OS X 10.9 Mavericks (64-bit)'
					fi

					if [ "$select_os_family" == "4" ]
					then
						echo 'note: no 64-bit versions of OS/2 exist, providing Unknown option)'
						echo 
						echo ' [1] Other/Unknown (64-bit)'
					fi

					if [ "$select_os_family" == "5" ]
					then
						echo ' [1] Solaris 10 5/09 and earlier (64-bit)'
						echo ' [2] Solaris 10 10/09 and later (64-bit)'
						echo ' [3] Solaris 11 (64-bit)'
					fi

					if [ "$select_os_family" == "6" ]
					then
						echo ' [1] Windows XP (64-bit)     [6] Windows 8 (64-bit)'
						echo ' [2] Windows 2003 (64-bit)   [7] Windows 8.1 (64-bit)'
						echo ' [3] Windows Vista (64-bit)  [8] Windows 2012 (64-bit)'
						echo ' [4] Windows 2008 (64-bit)   [9] Other Windows (64-bit)'
						echo ' [5] Windows 7 (64-bit)'
						echo 
					fi

					if [ "$select_os_family" == "7" ]
					then
						echo ' [1] Other/Unknown (64-bit)'
					fi
				fi

				# EXECUTE: Select OS Type:
				echo 
				read -p "OS Type : " select_os_type
				echo 


				# EXECUTE: Map OS Type Selection:

				# 32-bit os_type mapping
				if [ "$select_os_bit" == "1" ]
				then
					if [ "$select_os_family" == "1" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='FreeBSD (32-bit)'; os_type='FreeBSD'; fi
						if [ "$select_os_type" == '2' ]; then os_name='OpenBSD (32-bit)'; os_type='OpenBSD'; fi
						if [ "$select_os_type" == '3' ]; then os_name='NetBSD (32-bit)';  os_type='NetBSD';  fi
					fi
					if [ "$select_os_family" == "2" ]
					then
						if [ "$select_os_type" == '1' ];  then os_name='Arch Linux (32-bit)';    os_type='ArchLinux';  fi
						if [ "$select_os_type" == '2' ];  then os_name='Debian (32-bit)';        os_type='Debian';     fi
						if [ "$select_os_type" == '3' ];  then os_name='Fedora (32-bit)';        os_type='Fedora';     fi
						if [ "$select_os_type" == '4' ];  then os_name='Gentoo (32-bit)';        os_type='Gentoo';     fi
						if [ "$select_os_type" == '5' ];  then os_name='Linux 2.2';              os_type='Linux22';    fi
						if [ "$select_os_type" == '6' ];  then os_name='Linux 2.4 (32-bit)';     os_type='Linux24';    fi
						if [ "$select_os_type" == '7' ];  then os_name='Linux 2.6/3.x (32-bit)'; os_type='Linux26';    fi
						if [ "$select_os_type" == '8' ];  then os_name='Mandriva (32-bit)';      os_type='Mandriva';   fi
						if [ "$select_os_type" == '9' ];  then os_name='Oracle (32-bit)';        os_type='Oracle';     fi
						if [ "$select_os_type" == '10' ]; then os_name='openSUSE (32-bit)';      os_type='OpenSUSE';   fi
						if [ "$select_os_type" == '11' ]; then os_name='Red Hat (32-bit)';       os_type='RedHat';     fi
						if [ "$select_os_type" == '12' ]; then os_name='Turbolinux (32-bit)';    os_type='Turbolinux'; fi
						if [ "$select_os_type" == '13' ]; then os_name='Ubuntu (32-bit)';        os_type='Ubuntu';     fi
						if [ "$select_os_type" == '14' ]; then os_name='Xandros (32-bit)';       os_type='Xandros';    fi
						if [ "$select_os_type" == '15' ]; then os_name='Other Linux (32-bit)';   os_type='Linux';      fi
					fi
					if [ "$select_os_family" == "3" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Mac OS X (32-bit)';                   os_type='MacOS';    fi
						if [ "$select_os_type" == '2' ]; then os_name='Mac OS X 10.6 Snow Leopard (32-bit)'; os_type='MacOS106'; fi
					fi
					if [ "$select_os_family" == "4" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='OS/2 Warp 3';   os_type='OS2Warp3';  fi
						if [ "$select_os_type" == '2' ]; then os_name='OS/2 Warp 4';   os_type='OS2Warp4';  fi
						if [ "$select_os_type" == '3' ]; then os_name='OS/2 Warp 4.5'; os_type='OS2Warp45'; fi
						if [ "$select_os_type" == '4' ]; then os_name='eComStation';   os_type='OS2eCS';    fi
						if [ "$select_os_type" == '5' ]; then os_name='Other OS/2';    os_type='OS2';       fi
					fi
					if [ "$select_os_family" == "5" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Solaris 10 5/09 and earlier (32-bit)'; os_type='Solaris';     fi
						if [ "$select_os_type" == '2' ]; then os_name='Solaris 10 10/09 and later (32-bit)';  os_type='OpenSolaris'; fi
					fi
					if [ "$select_os_family" == "6" ]
					then
						if [ "$select_os_type" == '1' ];  then os_name='Windows 3.1';            os_type='Windows31';    fi
						if [ "$select_os_type" == '2' ];  then os_name='Windows 95';             os_type='Windows95';    fi
						if [ "$select_os_type" == '3' ];  then os_name='Windows 98';             os_type='Windows98';    fi
						if [ "$select_os_type" == '4' ];  then os_name='Windows ME';             os_type='WindowsMe';    fi
						if [ "$select_os_type" == '5' ];  then os_name='Windows NT 4';           os_type='WindowsNT4';   fi
						if [ "$select_os_type" == '6' ];  then os_name='Windows 2000';           os_type='Windows2000';  fi
						if [ "$select_os_type" == '7' ];  then os_name='Windows XP (32-bit)';    os_type='WindowsXP';    fi
						if [ "$select_os_type" == '8' ];  then os_name='Windows 2003 (32-bit)';  os_type='Windows2003';  fi
						if [ "$select_os_type" == '9' ];  then os_name='Windows Vista (32-bit)'; os_type='WindowsVista'; fi
						if [ "$select_os_type" == '10' ]; then os_name='Windows 2008 (32-bit)';  os_type='Windows2008';  fi
						if [ "$select_os_type" == '11' ]; then os_name='Windows 7 (32-bit)';     os_type='Windows7';     fi
						if [ "$select_os_type" == '12' ]; then os_name='Windows 8 (32-bit)';     os_type='Windows8';     fi
						if [ "$select_os_type" == '13' ]; then os_name='Windows 8.1 (32-bit)';   os_type='Windows81';    fi
						if [ "$select_os_type" == '14' ]; then os_name='Other Windows (32-bit)'; os_type='WindowsNT';    fi
					fi
					if [ "$select_os_family" == "7" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Other/Unknown'; os_type='Other';     fi
						if [ "$select_os_type" == '2' ]; then os_name='DOS';           os_type='DOS';       fi
						if [ "$select_os_type" == '3' ]; then os_name='Netware';       os_type='Netware';   fi
						if [ "$select_os_type" == '4' ]; then os_name='L4';            os_type='L4';        fi
						if [ "$select_os_type" == '5' ]; then os_name='QNX';           os_type='QNX';       fi
						if [ "$select_os_type" == '6' ]; then os_name='JRockitVE';     os_type='JRockitVE'; fi
					fi
				fi

				# 64-bit os_type mapping
				if [ "$select_os_bit" == "2" ]
				then
					if [ "$select_os_family" == "1" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='FreeBSD (64-bit)'; os_type='FreeBSD_64'; fi
						if [ "$select_os_type" == '2' ]; then os_name='OpenBSD (64-bit)'; os_type='OpenBSD_64'; fi
						if [ "$select_os_type" == '3' ]; then os_name='NetBSD (64-bit)';  os_type='NetBSD_64';  fi
					fi
					if [ "$select_os_family" == "2" ]
					then
						if [ "$select_os_type" == '1' ];  then os_name='Arch Linux (64-bit)';    os_type='ArchLinux_64';  fi
						if [ "$select_os_type" == '2' ];  then os_name='Debian (64-bit)';        os_type='Debian_64';     fi
						if [ "$select_os_type" == '3' ];  then os_name='Fedora (64-bit)';        os_type='Fedora_64';     fi
						if [ "$select_os_type" == '4' ];  then os_name='Gentoo (64-bit)';        os_type='Gentoo_64';     fi
						if [ "$select_os_type" == '5' ];  then os_name='Linux 2.4 (64-bit)';     os_type='Linux24_64';    fi
						if [ "$select_os_type" == '6' ];  then os_name='Linux 2.6/3.x (64-bit)'; os_type='Linux26_64';    fi
						if [ "$select_os_type" == '7' ];  then os_name='Mandriva (64-bit)';      os_type='Mandriva_64';   fi
						if [ "$select_os_type" == '8' ];  then os_name='openSUSE (64-bit)';      os_type='OpenSUSE_64';   fi
						if [ "$select_os_type" == '9' ];  then os_name='Oracle (64-bit)';        os_type='Oracle_64';     fi
						if [ "$select_os_type" == '10' ]; then os_name='Red Hat (64-bit)';       os_type='RedHat_64';     fi
						if [ "$select_os_type" == '11' ]; then os_name='Turbolinux (64-bit)';    os_type='Turbolinux_64'; fi
						if [ "$select_os_type" == '12' ]; then os_name='Ubuntu (64-bit)';        os_type='Ubuntu_64';     fi
						if [ "$select_os_type" == '13' ]; then os_name='Xandros (64-bit)';       os_type='Xandros_64';    fi
						if [ "$select_os_type" == '14' ]; then os_name='Other Linux (64-bit)';   os_type='Linux_64';      fi
					fi
					if [ "$select_os_family" == "3" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Mac OS X (64-bit)';                    os_type='MacOS_64';    fi
						if [ "$select_os_type" == '2' ]; then os_name='Mac OS X 10.6 Snow Leopard (64-bit)';  os_type='MacOS106_64'; fi
						if [ "$select_os_type" == '3' ]; then os_name='Mac OS X 10.7 Lion (64-bit)';          os_type='MacOS107_64'; fi
						if [ "$select_os_type" == '4' ]; then os_name='Mac OS X 10.8 Mountain Lion (64-bit)'; os_type='MacOS108_64'; fi
						if [ "$select_os_type" == '5' ]; then os_name='Mac OS X 10.9 Mavericks (64-bit)';     os_type='MacOS109_64'; fi
					fi
					if [ "$select_os_family" == "4" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Other/Unknown (64-bit)'; os_type='Other_64'; fi
					fi
					if [ "$select_os_family" == "5" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Solaris 10 5/09 and earlier (64-bit)'; os_type='Solaris_64';     fi
						if [ "$select_os_type" == '2' ]; then os_name='Solaris 10 10/09 and later (64-bit)';  os_type='OpenSolaris_64'; fi
						if [ "$select_os_type" == '3' ]; then os_name='Solaris 11 (64-bit)';                  os_type='Solaris11_64';   fi
					fi
					if [ "$select_os_family" == "6" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Windows XP (64-bit)';    os_type='WindowsXP_64';    fi
						if [ "$select_os_type" == '2' ]; then os_name='Windows 2003 (64-bit)';  os_type='Windows2003_64';  fi
						if [ "$select_os_type" == '3' ]; then os_name='Windows Vista (64-bit)'; os_type='WindowsVista_64'; fi
						if [ "$select_os_type" == '4' ]; then os_name='Windows 2008 (64-bit)';  os_type='Windows2008_64';  fi
						if [ "$select_os_type" == '5' ]; then os_name='Windows 7 (64-bit)';     os_type='Windows7_64';     fi
						if [ "$select_os_type" == '6' ]; then os_name='Windows 8 (64-bit)';     os_type='Windows8_64';     fi
						if [ "$select_os_type" == '7' ]; then os_name='Windows 8.1 (64-bit)';   os_type='Windows81_64';    fi
						if [ "$select_os_type" == '8' ]; then os_name='Windows 2012 (64-bit)';  os_type='Windows2012_64';  fi
						if [ "$select_os_type" == '9' ]; then os_name='Other Windows (64-bit)'; os_type='WindowsNT_64';    fi
					fi
					if [ "$select_os_family" == "7" ]
					then
						if [ "$select_os_type" == '1' ]; then os_name='Other/Unknown (64-bit)'; os_type='Other_64'; fi
					fi
				fi

				# --- OS Type : END -------------------------------------------

				# Final Assignment for ISO and OS Type, based on question path
				iso_assignment "$filtered_iso_path" "$os_type"

				# ---

				# metacache file prompt
				label_title 'Would you like to cache the OS Type to a metacache file?'
				echo 
				echo "Tip: This will cache your OS Type selection for future installs"

				echo 
				echo " [1] Yes"
				echo " [2] No"
				echo 
				read -p "Enter selection : " select_metacache_option

				if [ "$select_metacache_option" == '1' ]
				then
					# write to metacache
					echo 'filtered_iso_path='"$filtered_iso_path" >> "$path_iso/${filtered_iso_title}.metacache"
					echo 'os_name='"$os_name" >> "$path_iso/${filtered_iso_title}.metacache"
					echo 'os_type='"$os_type" >> "$path_iso/${filtered_iso_title}.metacache"
				fi
			fi
		fi

		# exit script if unvailable VM selected
		# TODO: Write regex validation for this later
		if [ "$vbox_iso_install" == "" ] || \
		   [ "$vbox_iso_install" == "$path_iso" ]
		then
			echo "Unavailable VM selected. Exiting script."
			exit 1
		fi
	fi

	# ---------------------------------------
	# IMG ASSIGNMENT:
	# ---------------------------------------
	if [ $vbox_source == 'img' ]
	then
		function img_assignment() {
			local arg1=$1 # iso file

			if [ -f "$arg1" ]
			then
				vbox_img_install="$arg1"
				vbox_img_disk="$vbox_name"'-disk1.vmdk'
			else
				echo 'Unavailable VM selected... exiting script.'
				exit 1
			fi
		}

		# CHOOSE IMG
		label_title 'Which Image would you like to build from?'
		echo 

		stored_imgs_as_paths=$(find -L "$path_img" \( -name "*.ovf" \))                  # TODO: SPACES could break this
		stored_imgs_as_titles=$(echo "$stored_imgs_as_paths" | sed -r 's/.+\/(.+)\.ovf/\1/g;') # TODO: SPACES could break this

		# list out available img's for selection
		stored_img_num=1
		label_success ' [0] manual entry'
		if [ "$stored_imgs_as_titles" == '' ]
		then
			echo 
			label_note ' (no IMGs in storage directory)'
		else
			# TODO: SPACES could break this
			for img in $stored_imgs_as_titles
			do
				echo ' ['"$stored_img_num"'] '"$img"'.ovf'

				stored_img_num=$(expr $stored_img_num + 1)
			done
		fi

		echo 
		read -p "Enter number : " select_img

		# manual IMG entry
		if [ $select_img == "0" ]
		then
			label_title 'Provide complete path of ready-made VM to build from (.ovf file):'
			echo 
			echo 'example filename: /storage/vm_img/debian8-basic.ovf'
			echo 
			read -p "Full IMG path : " manual_img_path
			echo 

			# Final Assignment for a readymade IMG, based on manual input
			img_assignment "$manual_img_path"
		fi

		if [ $select_img != "0" ]
		then
			filtered_img_path=$(filter_list "$stored_imgs_as_paths" "$select_img")
			filtered_img_title=$(filter_list "$stored_imgs_as_titles" "$select_img")

			# Final Assignment for a readymade IMG, based on question path
			img_assignment "$filtered_img_path"
		fi
	fi

	label_null '-------------------------------------------------------------'

	# C5: CPU (1|2|3|4)
	label_title 'How many CPU Cores would you like?'
	echo 
	echo " [1] One CPU Core     [3] Three CPU Core(s)"
	echo " [2] Two CPU Core(s)  [4] Four CPU Core(s)"
	echo 
	read -p "Enter number : " select_cpu_cores

	if [ $select_cpu_cores == "1" ]; then vbox_cpu="1"; fi
	if [ $select_cpu_cores == "2" ]; then vbox_cpu="2"; fi
	if [ $select_cpu_cores == "3" ]; then vbox_cpu="3"; fi
	if [ $select_cpu_cores == "4" ]; then vbox_cpu="4"; fi

	label_null '-------------------------------------------------------------'

	# C6: RAM (512|768|1024|2048|3072|4096)
	label_title 'How much RAM would you like?'
	echo 
	echo " [1] 256mb     [4] 1024mb (1GB)     [7] 4096mb (4GB)"
	echo " [2] 512mb     [5] 2048mb (2GB)"
	echo " [3] 768mb     [6] 3072mb (3GB)"
	echo 
	label_warn 'Tip: Choose low (512mb) and scale later.'
	label_warn '     run htop on VM to monitor RAM'
	label_warn '     increase as needed via: vbix -m'
	echo 
	read -p "Enter number : " select_ram_total

	if [ $select_ram_total == "1" ]; then vbox_ram="256"; fi
	if [ $select_ram_total == "2" ]; then vbox_ram="512"; fi
	if [ $select_ram_total == "3" ]; then vbox_ram="768"; fi
	if [ $select_ram_total == "4" ]; then vbox_ram="1024"; fi
	if [ $select_ram_total == "5" ]; then vbox_ram="2048"; fi
	if [ $select_ram_total == "6" ]; then vbox_ram="3072"; fi
	if [ $select_ram_total == "7" ]; then vbox_ram="4096"; fi

	label_null '-------------------------------------------------------------'

	# C7: STORAGE SIZE
	if [ $vbox_source == 'iso' ]
	then
		# VIRTUAL HD SIZE (5120|8192|10240|20480|30720|40960)
		label_title 'Choose the maximum size limit of your HD:'
		echo 
		echo " [1]  5GB     [4] 20GB     [7] Custom"
		echo " [2]  8GB     [5] 30GB"
		echo " [3] 10GB     [6] 40GB"
		echo 
		echo "note: your HD will start off small and grow to fill this space"
		echo 
		# TODO: Validation needed here
		read -p "Enter number : " select_hd_size

		if [ $select_hd_size == "1" ]; then vbox_hdsize="5120"; fi
		if [ $select_hd_size == "2" ]; then vbox_hdsize="8192"; fi
		if [ $select_hd_size == "3" ]; then vbox_hdsize="10240"; fi
		if [ $select_hd_size == "4" ]; then vbox_hdsize="20480"; fi
		if [ $select_hd_size == "5" ]; then vbox_hdsize="30720"; fi
		if [ $select_hd_size == "6" ]; then vbox_hdsize="40960"; fi

		if [ $select_hd_size == "7" ]
		then
			read -p "Enter custom HD Size in MB (10GB = 10240MB) : " manual_hd_size
			vbox_hdsize="$manual_hd_size"
		fi
	fi

	if [ $vbox_source == 'img' ]
	then
		vbox_hdsize='note: pre-made VM, unable to detect hdsize';
	fi

	label_null '-------------------------------------------------------------'

	# C8: NETWORK SETTING
	label_title 'Network this VM as NAT? or Bridged?'
	echo 
	echo " [1] NAT     : Running virtual network on top of hosts network. "
	echo "               Guest OS only reachable through mapped ports."
	label_good '               (Recommended option)'
	echo 
	echo " [2] Bridged : Request a Unique IP Address from Network Gateway"
	echo "               This shares 'the whole' network interface with host machine"
	label_note '               (For Advanced configs, for mapping to a static IP)'
	echo 
	read -p "Enter number : " select_network

	if [ $select_network == "1" ]; then vbox_network="nat"; fi
	if [ $select_network == "2" ]; then vbox_network="bridged"; fi

	if [ $vbox_network == "bridged" ]
	then
		echo 
		label_title 'Choose network interface for Bridge Adapter'
		echo 
		echo " [0] manual entry"
		echo 
		echo " [1] eth0             [3] eth2"
		echo " [2] eth1             [4] eth3"
		echo 
		read -p "Enter number : " select_bridged_nic

		if [ $select_bridged_nic == "1" ]; then vbox_badpt='eth0'; fi
		if [ $select_bridged_nic == "2" ]; then vbox_badpt='eth1'; fi
		if [ $select_bridged_nic == "3" ]; then vbox_badpt='eth2'; fi
		if [ $select_bridged_nic == "4" ]; then vbox_badpt='eth3'; fi

		if [ $select_bridged_nic == "0" ]
		then
			read -p "Enter name of network interface : " manual_bridged_nic
			vbox_badpt="$manual_bridged_nic"
		fi
	fi

	label_null '-------------------------------------------------------------'

	if [ $vbox_network == "nat" ]
	then
		label_title 'Map 20 additional UDP/TCP ports after the chosen rdp port?'
		echo 
		echo " [1] Yes"
		echo " [2] Yes, with first port mapped to SSH"
		echo " [3] No"
		echo " [4] Custom Number of Ports"
		echo " [5] Custom Number of Ports, with first port mapped to SSH"
		echo " [6] Disable Port Management and manually assign RDP Port"
		echo 
		read -p "Enter number : " select_port_option

		if [ $select_port_option == "4" ] || \
		   [ $select_port_option == "5" ]
		then
			read -p "Custom Number of Ports : " manual_port_range
		fi

		if [ $select_port_option == "6" ]
		then
			config_port_manage='NO'
		fi
	else
		label_null 'skipping port mapping, as no NAT will be used'
	fi

	label_null '-------------------------------------------------------------'

	function request_rdp_port() {
		label_title 'Enter the VirtualBox RDP port for your VM:'
		echo 
		echo 'Tip: Access RDP for a bridged VM at: parent-host-ip:port' # TODO: this comment is confusing, why give this instruction here?
		echo 
		read -p "Enter number : " manual_rdp_port
	}

	if [ $vbox_network == "bridged" ]
	then
		request_rdp_port
	else
		if [ $vbox_network == "nat" ] && [ $config_port_manage == "NO" ]
		then
			request_rdp_port
		else
			label_null 'skipping manual RDP port assignment in-favor of automatic assignment'
		fi
	fi
fi

# -----------------------------------------------------------------------------
# CREATE A VM: NON-INTERACTIVE MODE
# -----------------------------------------------------------------------------

# BUILD DEPENDANCIES BASED ON ARG INPUT
if [ $trig05 == "YES" ] && [ ! -z $copt ] && [ ! -z $nopt ]
then
	function non_int_err() {
		local arg1=$1

		label_error "$arg1"
		if [ ! -z $lopt ]; then echo "$arg1" >> "$log_file"; fi
		exit 1
	}

	# NAME --name
	if [[ ! "$opt_name" =~ ([ \&\:\*\(\)\#\@\!\^\+\?]) ]]
	then vbox_name="$opt_name"
	else non_int_err "BARF --name, $opt_name"
	fi

	# INSTALL --install
	if [[ "$opt_install" =~ ^([-_a-zA-Z0-9]+\.ovf|[-_a-zA-Z0-9]+\.iso)$ ]]
	then
		vbox_install="$opt_install"
		# install iso
		if [[ "$opt_install" =~ ^([-_a-zA-Z0-9]+\.iso)$ ]]
		then
			vbox_source='iso'
			vbox_iso_install="$path_iso/$vbox_install"
			if [[ "$opt_ostype" =~ ( ) ]]
			then
				vbox_ostype="$opt_ostype"
			else
				# this is old code, cons
				# TODO: vbox_ostype="" # lookup table needed
				# ok this is super ghetto, but... doing this for now...
				if [ "$vbox_install" == 'CentOS-7.0-1406-x86_64-NetInstall.iso' ]; then vbox_ostype='Linux_64';     fi
				if [ "$vbox_install" == 'debian-7.7.0-amd64-netinst.iso' ];        then vbox_ostype='Debian_64';    fi
				if [ "$vbox_install" == 'FreeBSD-10.1-RELEASE-amd64-disc1.iso' ];  then vbox_ostype='FreeBSD_64';   fi
				if [ "$vbox_install" == 'WIN7-X17-59463.iso' ];                    then vbox_ostype='Windows7';     fi
				if [ "$vbox_install" == 'Win_Ent_8.1_64BIT.ISO' ];                 then vbox_ostype='Windows81_64'; fi
				if [ "$vbox_install" == 'debian-8.2.0-amd64-netinst.iso' ];        then vbox_ostype='Debian_64';    fi
				if [ "$vbox_install" == 'debian-8.2.0-i386-netinst.iso' ];         then vbox_ostype='Debian_64';    fi
				if [ "$vbox_install" == 'CentOS-6.7-x86_64-minimal.iso' ];         then vbox_ostype='Linux_64';     fi
			fi
		fi
		# install readymade
		if [[ "$opt_install" =~ ^([-_a-zA-Z0-9]+\.ovf)$ ]]
		then
			vbox_source='img'
			vbox_img_install="$path_img/$vbox_install"
			vbox_img_disk="$vbox_name"'-disk1.vmdk'
			vbox_ostype=$(grep -E -i "<vbox:OSType.+>\S+</vbox:OSType>" "$vbox_img_install" | sed -r 's/\s+<vbox:OSType.+>(\S+)<\/vbox:OSType>/\1/g;')
		fi
	else
		non_int_err "BARF --install, $opt_name"
	fi

	# CPU --cpu
	if [[ "$opt_cpu" =~ ^(1|2|3|4)$ ]]
	then vbox_cpu="$opt_cpu"
	else non_int_err "BARF  --cpu, $opt_name"
	fi

	# RAM --ram
	if [[ "$opt_ram" =~ ^((256|512|768)([Mm][Bb])?)|((1024|2048|3072|4096)|((1|2|3|4)[Gg][Bb]))$ ]]
	then
		if [[ "$opt_ram" =~ ^256([Mm][Bb])?$ ]]; then vbox_ram='256'; fi
		if [[ "$opt_ram" =~ ^512([Mm][Bb])?$ ]]; then vbox_ram='512'; fi
		if [[ "$opt_ram" =~ ^768([Mm][Bb])?$ ]]; then vbox_ram='2768'; fi
		if [[ "$opt_ram" =~ ^(1024|1([Gg][Bb]))$ ]]; then vbox_ram='1024'; fi
		if [[ "$opt_ram" =~ ^(2048|2([Gg][Bb]))$ ]]; then vbox_ram='2048'; fi
		if [[ "$opt_ram" =~ ^(3072|3([Gg][Bb]))$ ]]; then vbox_ram='3072'; fi
		if [[ "$opt_ram" =~ ^(4096|4([Gg][Bb]))$ ]]; then vbox_ram='4096'; fi
	else
		non_int_err "BARF --ram, $opt_name"
	fi

	# HDSIZE --hdsize
	if [ "$vbox_source" == 'img' ]
	then
		:
	else
		if [[ "$opt_hdsize" =~ ^(5120|8192|10240|20480|30720|40960)|((5|8|10|20|30|40)[Gg][Bb])$ ]] && [ "$vbox_source" == 'iso' ]
		then
			if [[ "$opt_hdsize" =~ ^(5120|(5[Gg][Bb]))$ ]]; then vbox_hdsize='5120'; fi
			if [[ "$opt_hdsize" =~ ^(8192|(8[Gg][Bb]))$ ]]; then vbox_hdsize='8192'; fi
			if [[ "$opt_hdsize" =~ ^(10240|(10[Gg][Bb]))$ ]]; then vbox_hdsize='10240'; fi
			if [[ "$opt_hdsize" =~ ^(20480|(20[Gg][Bb]))$ ]]; then vbox_hdsize='20480'; fi
			if [[ "$opt_hdsize" =~ ^(30720|(30[Gg][Bb]))$ ]]; then vbox_hdsize='30720'; fi
			if [[ "$opt_hdsize" =~ ^(40960|(40[Gg][Bb]))$ ]]; then vbox_hdsize='40960'; fi
			# TODO: Custom hdsize not yet supported, a new flag will be needed
		else
			non_int_err "BARF --hdsize, $opt_name"
		fi
	fi

	# NETWORK --nic, --ports
	if [[ "$opt_ports" =~ ^(auto|auto22|none|custom|custom22|nopm)$ ]]
	then vbox_ports="$opt_ports"
	else non_int_err "BARF --ports, $opt_name"
	fi

	if [ $vbox_ports == "nopm" ]
	then
		config_port_manage='NO'
	fi

	function map_rdp_port_nint() {
		if [[ "$opt_rdp" =~ ^([0-9]+)$ ]]
		then manual_rdp_port="$opt_rdp"
		else non_int_err "BARF --rdp, $opt_name"
		fi
	}

	if [[ "$opt_nic" =~ ^(nat|bridged:eth[0-9])$ ]]
	then
		if [ "$opt_nic" == 'nat' ]
		then
			vbox_network="$opt_nic"
		else
			vbox_network=$(sed -r 's/(bridged):eth[0-9]/\1/g;' <<< "$opt_nic")
			vbox_badpt=$(sed -r 's/bridged:(eth[0-9])/\1/g;' <<< "$opt_nic")
		fi

		if [ "$vbox_network" == 'bridged' ]
		then
			map_rdp_port_nint
		else
			if [ "$vbox_network" == 'nat' ] && [ $config_port_manage == "NO" ]
			then
				map_rdp_port_nint
			fi
		fi
	else
		non_int_err "BARF --nic, $opt_name"
	fi

	# build custom port range if coming from command line
	if [[ "$opt_ports" =~ ^(custom:[0-9]+)$ ]] || [[ "$opt_ports" =~ ^(custom22:[0-9]+)$ ]]
	then
		manual_port_range=$(sed -r 's/\S+:([0-9]+)/\1/g;' <<< "$opt_ports")
	fi

fi

# -----------------------------------------------------------------------------
# CREATE A VM: PORT MAPPINGS (shared by int/non-int modes)
# -----------------------------------------------------------------------------

# This builds var data for the following port mappings:
#  : vbox_rdp_port
#  : vbox_ports_range (block size)
#  : vbox_ssh_port
#  : vbox_ports_start
#  : vbox_ports_end
# 
# This code merely creates vars, and does not apply them until another 
# step. It pulls data from either the interactive or non-interactive 
# configuration modes. 

if [ $trig06 == "YES" ] && [ ! -z $copt ] && [ $vbox_network == "bridged" ]
then
	vbox_rdp_port="$manual_rdp_port"
fi

if [ $trig06 == "YES" ] && [ ! -z $copt ] && [ $vbox_network == "nat" ]
then
	# assign rdp port
	if [ $config_port_manage == "YES" ]
	then
		label_step 'Automatically selecting an open RDP port slot, to build port range...'

		vm_port_grabslot=$(grep "OPEN" "$path_conf/$file_csv" | head -n 1) # get the first open slot from the list (this is used later on)
		vbox_rdp_port=$(sed -r 's/OPEN,([0-9]+)/\1/g;' <<< "$vm_port_grabslot") # parse the port from the slot, and assign to RDP
	else
		vbox_rdp_port="$manual_rdp_port"
	fi

	# define block size
	if [ "$select_port_option" == "1" ] || \
	   [ "$select_port_option" == "2" ] || \
	   [ "$vbox_ports" == 'auto' ] || \
	   [ "$vbox_ports" == 'auto22' ]
	then
		vbox_ports_range="20"
	fi
	if [ "$select_port_option" == "4" ] || \
	   [ "$select_port_option" == "5" ] || \
	   [[ "$vbox_ports" =~ ^(custom:[0-9]+)$ ]] || \
	   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
	then
		if (( "$manual_port_range" < 100 ))
		then
			vbox_ports_range="$manual_port_range"
		else
			# TODO: This is a potential trap for the user, move as a check when $manual_port_range is actually defined
			label_error 'Error: Custom Number of Ports needs to be less than 100'
			echo 'exiting script...'
			exit 1
		fi
	fi

	# define ssh (if selected)
	if [ "$select_port_option" == "2" ] || \
	   [ "$select_port_option" == "5" ] || \
	   [ "$vbox_ports" == 'auto22' ] || \
	   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
	then
		vbox_ssh_port=$(expr "$vbox_rdp_port" + 1)
	fi

	# define ports start
	if [ "$select_port_option" == "1" ] || \
	   [ "$select_port_option" == "4" ] || \
	   [ "$vbox_ports" == 'auto' ] || \
	   [[ "$vbox_ports" =~ ^(custom:[0-9]+)$ ]]
	then
		vbox_ports_start=$(expr "$vbox_rdp_port" + 1)
	fi
	if [ "$select_port_option" == "2" ] || \
	   [ "$select_port_option" == "5" ] || \
	   [ "$vbox_ports" == 'auto22' ] || \
	   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
	then
		vbox_ports_start=$(expr "$vbox_ssh_port" + 1)
	fi

	# define ports end
	if [ "$select_port_option" == "1" ] || \
	   [ "$select_port_option" == "2" ] || \
	   [ "$select_port_option" == "4" ] || \
	   [ "$select_port_option" == "5" ] || \
	   [ "$vbox_ports" == 'auto' ] || \
	   [ "$vbox_ports" == 'auto22' ] || \
	   [[ "$vbox_ports" =~ ^(custom:[0-9]+)$ ]] || \
	   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
	then
		vbox_ports_end=$(expr "$vbox_rdp_port" + "$vbox_ports_range")
	fi
fi

# -----------------------------------------------------------------------------
# CREATE A VM: VERIFY BEFORE CREATION
# -----------------------------------------------------------------------------

if [ $trig07 == "YES" ]
then
	if [ ! -z $copt ] && [ -z $nopt ]
	then
		label_banner 'VERIFY YOUR SELECTIONS'

		label_warn 'Your Virtualbox VM Configuration:'

		echo 
		# TODO: Check these for empty strings, and show error
		echo ' vbox_name        : '"$vbox_name"
		if [ $vbox_source == 'iso' ]
		then
			echo ' vbox_iso_install : '"$vbox_iso_install"
		fi
		if [ $vbox_source == 'img' ]
		then
			echo ' vbox_img_install : '"$vbox_img_install"
		fi
		echo ' vbox_ostype      : '"$vbox_ostype"
		echo ' vbox_cpu         : '"$vbox_cpu"
		echo ' vbox_ram         : '"$vbox_ram"
		echo ' vbox_network     : '"$vbox_network"
		if [ "$vbox_network" == 'bridged' ]
		then
			echo ' vbox_badpt       : '"$vbox_badpt"
		fi
		echo ' vbox_hdsize      : '"$vbox_hdsize"
		echo ' vbox_rdp_port    : '"$vbox_rdp_port"
		if [ "$select_port_option" != '3' ] && [ "$vbox_network" == 'nat' ]
		then
			echo ' vbox_ssh_port    : '"$vbox_ssh_port"
		fi
		echo 

		label_warn 'Script VM Defaults:'

		echo 
		echo ' 1 SATA Controller'
		echo ' 1 IDE Controller'
		echo ' 6 SATA Ports'
		echo ' I/O APIC ON'
		echo ' VRDE Multi-Connection Support'
		if [ $config_ext_pack_vnc == "YES" ]
		then
			echo ' VRDE VNC'
		else
			echo ' VRDE RDP'

			if [ $config_vrde_tls == "YES" ]
			then echo ' RDP TLS Encryption ON'
			else echo ' RDP TLS Encryption OFF'
			fi
		fi
		echo 

		proceed_or_exit
	fi
fi

# -----------------------------------------------------------------------------
# CREATE A VM: EXECUTIONS
# -----------------------------------------------------------------------------

if [ $trig08 == "YES" ] && [ ! -z $copt ]
then
	# -------------------------------------------------------------------------
	# BUILD VM SHELL
	# -------------------------------------------------------------------------

	if [ $trig08a == "YES" ]
	then
		if [ $vbox_source == 'iso' ]
		then
			label_banner 'BUILD VM SHELL'

			# set vmname and register it, under "./VirtualBox\ VMs/<vmname>"
			label_step 'Set vmname and register it'
			vboxmanage createvm --name "$vbox_name" --ostype "$vbox_ostype" --register
		fi
		if [ $vbox_source == 'img' ]
		then
			if [ -f "$vbox_img_install" ]
			then
				label_banner 'BUILD VM SHELL'
				label_step 'Build new VM from Ready-Made Image, setting name, cpu, and ram'
				# run this on ovf file after exporting:
				#   sed -ri 's/^\s+<Forwarding name=.+$//g;' "$vbox_img_install"
				vboxmanage import "$vbox_img_install" --vsys 0 --vmname "$vbox_name" --cpus "$vbox_cpu" --memory "$vbox_ram" --unit 9 --disk "$path_vbox_vms/$vbox_name/$vbox_img_disk"
			else
				label_error 'Error: [ '"$vbox_img_install"' ] not found'
				exit 1
			fi
		fi
	fi

	# -------------------------------------------------------------------------
	# CPU + RAM
	# -------------------------------------------------------------------------

	if [ $trig08b == "YES" ] && [ $vbox_source == 'iso' ]
	then
		label_banner 'CPU + RAM'

		# set vm memory and CPU core count, turn on ACPI
		vboxmanage modifyvm "$vbox_name" --cpus "$vbox_cpu" --memory "$vbox_ram" --acpi on

		# turn on IOAPIC
		label_step 'Turn on IOAPIC, needed for x64_windows, x64, and multi-cpu core systems'
		vboxmanage modifyvm "$vbox_name" --ioapic on

		# TODO: This Windows 8.1 fix may not be needed on versions of Virtualbox 5.0 and up.
		#       Also, if a user specifies Win 8.1 and doesn't set the ostype properly, this 
		#       block will fail to run.
		if [ $vbox_ostype == "Windows81_64" ]
		then
			# adds the CMPXCHG16B CPU instruction that's missing from the default configuration of VirtualBox
			label_step 'Add CMPXCHG16B CPU instruction'
			vboxmanage setextradata "$vbox_name" VBoxInternal/CPUM/CMPXCHG16B 1
		fi
	fi

	# -------------------------------------------------------------------------
	# STORAGE DEVICES
	# -------------------------------------------------------------------------

	if [ $trig08c == "YES" ] && [ $vbox_source == 'iso' ]
	then
		label_banner 'STORAGE DEVICE'

		# create a raw hd image
		label_step 'Create a raw hd image'
		vboxmanage createhd --filename "$path_vbox_vms/$vbox_name/$vbox_name.vdi" --size "$vbox_hdsize"

		# assign SATA controller
		label_step 'Assign SATA controller'
		vboxmanage storagectl "$vbox_name" --name "SATA_Controller" --add sata --portcount 6

		# assign IDE controller
		label_step 'Assign IDE controller'
		vboxmanage storagectl "$vbox_name" --name "IDE_Controller" --add ide

		# attach VDI drive image
		label_step 'Attach VDI drive image'
		vboxmanage storageattach "$vbox_name" --storagectl "SATA_Controller" --port 0 --device 0 --type hdd --medium "$path_vbox_vms/$vbox_name/$vbox_name.vdi"

		# attach ISO disc image
		label_step 'Attach ISO disc image'
		vboxmanage storageattach "$vbox_name" --storagectl "IDE_Controller" --port 0 --device 0 --type dvddrive --medium "$vbox_iso_install"

		# set boot device to DVD
		vboxmanage modifyvm "$vbox_name" --boot1 dvd
	fi

	# -------------------------------------------------------------------------
	# NETWORKING
	# -------------------------------------------------------------------------

	if [ $trig08d == "YES" ]
	then
		label_banner 'CONFIGURE NETWORK SETTINGS'

		if [ "$vbox_network" == "nat" ]
		then
			# set network mode to nat networking
			label_step 'Set network mode to nat networking'
			vboxmanage modifyvm "$vbox_name" --nic1 nat --cableconnected1 on

			# port checkout procedure
			label_step 'Checkout a port range from the list'
			if [ $config_port_manage == "YES" ]
			then
				check_md5 "$path_conf/$file_md5"
				sed -ri 's/^('"$vm_port_grabslot"')$/CLOSED,'"$vbox_rdp_port"','"$vbox_name"'/g' "$path_conf/$file_csv"
				md5sum "$path_conf/$file_csv" > "$path_conf/$file_md5"
				md5sum -c "$path_conf/$file_md5"
			fi

			# forward all incoming traffic from a host interface to the guest via a single port
			label_step 'Forward the SSH port'
			if [ "$select_port_option" == "2" ] || \
			   [ "$select_port_option" == "5" ] || \
			   [ "$vbox_ports" == 'auto22' ] || \
			   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
			then
				vboxmanage modifyvm "$vbox_name" --natpf1 "tcp-port-ssh,tcp,,$vbox_ssh_port,,22"
			fi

			# map port range from $vbox_ports_start to $vbox_ports_end, for udp and tcp
			label_step 'Map assigned port range'
			if [ "$select_port_option" == "1" ] || \
			   [ "$select_port_option" == "2" ] || \
			   [ "$select_port_option" == "4" ] || \
			   [ "$select_port_option" == "5" ] || \
			   [ "$vbox_ports" == 'auto' ] || \
			   [ "$vbox_ports" == 'auto22' ] || \
			   [[ "$vbox_ports" =~ ^(custom:[0-9]+)$ ]] || \
			   [[ "$vbox_ports" =~ ^(custom22:[0-9]+)$ ]]
			then
				for i in $(eval echo "{$vbox_ports_start..$vbox_ports_end}")
				do
					vboxmanage modifyvm "$vbox_name" --natpf1 "tcp-port$i,tcp,,$i,,$i"
					vboxmanage modifyvm "$vbox_name" --natpf1 "udp-port$i,udp,,$i,,$i"
				done
			fi
		fi

		if [ "$vbox_network" == "bridged" ]
		then
			# set network mode to bridged networking
			label_step 'Set network mode to bridged networking'
			vboxmanage modifyvm "$vbox_name" --nic1 bridged --bridgeadapter1 "$vbox_badpt"
		fi
	fi

	# -------------------------------------------------------------------------
	# VRDE SETTINGS (RDP or VNC)
	# -------------------------------------------------------------------------

	# VRDE (VirtualBox Remote Desktop Extension) is an interface, that allows for RDP or VNC

	if [ $trig08e == "YES" ]
	then
		label_banner 'REMOTE DESKTOP SETTINGS'

		# ---------------------------------------------------------------------
		# General VRDE Configuration
		# ---------------------------------------------------------------------

		# enable remoting feature
		label_step 'Enable Remoting'
		vboxmanage modifyvm "$vbox_name" --vrde on

		# enable rdp multicon, for multi-user collaboration
		label_step 'Enable multiple simultaneous connections to RDP'
		vboxmanage modifyvm "$vbox_name" --vrdemulticon on

		# enable bidirectional clipboard transfer (text only, not files)
		label_step 'Enable bidirectional clipboard'
		vboxmanage modifyvm "$vbox_name" --clipboard bidirectional

		# enable file drag and drop support, from host to guest
		label_step 'Enable drag and drop support'
		vboxmanage modifyvm "$vbox_name" --draganddrop hosttoguest

		# ---------------------------------------------------------------------
		# Default VRDE settings
		# ---------------------------------------------------------------------

		# set VRDE port
		label_step 'Set VRDE port'
		vboxmanage modifyvm "$vbox_name" --vrdeport "$vbox_rdp_port"

		# ---------------------------------------------------------------------
		# Default VRDE VNC (open source)
		# ---------------------------------------------------------------------

		if [ $config_vrde_private == 'YES' ]
		then
			# restrict to localhost
			label_step 'Restrict to localhost'
			vboxmanage modifyvm "$vbox_name" --vrdeaddress '127.0.0.1'
		fi

		# ---------------------------------------------------------------------
		# VRDE RDP via Oracle Extensions Pack (proprietary, not open source)
		# ---------------------------------------------------------------------

		if [ $config_ext_pack_vnc == 'NO' ]
		then

			# enable external authorization (security)
			# note: parent system u:p required to access the VM
			label_step 'Enable external RDP authentication'
			vboxmanage modifyvm "$vbox_name" --vrdeauthtype external

			# TODO: This still needs to be integrated into the script properly, where certs can be generated from within the script.
			if [ $config_vrde_tls == 'YES' ]
			then
				if [ -d "$path_cert" ] && \
				   [ -f "$path_cert/ca_cert.pem" ] && \
				   [ -f "$path_cert/server_cert.pem" ] && \
				   [ -f "$path_cert/server_key_private.pem" ]
				then
					# Enhanced Security
					vboxmanage modifyvm "$vbox_name" --vrdeproperty "Security/Method=TLS"
					vboxmanage modifyvm "$vbox_name" --vrdeproperty "Security/CACertificate=$path_cert/ca_cert.pem"
					vboxmanage modifyvm "$vbox_name" --vrdeproperty "Security/ServerCertificate=$path_cert/server_cert.pem"
					vboxmanage modifyvm "$vbox_name" --vrdeproperty "Security/ServerPrivateKey=$path_cert/server_key_private.pem"
				else
					label_error 'Error: Local Certificates for TLS Encryption not found.'
					echo "Consult VirtualBox Documentation to enable TLS Encryption for the RDP5.2 protocol."
					label_warn "Proceeding to create the VM without TLS Security."
					echo 
					echo 'Manually apply encryption to your VM using the following commands:'
					echo 
					echo '  $ vboxmanage modifyvm "<vm_name>" --vrdeproperty "Security/Method=TLS"'
					echo '  $ vboxmanage modifyvm "<vm_name>" --vrdeproperty "Security/CACertificate='"$path_cert"'/ca_cert.pem"'
					echo '  $ vboxmanage modifyvm "<vm_name>" --vrdeproperty "Security/ServerCertificate='"$path_cert"'/server_cert.pem"'
					echo '  $ vboxmanage modifyvm "<vm_name>" --vrdeproperty "Security/ServerPrivateKey='"$path_cert"'/server_key_private.pem"'
					echo 
				fi
			fi
		fi

		#chk_extpack=$(vboxmanage list extpacks | grep -ioh "Oracle VM VirtualBox Extension Pack")
		#if [ "$chk_extpack" == "Oracle VM VirtualBox Extension Pack" ]
		#then
		#	vboxmanage modifyvm "$vbox_name" --vrdeextpack "Oracle VM VirtualBox Extension Pack"
		#fi
	fi

	# -------------------------------------------------------------------------
	# FINALIZE VM CREATION
	# -------------------------------------------------------------------------

	if [ $trig08f == "YES" ]
	then
		label_success 'VM Creation Process Complete.'
		if [ $vbox_source == 'iso' ]
		then
			echo "Use the manage prompt to remove the installer.iso from the DVD Drive "
			echo "after OS install. Otherwise your VM will boot to disk and SSH will be "
			echo "inaccessible. "
		fi
		label_null 'Use the -m flag to manage your created VM'\''s.'
	fi

fi

# -----------------------------------------------------------------------------
# MANAGE A VM (vbix -m)
# -----------------------------------------------------------------------------

if [ $trig09 == "YES" ] && [ ! -z $mopt ]
then
	# -------------------------------------------------------------------------
	# MANAGE... NON-INTERACTIVE MODE (cli)
	# -------------------------------------------------------------------------

	if [ ! -z $nopt ]
	then

		# RUN --run
		if [ "$opt_run" != '' ] && \
		   [ "$opt_poweroff" == '' ] && \
		   [ "$opt_restart" == '' ] && \
		   [ "$opt_savestate" == '' ] && \
		   [ "$opt_vmexport" == '' ]
		then
			chk_vmname "$opt_run"
	#		echo "vm_to_manage: $vm_to_manage"
			# run
			nohup VBoxHeadless -s "$opt_run" &
			# TODO: check to see if $vm_to_manage is actually running
			# if true, then show the following:
	#		echo 'Starting your VM...'
			sleep 3 # this is needed!!! running vboxmanage showvminfo so quickly after starting a vm causes VBoxHeadless -s to fail and go into a lock state
			echo "Your VM is now running, and accessible via Remote Desktop at:"
			vboxmanage showvminfo "$opt_run" | grep -E -i "VRDE.+Ports  =" | sed -r "s/^.+\"([0-9]+)\"/\1/g;"
			#echo "You have an open port range from $vbox_ports_start to $vbox_ports_end"
		fi

		# POWEROFF --poweroff
		if [ "$opt_run" == '' ] && \
		   [ "$opt_poweroff" != '' ] && \
		   [ "$opt_restart" == '' ] && \
		   [ "$opt_savestate" == '' ] && \
		   [ "$opt_vmexport" == '' ]
		then
			# TODO: Check if path/opt exists: if [ -d "$var" ]; then ; else exit 1; fi
			chk_vmname "$opt_poweroff"
			vboxmanage controlvm "$opt_poweroff" poweroff
		fi

		# RESTART --restart
		if [ "$opt_run" == '' ] && \
		   [ "$opt_poweroff" == '' ] && \
		   [ "$opt_restart" != '' ] && \
		   [ "$opt_savestate" == '' ] && \
		   [ "$opt_vmexport" == '' ]
		then
			chk_vmname "$opt_restart"
			vboxmanage controlvm "$opt_restart" reset
		fi

		# SAVESTATE --savestate
		if [ "$opt_run" == '' ] && \
		   [ "$opt_poweroff" == '' ] && \
		   [ "$opt_restart" == '' ] && \
		   [ "$opt_savestate" != '' ] && \
		   [ "$opt_vmexport" == '' ]
		then
			chk_vmname "$opt_savestate"
			vboxmanage controlvm "$opt_savestate" savestate
		fi

		# VMEXPORT --vmexport, usage: vbix -mn --vmexport='debian8:debian8-basic'
		# TODO: Add to interactive mode
		if [ "$opt_run" == '' ] && \
		   [ "$opt_poweroff" == '' ] && \
		   [ "$opt_restart" == '' ] && \
		   [ "$opt_savestate" == '' ] && \
		   [ "$opt_vmexport" != '' ]
		then
			vmexport_src=$(sed -r 's/(\S+):\S+/\1/g;' <<< "$opt_vmexport")
			vmexport_dest=$(sed -r 's/\S+:(\S+)/\1/g;' <<< "$opt_vmexport")

			if [ ! -f "$path_img/$vmexport_dest"'.ovf' ]
			then
				if [[ "$opt_vmexport" =~ ^([-_a-zA-Z0-9]+:[-_a-zA-Z0-9]+)$ ]]
				then
					vboxmanage export "$vmexport_src" --output "$path_img/$vmexport_dest"'.ovf'
				else
					label_error 'Error: --vmexport not in the right format, type -h for help'
					if [ ! -z $lopt ]; then echo 'Error: --vmexport not in the right format, type -h for help' >> "$log_file"; fi
					exit 1
				fi
			else
				label_warn 'Warning: file [ '"$vmexport_dest"' already exists.'
				echo 'if re-exporting a fresher version, first remove manually from: '"$path_img"
				echo '- OR -'
				echo 'adjust your vmname to another unique name to avoid the conflict'
				exit 1
			fi
		fi
	fi

	# -------------------------------------------------------------------------
	# MANAGE... INTERACTIVE MODE
	# -------------------------------------------------------------------------

	if [ -z $nopt ]
	then
		label_banner 'MANAGE A VM'

		label_title 'Perform an action on the following VM'\''s:'
		echo 

		num_i=1

		# Select VM
		for i in "${!arr_created[@]}"
		do
			printf " [%d] %s\n" $i "${arr_created[$i]}"
		done
		echo 
		read -p "VM to manage : " select_vm_to_manage
		echo 

		vm_to_manage="${arr_created[$select_vm_to_manage]}"

		# Choose Action
		label_title 'Choose action to perform on:'

		echo 
		label_step " $vm_to_manage"
		echo 

		if [ -z $xopt ]
		then
			echo -e ' [ 1] ''\e[1;32m''Run the VM''\e[0m''        (power on                 )' #: -r
			echo -e ' [ 2] ''\e[1;31m''Poweroff the VM''\e[0m''   (pull the power cable     )' #: -p
			echo -e ' [ 3] ''\e[1;33m''Restart the VM''\e[0m''    (reboot the machine       )' #:   
			echo -e ' [ 4] ''\e[1;36m''Suspend the VM''\e[0m''    (save state and power off )' #: -s
			echo -e ' [ 5] ''\e[1;37;41m''Delete the VM''\e[0m''     (clear all contents       )' #: -d
		else
			echo ' [ 1] Run the VM        (power on                 )' #: -r
			echo ' [ 2] Poweroff the VM   (pull the power cable     )' #: -p
			echo ' [ 3] Restart the VM    (reboot the machine       )' #:   
			echo ' [ 4] Suspend the VM    (save state and power off )' #: -s
			echo ' [ 5] Delete the VM     (clear all contents       )' #: -d
		fi
		echo 
		echo ' [ 6] Adjust RAM        (Increase/Decrease RAM    )' #:   
		echo ' [ 7] List Port Maps    (lists all assigned ports )' #:   
		echo ' [ 8] List Drives       (DVD/HDD Storage Media    )' #:   
		echo ' [ 9] Disc Drive        (insert/remove media      )' #:   
		echo ' [10] ---               (-                        )' #:   
		echo 
		read -p "Action (number): " select_manage_option
		echo 

		if [ $select_manage_option == "1" ]
		then
			echo "vm_to_manage: $vm_to_manage"
			# run
			nohup VBoxHeadless -s "$vm_to_manage" &
			# TODO: check to see if $vm_to_manage is actually running
			# if true, then show the following:
			echo 'Starting your VM...'
			sleep 3 # this is needed!!! running vboxmanage showvminfo so quickly after starting a vm causes VBoxHeadless -s to fail and go into a lock state
			echo "Your VM is now running, and accessible via Remote Desktop at:"
			vboxmanage showvminfo "$vm_to_manage" | grep -E -i "VRDE.+Ports  =" | sed -r "s/^.+\"([0-9]+)\"/\1/g;"
			#echo "You have an open port range from $vbox_ports_start to $vbox_ports_end"
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "2" ]
		then
			# poweroff
			vboxmanage controlvm "$vm_to_manage" poweroff
			# TODO: Verification Block Needed
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "3" ]
		then
			# reboot
			vboxmanage controlvm "$vm_to_manage" reset
			# TODO: Verification Block Needed
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "4" ]
		then
			# suspend
			vboxmanage controlvm "$vm_to_manage" savestate
			# TODO: Verification Block Needed
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "5" ]
		then
			# caution! this deletes the vdi file too
			label_error 'Delete the following VM?'
			echo 
			label_step "$vm_to_manage"
			echo 
			read -p "Type DELETE_THIS_VM to proceed: " manual_delete_verification

			if [ $manual_delete_verification == 'DELETE_THIS_VM' ]
			then
				if [ $config_port_manage == "YES" ]
				then
					# RE-OPEN PORT AFTER DELETING VM
					vm_vrde_port=$(vboxmanage showvminfo "$vm_to_manage" | grep -E -ioha "VRDE property\s*:\s+TCP/Ports\s+=\s+\"[0-9]+\"" | grep -E -ioha "[0-9]+")

					check_md5 "$path_conf/$file_md5"
					sed -ri 's/CLOSED,'"$vm_vrde_port"','"$vm_to_manage"'/OPEN,'"$vm_vrde_port"'/g;' "$path_conf/$file_csv"
					md5sum "$path_conf/$file_csv" > "$path_conf/$file_md5"
				fi

				# delete vm (destructive process)
				label_step 'executing delete operation...'
				vboxmanage unregistervm "$vm_to_manage" --delete

				if [ ! -f "$path_vbox_vms/$vm_to_manage/$vm_to_manage"'.vdi' ]
				then
					label_success 'DONE: vm delete operation successful for [ '"$vm_to_manage"' ]'
					if [ -d "$path_vbox_vms/$vm_to_manage" ]
					then
						label_note 'note: vm directory still exists for [ '"$vm_to_manage"' ]'
						echo 'This is most likely due to user created files being present within the '
						echo 'dirctory. Consider manually deleting the folder to prevent the script '
						echo 'from complaining in -i mode.'
					fi
				else
					label_error 'error: vm delete operation failed, .vdi file still exists'
				fi
			else
				label_error "Error: Text entry not valid, try again."
			fi
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "6" ]
		then
			read -p "New RAM total in MB (512/768/1024/2048/3072/4096) : " manual_modify_ram_total
			vboxmanage modifyvm "$vm_to_manage" --memory "$manual_modify_ram_total"
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "7" ]
		then
			vboxmanage showvminfo "$vm_to_manage" | grep -E "NIC\s[0-9]\s" | less
		fi

		# ---------------------------------------------------------------------

		if [ $select_manage_option == "8" ]
		then
			label_note 'Storage Controller Status (Prior to Modification):'
			show_storagectrl_info "$vm_to_manage"
		fi

		# ---------------------------------------------------------------------

		# EXPERIMENTAL DRIVE EJECT CODE - START
		if [ $select_manage_option == "9" ]
		then
			# -- Question -------------------------

			label_good 'If you created your VM with this script, and did not add any new drives:'

			echo 
			echo ' [1] Eject the disc.iso (automatic)'
			echo ' [2] Insert a disc.iso (automatic)'
			echo 

			label_note 'If you added a new drive, or your VM was NOT created with this script'

			echo 
			echo ' [3] Eject the disc.iso (manual)'
			echo ' [4] Insert a disc.iso (manual)'
			echo 

			read -p 'Choose an action: ' select_disc_action
			echo 

			# -- Execute --------------------------

			# Eject the disc.iso (automatic)
			if [ $select_disc_action == "1" ]
			then
				vboxmanage storageattach "$vm_to_manage" --storagectl "IDE_Controller" --port 0 --device 0 --type dvddrive --medium "emptydrive"
				label_note 'Listing drive info for visual verification:'
				show_storagectrl_info "$vm_to_manage"
			fi

			# Insert a disc.iso (automatic)
			if [ $select_disc_action == "2" ]
			then
				read -p "Enter ISO with full path : " manual_disc_path
				vboxmanage storageattach "$vm_to_manage" --storagectl "IDE_Controller" --port 0 --device 0 --type dvddrive --medium "$manual_disc_path"
				label_note 'Listing drive info for visual verification:'
				show_storagectrl_info "$vm_to_manage"
			fi

			# Eject the disc.iso (manual)
			if [ $select_disc_action == "3" ]
			then
				label_note 'Storage Controller Status (Prior to Modification):'
				show_storagectrl_info "$vm_to_manage"
				echo 

				label_title 'Empty DVD drive:'

				read -p "Enter storage controller (storagectl) name: " manual_storagectl_name
				read -p "Enter port and device id's in the following format 0,1: " manual_port_device_id

				chk_pd_entry=$(echo "$manual_port_device_id" | grep -o "^[0-9],[0-9]$")

				if [ "$chk_pd_entry" != '' ]
				then
					port_id=$(sed -r "s/^([0-9]),([0-9])$/\1/g;" <<< "$manual_port_device_id")
					device_id=$(sed -r "s/^([0-9]),([0-9])$/\2/g;" <<< "$manual_port_device_id")
					vboxmanage storageattach "$vm_to_manage" --storagectl "$manual_storagectl_name" --port "$port_id" --device "$device_id" --type dvddrive --medium "emptydrive"
					label_step 'Disc Removed from DVD drive for VM: '"$vm_to_manage"
					label_note 'Listing drive info for visual verification:'
					show_storagectrl_info "$vm_to_manage"
				else
					echo "Error: Port/Device id not entered correctly."
				fi
			fi

			# Insert a disc.iso (manual)
			if [ $select_disc_action == "4" ]
			then
				label_note 'Storage Controller Status (Prior to Modification):'
				show_storagectrl_info "$vm_to_manage"
				echo 

				label_title 'Insert new disc into DVD drive:'

				read -p "Enter storage controller (storagectl) name: " manual_storagectl_name
				read -p "Enter port and device id's in the following format 0,1: " manual_port_device_id

				chk_pd_entry=$(echo "$manual_port_device_id" | grep -o "^[0-9],[0-9]$")

				if [ "$chk_pd_entry" != '' ]
				then
					port_id=$(sed -r "s/^([0-9]),([0-9])$/\1/g;" <<< "$manual_port_device_id")
					device_id=$(sed -r "s/^([0-9]),([0-9])$/\2/g;" <<< "$manual_port_device_id")

					read -p "Enter ISO with full path : " manual_disc_path

					#vboxmanage storageattach "$vm_to_manage" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium "$manual_disc_path"

					# Experimental Error Checking
					#chk_device_expect="IDE_Controller ($port_id, $device_id): Empty"
					#chk_device_grep=$(vboxmanage showvminfo oclinux | grep -E "IDE_Controller \($port_id, $device_id\)")
					#if [ "$chk_device_expect" == "$chk_device_grep" ]
					#then
						vboxmanage storageattach "$vm_to_manage" --storagectl "$manual_storagectl_name" --port "$port_id" --device "$device_id" --type dvddrive --medium "$manual_disc_path"
					#else
					#	echo "Error: IDE_Controller not detected as the storagectl name for the dvddrive, or the drive is not empty."
					#fi
					label_note 'Listing drive info for visual verification:'
					show_storagectrl_info "$vm_to_manage"
				else
					echo "Error: Port/Device id not entered correctly."
				fi
			fi
		fi
		# EXPERIMENTAL DRIVE EJECT CODE - END
	fi
fi

# ---

fi
