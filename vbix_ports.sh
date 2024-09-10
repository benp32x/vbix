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
# PATHS:
# -----------------------------------------------------------------------------

sh_local='YES' # YES|(NO)

# build path to users home dir
v_pwd=$(pwd); cd ~/; path_user_home=$(pwd); cd "$v_pwd";

file_csv='vbix_ports.csv'
file_md5='vbix_ports.md5'

# paths main
if [ $sh_local == 'YES' ]
then path_conf="$path_user_home/vbix/vbix_conf"  # ports csv/md5 stored here
else path_conf='/usr/local/conf/vbix'            # vix_ports.csv|.md5 stored here
fi

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
# SETUP PORT BLOCKS:
# -----------------------------------------------------------------------------

if [ ! -d "$path_conf" ]
then
	label_error 'error: conf path does not exist [ '"$path_conf"' ]'
	exit 1
fi

# build ports.csv and md5 hash, if csv does not already exist
if [ ! -f "$path_conf/$file_csv" ]
then
	echo 

	# port range assignments
	label_title 'Configure NAT port range:'

	echo 'Scalable pattern, 40 vm slots : 5000-8900, block_size = 100 ports'
	echo 'Conservative pattern, 20 vm slots : 55000-56000, block_size = 50 ports'
	echo 
	echo 'note: minimum blocksize is 20, maximum blocksize is 100'
	echo 
	read -p ' Start Port : ' start_port
	read -p ' End Port   : ' end_port

	function set_blocksize() {
		read -p ' Block Size : ' block_size
		echo 
		if [[ "$block_size" =~ ([0-9]+) ]] && (( $block_size > 19 )) && (( $block_size < 101 ))
		then
			label_warn 'Review Port Assignments:'

			echo 
			echo "$start_port - $end_port, $block_size ports per block"
			echo 

			read -p "Press Enter to Proceed"
		else
			label_error 'error: minimum blocksize is 20, maximum blocksize is 100 : try again'
			set_blocksize
		fi
	}
	set_blocksize

	# generate csv
	touch "$path_conf/$file_csv"
	for (( i="$start_port"; i<"$end_port"; i+="$block_size" ))
	do
		echo "OPEN,$i" >> "$path_conf/$file_csv"
	done

	# verify csv creation
	chk_csv_file=$(stat -c %s "$path_conf/$file_csv")

	if [ -f "$path_conf/$file_csv" ] && (( $chk_csv_file > 0 ))
	then
		label_success "$file_csv"' successfully written to: [ '"$path_conf"'/ ]'
	else
		label_error 'error: '"$file_csv"' generation failed, file empty or missing'
		proceed_or_exit
	fi

	# generate MD5 sum
	md5sum "$path_conf/$file_csv" > "$path_conf/$file_md5"

	# verify md5 creation
	chk_md5_file=$(stat -c %s "$path_conf/$file_md5")

	if [ -f "$path_conf/$file_md5" ] && (( $chk_md5_file > 0 ))
	then
		label_success "$file_md5"' successfully written to: [ '"$path_conf"'/ ]'
	else
		label_error 'error: MD5 checksum for '"$file_csv"' failed, file empty or missing'
		proceed_or_exit
	fi
else
	echo "$file_csv"' file already exists'
	proceed_or_exit
fi
