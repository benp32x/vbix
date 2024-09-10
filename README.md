# What is vbix?

![vbix](<./img/logo.png>)

vbix provides a text based interface for managing virtualbox based virtual machines.

I needed a bare metal server, running most of my applications on the performant parent Linux OS, but also needed a few small virtual machines for other services, and even the occasional vm for "curious experiments". I didn't necessarily require a hypervisor, and Cloud Service costs might have exceeded a decent dedicated server. The VM's were for non-container situations. So, I started writing bash code against virtualbox commands, and this script gradually evolved.

If you need a basic management tool for Virtualbox over command line, then "vbix" is a great option.

Some key features of vbix:

* Manages port assignments in "blocks" for NAT based vm's, allowing convenient management of multiple VM's on a remote machine with only a single IPv4 address
* Auto-map's the SSH port for a NAT based VM during the vm creation process
* Supports building from .iso's or exported vm images
* The VM creation process can be very fast, proving that text based interfaces can reign supreme

vbix features a management interface, making it convenient to check the status of your running vms, and manage them with the following operations:

```
  [ 1] Run the VM        (power on                 )
  [ 2] Poweroff the VM   (pull the power cable     )
  [ 3] Restart the VM    (reboot the machine       )
  [ 4] Suspend the VM    (save state and power off )
  [ 5] Delete the VM     (clear all contents       )
  
  [ 6] Adjust RAM        (Increase/Decrease RAM    )
  [ 7] List Port Maps    (lists all assigned ports )
  [ 8] List Drives       (DVD/HDD Storage Media    )
  [ 9] Disc Drive        (insert/remove media      )
```

I consider vbix to be not only a useful script, but also a great example of how empowering BASH can be in "personal" computing.

# How does it work?

vbix wraps a text based interface around vboxmanage commands, and adds a comma delimited set of port blocks for NAT based VM's to checkout on creation.

vbix has 3 main modes:

```shell
vbix -c # Create
vbix -m # Manage
vbix -i # Information
```

# Installation and Setup

I have previously used a full "installer" script, which did all of the setup, along with reinstall/uninstall modes, and generating certain dependancies. As features were added this script grew to exceed 800 lines of code. I want people to easily give vbix a try, and a large file of operations with the expectation that you blindly run them... can be a bit of a barrier to entry.

At its core, vbix just needs a few directories and a file for the port blocks. That is all.

Also, while it's possible to setup vbix for all users of a Linux system, for simplicity these instructions will set up vbix for a single user.

So, let's keep it simple:

### Create Directories

```shell
mkdir '~/vbix/conf'
mkdir '~/vbix/vbix_iso'
mkdir '~/vbix/vbix_img'
```

### Generate Port Blocks for NAT based VMs

Run this interactive script to generate the available port blocks for your VMs. It will generate a .csv file and .md5 checksum. This checksum is checked and re-calculated everytime vbix creates a new VM to ensure the file has not been malformed during an interrupted create operation.

```shell
bash vbix_ports.sh
```

### Set Permissions

```shell
chmod 770 '~/vbix/conf'
chmod 660 '~/vbix/conf/vbix_ports.csv'
chmod 660 '~/vbix/conf/vbix_ports.md5'

chmod 770 '~/vbix/vbix_iso'
chmod 770 '~/vbix/vbix_img'
```

### Setup the main vbix script

If you want, you can just run vbix.sh from your home directory via bash, using:

```shell
$ cd ~/
$ bash vbix.sh -h
```

Most likely you will want it on the path so you can just run "vbix -h". To do this, move vbix.sh to a folder in your home directory that is visible from the command line path, and rename it to "vbix".

```shell
mv '~/vbix.sh' '~/bin/vbix'
chmod +x '~/bin/vbix'
```

# Securely access your VM via RDP, to install your OS

### Remote Desktop Access

The Oracle Virtualbox Extensions Pack is required to access a VM via RDP (VRDE), and install a fresh operating system.

This is a proprietary non-open source blob of code.

For a while, the way around this was to use the VNC Ext Pack instead. However this has to be compiled into the application via a compile flag. This feature has come and gone over the years as a default option, and was present/missing depending on which Linux Distribution you used. Currently it is not being compiled with the build of Virtualbox provided by Oracle. Debian no longer includes Virtualbox in their repository and others like Arch's AUR repository may or may not provide build scripts with the VNC Ext Pack enabled by default.

As such vbix assumes you have to use VRDE to access the native virtualbox RDP. In my opinion, the entire point of having modular extension packs means that the VNC Ext Pack should be available as an alternative standalone pack, rather than a compile time feature. As such, if you truly want a Libre version of Virtualbox on your system with vbix, you have to compile virtualbox from scratch to get the VNC option.

1). Query your currently installed ext packs:

```shell
vboxmanage list extpacks
```

2.) Download Oracle Ext Pack via:

https://www.virtualbox.org/wiki/Downloads  
or  
https://download.virtualbox.org/virtualbox/

3.) Install Oracle Ext Pack:

```shell
vboxmanage extpack install <path_to_file>
```

How to Uninstall Oracle Ext Pack:

```shell
vboxmanage extpack uninstall "Oracle VM VirtualBox Extension Pack"
```

### Encrypting the Connection, and Connecting

SSH is relied on here for encryption.

Rather than publically exposing multiple RDP ports, leaving the potential for user error on TLS Certs, we just use SSH to create a secure tunnel for accessing RDP.

1.) Run the following command on your local machine:

```shell
$ ssh -p <host_ssh_port> -N -v -L <local_port>:<host_ip_address>:<vm_rdp_port> <host_user>@<host_ip_address>
```

2.) Connect to RDP via: `127.0.0.1:<local_port>`

3.) External RDP Authorization is turned on, so you will need to use a username/password from the parent Linux Host in your RDP Client order to authenticate and access the VM via RDP.

Note: On Linux I have had good success with Remmina and the FreeRDP plugin for an all in one RDP Client solution (protocols are installed in Remmina as plugins).

# Code

Here are a few notes about code structure:

### Parameter Prefixes (vars)

vbix is a rather large script. To ensure we know whats data is being passed and stored, we use certain prefixes on parameters.

config_ = configuration values  
select_ = data stored as a result of selecting an option from a question prompt (via read -p), usually from a numerical list of options  
manual_ = manually input text to a question prompt (via read -p)  
vbox_ = assigned data that virtualbox will eventually read as input in a command

### Function format

I write so much bash code for my other projects, I grew tired of trying to uniquely name vars within functions. Function arguments are setup as local vars with arg1=$1, arg2=$2, etc; and a simple comment for context. This isn't something I do in other languages, and I only do this sort of thing in my bash scripts. I consider it a quirk of my bash code, but I find it maintains consistancy with function format, lowers cognitive load when debugging, and makes writing functions faster.

```shell
function pad_stuff() {
	local arg1=$1 # string length
	local arg2=$2 # to pad
```

### Trigger Blocks

In a lot of my bash scripts, I wrap core functionality in "trigger block" as I call them.

```shell
if [ $trig01 == "YES" ]
then
```

If I set the following, the block of code won't run:

```shell
trig01="NO"
```

This is done for debugging and feature implementation. I need to be able to test/debug sections of the script. So blocks of code need to be turned on/off.

# Additional Info

### I already run virtualbox based vms, do I have to remove my VMs to use vbix?

If virtual machines already exist on the system in the default "Virtualbox VMs" folder, vbix can manage these vms as well. The only thing to take under consideration, is if you have pre-existing NAT based vms, they may have port conflicts with the new VMs created by vbix depending on the port range you allocate to vbix. You just have to make sure they are not in conflict.

vbix is afterall, just executing native virtualbox commands. So running `vbix -m`, and managing a previously created vm via vbix, will work just fine.

### Scope

vbix was designed to be very simple, solving for the bare minimum workflow in creating and managing vms. The command features for virtualbox are extensive, and vbix does not try to encapsulate the entire command api into its functions.

### Metacache files

These files are optionally generated during the VM creation process. It cache's ISO information for future VM creations. Data is exported in the following format:

```
iso_select=WIN7-X17-59465.iso
os_name=Windows 7 (64-bit)
os_type=Windows7_64
```

### Exporting a VM for use as a "ready made image"

First Create a VM, install an OS, and power down the machine.

Then export the VM using:

```shell
vboxmanage export <vm_name> --output '~/vbix/vbix_img/name_of_image.ovf'
```

### Non-interactive mode

vbix by default interacts with the user in the terminal via text prompts, with question based selectable options. This requires user interaction. But what if you wanted to use something like SALT/Chef/Puppet/Ansible to interact with vbix? This is where things can get pretty crazy. I remember initially testing this, and decided to kick off a batch of 8 virtual machine creation jobs from ready made images at the exact same time, powering them all up, and then powering them all down.

Examples:

```shell
# running a VM
vbix -m -n --run=<vm_name>

# creating a VM
vbix -c -n --name=<vm_name> --install=<file_name_only>'.iso' --ostype=<ostype> --cpu=2 --ram=2GB --hdsize=20GB --nic=nat --ports=auto22
```

NOTE: It must be stated that it has been quite a while since I have fully tested the code for non-interactive mode. There could be bugs? Create an issue if you run into anything. Thanks!

# Gotchas

Technology is always changing, so sometimes things break. Linux Mint 22 Wilma recently released. I was testing an install of Mint not realising the ISO I downloaded was "version 22", which had JUST been released within the hour of me kicking off an install in virtualbox. I was getting a black screen on RDP connect, and I could not for the life of me figure out why. I eventually figured out that it was a brand new release of MINT, and days later when proper release notes were posted for Mint 22, it highlights all types of Virtualbox caveates.

I say this merely to highlight "when its just not working", it probobly isn't the script, and most likely has to do with everything else going on between your client machine, virtualbox's version, how it was compiled, and the iso/img you are trying to run. Just be patient if you run into an issue, and take all the technology involved into consideration.
