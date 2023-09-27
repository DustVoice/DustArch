#import "dustypst/dustypst.typ": admindoc_project, note, important, tip, warning, caution, linkfn, filepath, terminal-root, terminal, cmd, pkg-aur, pkgtable, filesrc, codeblock, pkg

#show: admindoc_project.with(
  title: "DustArch",
  subtitle: "DustVoice's Arch Linux from scratch",
)

= Inside the `archiso`

This chapter is aimed at assisting with the general setup of a customized Arch Linux installation, using an official Arch Linux image (`archiso`).

#note[
  As Arch Linux is a rolling release GNU/Linux distribution, it is advised, to have a working internet connection, in order to get the latest package upgrades and to install additional software, as the `archiso` doesn't have all packages available from cache, especially the ones that need to be installed from the `AUR`.

  / AUR (Arch User Repository):
    A huge collection of packages contributed and maintained by the community, which in order to install you need to download and build.\
    Accessable and browsable under #linkfn("https://aur.archlinux.org/")[aur.archlinux.org].

  Furthermore, one should bear in mind that depending on the version, or rather modification date, of this guide, the exact steps taken may already be outdated.
  If you encounter any problems along the way, you will either have to resolve the issue yourself or utilize the great #linkfn("https://wiki.archlinux.org/")[ArchWiki], or the #linkfn("https://bbs.archlinux.org/")[Arch Linux forums].
]

To get some explanation on how this document is formatted, look into the @glossary

== Syncing up `pacman`


First of all, we need to sync up `pacman`'s package repository, in order to be able to install the latest, as well as new packages to the `archiso` and our new system.

#terminal-root("/")[`pacman -Sy`]

#warning[
  Using #cmd[`pacman -Sy`] should be sufficient, in order to be able to search for packages from within the `archiso`, without upgrading the system, but might break your system, if you use this command on an existing installation!
  
  #cmd[pacstrap] uses the latest packages anyways.
]
#caution[
  To be on the safe side, it is advised to always use #cmd[`pacman -Syu`]!
  
  Only on the `archiso` is there an exception to be made, as #cmd[`pacman -Syu`] will probably fail due to `RAM` limitations!
]

=== Official repositories

After doing that, we can now install any software from the official repositories by issuing

#terminal-root("/")[`pacman -S <package_name>`]

where you would replace `<package_name>` with the actual package name.

If you want to remove an installed package, use

#terminal-root("/")[`pacman -Rsu <package_name>`]

If you don't know the exact package name, or if you just want to search for a keyword, for example, `xfce`, to list all packages having something to do with `xfce`, use

#terminal-root("/")[`pacman -Ss <keyword>`]

If you really need to force remove a package, which you should use _with extreme caution_, you could use

#terminal-root("/")[`pacman -Rdd <package_name>`]

=== `AUR`

If you want to install a package from the #linkfn("https://aur.archlinux.org/")[AUR], I would advise proceeding in the following manner, in order to install the `AUR`-helper #pkg-aur("paru") or alternatively #pkg-aur("paru-bin").

#enum[
  Clone the package with `git`
  #terminal("~")[`git clone https://aur.archlinux.org/paru.git`]

   If you are on a slow PC or don't want to compile `paru` from scratch, you can also use the #linkfn("https://aur.archlinux.org/packages/paru-bin")[paru-bin].
][
  Switch to the package directory
][
  Execute #cmd[`makepkg`] with the appropriate argments
  #terminal("~/paru")[`makepkg -si`]
][
  Delete all files created, as `paru` will now be handling all the `AUR` stuff.

  #terminal("~/paru")[
    `cd ..`

    `rm -rf paru`
  ]
]

If you only install `AUR` packages the manual way, you might have to resolve some `AUR` dependencies manually, which can't be automatically resolved by `makepkg`'s `-s` option, which uses `pacman`.

In order to install a desired `AUR` package, you _must_ switch to your normal, non-`root` user, because `makepkg` doesn't run as `root`.

=== Software categories

In this guide, the software is categorized into three different categories

/ `console`: Intended to be used with either the native linux console or with a terminal emulator

/ `GUI`: Intended to be used within a graphical desktop environment

/ `hybrid`: To be used either within both a console and a graphical desktop environment (e.g. `networkmanager`), or there are packages available for both a console and a graphical desktop environment (e.g. `pulseaudio` with `pulsemixer` for `Console` and `pavucontrol` for `GUI`)

=== Software installation

In this guide, I'll be explicitly listing the packages installed in a specific section at the beginning of the individual sections.

This allows you to

- clearly see what packages get installed/need to be installed in a specific section

- install packages before you start with the section in order to minimize waiting time

The packages are always the recommended packages.

For further clarification for specific packages (e.g. `UEFI` specific packages), continue reading the section, as there is most certainly an explanation or follow-up section there.

Of course, as always, you can and *should* adapt everything according to your needs, as this guide is, again, _no tutorial, but a guide_.

== Formatting the drive

First, you probably want to get a list of all available drives, together with their corresponding device name, by issuing

#terminal-root("/")[`fdisk -l`]

The output of #cmd[`fdisk -l`] is dependent on your system configuration and many other factors, like the `BIOS` initialization order, etc.

#caution[
  Don't assume the same path of a device between reboots!

  Always double-check!

  There is nothing worse than formatting a drive you didn't mean to format!
]

=== The standard way

In my case, the partition I want to install the root file system on will be #filepath("/dev/mapper/DustPortable"), which is an unlocked `luks2` volume that will be located on #filepath("/dev/sda2"). For my `swap`, I will use a `swapfile`.

#note[
  A `swap` size twice the size of your RAM is recommended by a lot of people.

  To be exact, every distribution has different recommendations for `swap` sizes. Also `swap` size heavily depends on whether you want to be able to hibernate, etc.
]

==== In my opinion

You should make the `swap` size at least your RAM size and for RAM sizes over `4GB` with the intention to hibernate, at least one and a half times your RAM size.

If you haven't yet partitioned your disk, please refer to the #linkfn("https://wiki.archlinux.org/index.php/Partitioning")[general partitioning tutorial] in the ArchWiki.

=== Full system encryption


#note[
  This is only one way to do it (read: it is the way I have previously done it).
]

I'm using a `LUKS` setup, with `btrfs` and `luks2`.
For more information look into the #linkfn("https://wiki.archlinux.org/")[ArchWiki].

This setup has different partitions, used for the `EFI System Partition`, `root` partition, etc. compared to the ones used in the rest of the guide.
The only part of the guide, which currently uses the drives & partitions used in this section is @manual-secure-boot.

To start things, we first have to decide, which disk, or partition, is going to be `luks2` encrypted.

In my case, I'll be using my SSD in a USB-C enclosure to be able to take the system with me on the go.
For that, I will use a `GPT` partition scheme.
I will then create a `2 GiB` `EFI System partition` (I have multiple kernels installed at a time), in my case #filepath("/dev/sda1"), defined as an `EFI System partition` type in `gdisk`, as well as the main `luks2` volume, in my case #filepath("/dev/sda2"), defined as a `Linux filesystem` partition type in `gdisk`.

After partitioning our disk, we now have to set everything up.

==== `EFI System Partition`

#pkgtable(core: "dosfstools")

I won't set up my `EFI System Partition` with `cryptsetup`, as it makes no sense in my case.

Every `EFI` binary (or `STUB`) will have to be signed with my custom Secure Boot keys, as described in @manual-secure-boot, so tempering with the `EFI System Partition` poses no risk to my system.

Instead, I will simply format it with a `FAT32` filesystem

#terminal-root("/")[`mkfs.fat -F 32 -n EFI /dev/sda1`]

We will bother with mounting it later on.

When you _do_ want to encrypt your `EFI System Partition`, in conjunction with e.g. `grub`, please either use `LUKS 1`, or make sure to have the latest version of `grub` installed on your system, to make it work with `LUKS 2`!
I will use `limine` though, so for me, all of this isn't a consideration.

==== `LUKS`

#pkgtable(core: "cryptsetup")

First off we have to create the `LUKS` volume

#terminal-root("/")[`cryptsetup luksFormat --type luks2 /dev/sda2`]

In my case, I will convert the key slot to `pbkdf2`, as `luks2` defaults to `argon2id`, which doesn't play well with my portable setup, namely the differing RAM sizes.

#terminal-root("/")[`cryptsetup luksConvertKey --pbkdf pbkdf2 /dev/sda2`]

/ pbkdf: Password-Based Key Derivation Function

After that, we have to open the volume

#terminal-root("/")[`cryptsetup open /dev/sda2 DustPortable`]

The volume is now accessible under #filepath("/dev/mapper/DustPortable").

==== `btrfs`

#pkgtable(core: "btrfs-progs")

First off we need to create the filesystem

#terminal-root("/")[`mkfs.btrfs -L DustPortable /dev/mapper/DustPortable`]

After that, we mount the `btrfs` root under #filepath("/mnt/meta")

#terminal-root("/")[
  ```
  mkdir /mnt/meta
  
  mount /dev/mapper/DustPortable /mnt/meta
  ```
]

Now we create the desired filesystem layout.

We will create 5 top-level subvolumes that will be mounted at the appropriate places later on.


#terminal-root("/mnt/meta")[
  ```
  btrfs subvolume create @
  
  btrfs subvolume create @home
  
  btrfs subvolume create @snapshots
  
  btrfs subvolume create @var_log
  
  btrfs subvolume create @swapfile
  ```
]

== Preparing the `chroot` environment

As a first step, it might make sense to edit the #filepath("/etc/pacman.d/mirrorlist") to move the mirrors geographically closest to you to the top.

=== `pacstrap` in

Generally, we need to `pacstrap` the _minimum packages_ needed.
We will install all other packages later on.

#pkgtable(
  core: "base base-devel linux linux-firmware",
)

This is the actual command used in my case

#terminal-root("/")[`pacstrap /mnt/meta/@ base base-devel linux linux-firmware`]

=== Mounting party

Now we have to mount the subvolumes and boot partition we created earlier to the appropriate locations.

First off, we mount the #filepath("/") subvolume `@`

#terminal-root("/")[
  ```
  mkdir /mnt/DustPortable
  
  mount -o subvol=@ /dev/mapper/DustPortable /mnt/DustPortable
  ```
]

Now we can mount the #filepath("/home") subvolume `@home`

#terminal-root("/mnt/DustPortable")[`mount -o subvol=@home /dev/mapper/DustPortable home`]

The #filepath("/.snapshots") subvolume `@snapshots` closely follows

#terminal-root("/")[
  ```
  mkdir .snapshots
  
  mount -o subvol=@snapshots /dev/mapper/DustPortable .snapshots
  ```
]

After that we have to move the log dir #filepath("/var/log") to the appropriate subvolume `@var_log`

#terminal-root("/mnt/DustPortable")[
  ```
  mv var/log var/log_bak
  
  mount -o subvol=@var_log /dev/mapper/DustPortable var/log
  
  mkdir var/log
  
  mv var/log_bak/* var/log/
  
  rmdir var/log_bak
  ```
]

Finally, we can generate the `swapfile`

#terminal-root("/mnt/DustPortable")[
  ```
  mkdir swapfile
  
  mount -o subvol=@swapfile /dev/mapper/DustPortable swapfile
  
  btrfs filesystem mkswapfile --size 128G swapfile/swapfile
  
  swapon swapfile/swapfile
  ```
]

#important[
  I use my SSD inside a USB-C enclosure (although it is rated at 40Gbps it is *not* Thunderbolt 3!), which means that it _doesn't_ support `TRIM`.
  This is why I personally need to add `nodiscard` to every `mount` command option, which would look something along the lines of this

  #terminal-root("/")[
    `mount -o subvol=@,nodiscard /dev/mapper/DustPortable /mnt/DustPortable`
  ]
]

The only thing left to do now is mount the boot partition, namely my `EFI System Partition`

#terminal-root("/mnt/DustPortable")[
  ```
  mv boot boot_bak
  
  mkdir boot
  
  mount /dev/sda1 boot
  
  mv boot_bak/* boot/
  
  rmdir boot_bak
  ```
]

After that we can generate the #filepath("/etc/fstab") using `genfstab`

#terminal-root("/")[
  `genfstab -U /mnt/DustPortable >> /mnt/DustPortable/etc/fstab`
]

and you're ready to enter the `chroot` environment.

=== Outdated `archiso`

If you're using an older version of the `archiso`, you might want to replace the `mirrorlist` present on the `archiso` with the newest #linkfn("https://archlinux.org/mirrorlist/all")[online one]

#terminal-root("/")[
  `curl https://archlinux.org/mirrorlist/all > /etc/pacman.d/mirrorlist`
]

#pkgtable(extra: "reflector")

The best way to do this tho is using a package from the official repositories named `reflector`.
It comes with all sorts of options, for example sorting mirrors by speed, filtering by country, etc.

#terminal-root("/")[
  `reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist`
]

After that, you would need to reinstall the `pacman-mirror` package and
run

#terminal-root("/")[`pacman -Syyuu`]

for best results.

#caution[
  Be wary though as there could arise keyring issues etc.
  Normally the `pacstrap` command takes care of syncing everything etc.
]

=== Living behind a proxy

If you're sitting behind a proxy, you're generally in for an unpleasant time.
Generally, you need to set the `http_proxy`, `https_proxy`, `ftp_proxy` variables as well as their *upper case* counterparts.

#terminal-root("/")[
  ```
  export http_proxy="http://ldiproxy.lsjv.rlp.de:8080"
  
  export https_proxy=$http_proxy
  
  export ftp_proxy=$http_proxy
  
  export HTTP_PROXY=$http_proxy
  
  export HTTPS_PROXY=$http_proxy
  
  export FTP_PROXY=$http_proxy
  ```
]

If you can't `pacstrap` after that, you probably have the issue that the `systemd-timesyncd`, as well as the `pacman-init` service didn't execute correctly.

#terminal-root("/")[
  ```
  systemctl status systemd-timesyncd.service
  
  systemctl status pacman-init.service
  ```
]

To mitigate this, you need to initialize `pacman` yourself.

First off check whether the correct time is set.

#terminal-root("/")[`timedatectl`]

In my case the time zone was not correctly set, why my time was off by one hour, so I had to set it manually.

#terminal-root("/")[`timedatectl set-timezone Europe/Berlin`]

After that, we have to execute the `pacman-init` stuff manually

#terminal-root("/")[
  ```
  pacman-key --init
  
  pacman-key --populate
  ```
]

#note[
  You might also want to add the following lines to #filepath("/etc/sudoers"), in order to keep the proxy environment variables alive when executing a command through `sudo`

  #filesrc(part: true, "/etc/sudoers")[
    ```
    Defaults  env_keep += "http_proxy"
    
    Defaults  env_keep += "https_proxy"
    
    Defaults  env_keep += "ftp_proxy"
    
    Defaults  env_keep += "HTTP_PROXY"
    
    Defaults  env_keep += "HTTPS_PROXY"
    
    Defaults  env_keep += "FTP_PROXY"
    ```
  ]
]

= Entering the `chroot`

#pkgtable(extra: "arch-install-scripts")

#note[
  As we want to set up our new system, we need to have access to the different partitions, the internet, etc. which we wouldn't get by solely using `chroot`.

  That's why we are using `arch-chroot`, provided by the `arch-install-scripts` package, which is shipped with the `archiso`. This script takes care of all the aforementioned stuff, so we can set up our system properly.
]

#terminal-root("/")[`arch-chroot /mnt/DustPortable`]

Et Voila! You successfully `chroot`-ed inside your new system and you'll be greeted by a `bash` prompt, which is the default shell on fresh Arch Linux installations.

== Installing additional packages

#pkgtable(
  core: "amd-ucode base-devel btrfs-progs diffutils dmraid dnsmasq dosfstools efibootmgr emacs-nativecomp exfat-utils iputils linux-headers openssh sudo usbutils",
  extra: "efitools fish git intel-ucode neovim networkmanager networkmanager-openconnect networkmanager-openvpn nushell parted polkit rsync zsh",
  aur: "limine",
)

#note[
  There are many command line text editors available, like `nano`, `vi`, `vim`, `emacs`, etc.

  I'll be using `neovim` as my simple text editor, until a certain point, at which I'll replace it with my doom-`emacs` setup, though it shouldn't matter what editor you choose for the rest of the guide.
]

Make sure to enable the `NetworkManager.service` service, in order for the Internet connection to work correctly, upon booting into the fresh system later on.

#terminal-root("/")[`systemctl enable NetworkManager.service`]

With `polkit` installed, create a file to enable users of the `network` group to add new networks without the need for `sudo`.

#filesrc("/etc/polkit-1/rules.d/50-org.freedesktop.NetworkManager.rules")[
  ```
  polkit.addRule(function(action, subject) {
      if (action.id.indexOf(
        "org.freedesktop.NetworkManager."
      ) == 0 && subject.isInGroup("network")) {
          return polkit.Result.YES;
      }
  });
  ```
]

If you use `UEFI`, you'll also need the `efibootmgr`, in order to modify the `UEFI` entries.

=== Additional kernels

#pkgtable(
  core: "linux-lts linux-lts-headers linux-zen linux-zen-headers",
  extra: "linux-hardened linux-hardened-headers",
)

In addition to the standard `linux` kernel, there are a couple of different options out there.
Just to name a few, there are `linux-lts`, `linux-zen`, and `linux-hardened`.

You can simply install them and then add the corresponding `initramfs` and kernel image to your bootloader entries.

Make sure you have allocated enough space on your `EFI System Partition` though.

== Master of time

After that, you have to set your timezone and update the system clock.

Generally speaking, you can find all the different timezones under #filepath("/usr/share/zoneinfo").

In my case, my timezone file resides under #filepath("/usr/share/zoneinfo/Europe/Berlin").

To achieve the desired result, I will want to symlink this to the #filepath("/etc/localtime") and set the hardware clock.

#terminal-root("/")[
  ```
  ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  
  hwclock --systohc --utc
  ```
]

Now you can also enable time synchronization over the network

#terminal-root("/")[
  ```
  timedatectl set-timezone Europe/Berlin
  
  timedatectl set-ntp true
  ```
]

and check that everything is alright

#terminal-root("/")[`timedatectl status`]

== Master of locales

Now you have to generate your locale information.

For that you have to edit #filepath("/etc/locale.gen") and uncomment the locales
you want to enable.

I recommend always uncomment `en_US.UTF-8 UTF8`, even if you want to
use another language primarily.

In my case, I only uncommented the `en_US.UTF-8 UTF8` line

#filesrc(part: true, "/etc/locale.gen")[
  ```
  en_US.UTF-8 UTF8
  ```
]

After that, you still have to actually generate the locales by issuing

#terminal-root("/")[`locale-gen`]

and set the locale

#terminal-root("/")[
  `localectl set-locale LANG="en_US.UTF-8"`
]

After that, we're done with this part.

== Naming your machine

Now we can set the `hostname` for our new install and add `hosts` entries.

Apart from being mentioned in your command prompt, the `hostname` also serves the purpose of identifying or naming your machine locally, as well as in a networked scenario.
This will enable you to see your PC with the correct name in your router, etc.

=== `hostname`

To change the `hostname`, simply edit #filepath("/etc/hostname"), enter the desired name, then save and quit

#filesrc("/etc/hostname")[
  ```
  DustArch
  ```
]

=== `hosts`

Now we need to specify some `hosts` entries by editing #filepath("/etc/hosts")

#filesrc("/etc/hosts")[
  ```
  // # Static table lookup for hostnames.
  // # See hosts(5) for details.
  
  127.0.0.1   localhost           .
  ::1         localhost           .
  127.0.1.1   DustArch.localhost  DustArch
  ```
]

== User setup

Now you should probably change the default `root` password and create a new non-`root` user, as using your new system purely through the native `root` user is not recommended from a security standpoint.

=== Give `root` a password

To change the password for the current user (the `root` user) issue

#terminal-root("/")[`passwd`]

and choose a new password.

=== Create a personal user

#pkgtable(
  core: "sudo bash",
)

We are going to create a new user and set the password, groups, and shell for this user

#terminal-root("/")[
  ```
  useradd -m -p "" -G "adm,audio,disk,floppy,kvm,
  log,lp,network,rfkill,scanner,storage,
  users,optical,power,wheel" -s /bin/bash dustvoice
  passwd dustvoice
  ```
]

We must now allow the `wheel` group `sudo` access.

We edit the #filepath("/etc/sudoers") file and uncomment the `%wheel` line.

#filesrc(part: true, "/etc/sudoers")[
  ```
  %wheel ALL=(ALL) ALL
  ```
]

You could also add a new line below the `root` line

#filesrc(part: true, "/etc/sudoers")[
  ```
  root ALL=(ALL) ALL
  ```
]

with your new username

#filesrc(part: true, "/etc/sudoers")[
  ```
  dustvoice ALL=(ALL) ALL
  ```
]

to solely grant the _new_ user `sudo` privileges.

== Boot manager <boot-manager>

In this section, different boot managers/boot methods are explained.

=== `EFISTUB`

#pkgtable(core: "efibootmgr ")

You can directly boot the system, by making use of the `EFISTUB` contained in the kernel image. To utilize this, we can use `efibootmgr` to create an entry in the `UEFI`

#terminal-root("/")[
  ```
  efibootmgr
    --disk /dev/sda
    --part 2
    --create
    --label "Arch Linux"
    --loader /vmlinuz-linux
    --unicode
    'root=<root-partition-uuid> rw initrd=\initramfs-linux.img resume=UUID=<swap-partition-uuid>'
    --verbose
  ```
]

#warning[
  You need to replace the `<[...]-partition-uuid>` parts with your corresponding  values!
]

This only makes sense of course, if you're using `UEFI` instead of a legacy `BIOS`. In this case, it doesn't matter of course, if your machine _theoretically supports_ `UEFI`, but rather if it is the /enabled mode/!

=== `grub`

#pkgtable(
  core: "dosfstools efibootmgr grub",
  extra: "mtools os-prober",
)

Of course, you can also use a boot manager to boot the system, as the name implies.

If I can't use `EFISTUB`, e.g. either because the system has no `UEFI` support, or because I need another feature of a boot manager, I could use `grub`.

#tip[
  Currently, I mainly use `limine` as a boot manager *especially* on my portable setup, as `grub` is *such a huge pain in the butt!*

  `limine` is insanely easy to set up and configure, without all the `BIOS Boot partition` crap that I find myself mainly using this.
  Refer to @limine for further information.
]

#note[
  You'll probably only need the `efibootmgr` package, if you plan to utilize `UEFI`.
]

==== `grub` - `BIOS`

If you chose the `BIOS - MBR` variation, you'll have to _do nothing special_.

If you chose the `BIOS - GPT` variation, you'll have to _have a `+1M` boot partition_ created with the partition type set to `BIOS boot`.

In both cases, you'll have to _run the following comman_ now

#terminal-root("/")[`grub-install --target=i386-pc /dev/sdb`]

It should obvious that you would need to replace #filepath("/dev/sdb") with the disk you actually want to use. Note however that you have to specify a _disk_ and _not a partition_, so _no number_.

==== `grub` - `UEFI`

If you chose the `UEFI - GPT` variation, you'd have to _have the `EFI System Partition` mounted_ at #filepath("/boot") (where #filepath("/dev/sda2") is the partition holding said `EFI System Partition` in my particular setup)

Now _install `grub` to the `EFI System Partition`_

#terminal-root("/")[
  ```
  grub-install
    --target x86_64-efi
    --efi-directory /boot
    --bootloader-id=grub
    --recheck
  ```
]

If you've planned on dual booting Arch with Windows and therefore reused the `EFI System Partition` created by Windows, you might not be able to boot to `grub` just yet.

In this case, boot into Windows, open a `cmd` window as Administrator, and type in

#terminal-root(windows: true, "C:\\Windows\\System32")[`bcdedit /set {bootmgr} path \EFI\grub\grubx64.efi`]

To make sure that the path is correct, you can use

#terminal-root("/")[`ls /boot/EFI/grub`]

under Linux to make sure, that the `grubx64.efi` file is really there.

==== `grub` config

In all cases, you now have to create the main `grub.cfg` configuration file.

But before we actually generate it, we'll make some changes to the default `grub` settings, which the `grub.cfg` will be generated from.

===== Adjust the timeout

First of all I want my `grub` menu to wait indefinitely for my command to boot an OS.

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_TIMEOUT=-1
  ```
]

I decided on this because I'm dual booting with Windows and after Windows updates itself, I don't want to accidentally boot into my Arch Linux, just because I wasn't quick enough to select the Windows Boot Loader from the `grub` menu.

Of course, you can set this parameter to whatever you want.

Another way of achieving what I described, would be to make `grub` remember the last selection.

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_TIMEOUT=5
  GRUB_DEFAULT=saved
  GRUB_SAVEDEFAULT="true"
  ```
]

===== Enable the recovery

After that, I also want the recovery option to show up, which means that besides the standard and fallback images, also the recovery one would show up.

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_DISABLE_RECOVERY=false
  ```
]

===== NVIDIA fix

Now, as I'm using the binary NVIDIA driver for my graphics card, I also want to make sure, to revert `grub` back to text mode, after I select a boot entry, in order for the NVIDIA driver to work properly. You might not need this

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_GFXPAYLOAD_LINUX=text
  ```
]

===== Add power options

I also want to add two new menu entries, to enable me to shut down the PC, or reboot it, right from the `grub` menu.

```fish
menuentry '=> Shutdown' {
    halt
}

menuentry '=> Reboot' {
    reboot
}
```

===== Installing `memtest`

As I want all possible options to possibly troubleshoot my PC right there in my `grub` menu, without the need to boot into a live OS, I also want to have a memory tester there.

====== `BIOS`

#pkgtable(extra: "memtest86+")

For a `BIOS` setup, you'll simply need to install the `memtest86+` package, with no further configuration.

====== `UEFI`

#pkgtable(aur: "memtest86-efi")

For a `UEFI` setup, you'll first need to install the package and then tell #pkg-aur("memtest86-efi") how to install itself

#terminal-root("/")[`memtest86-efi -i`]

Now select option 3, to install it as a `grub2` menu item.

===== Enabling hibernation

We need to add the `resume` kernel parameter to #filepath("/etc/default/grub"), containing my `swap` partition `UUID`, in my case

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet resume=UUID=097c6f11-f246-40eb-a702-ba83c92654f2"
  ```
]

If you have to change anything, like the `swap` partition `UUID`, inside the `grub` configuration files, you'll always have to rerun #cmd[`grub-mkconfig`] as explained in @generate-grub-config.

===== Disabling `os-prober`

Sometimes it makes sense to disable the `os-prober` functionality of grub, even though `os-prober` is installed on the system (which auto enables it), for example when installing arch for portability purposes. We can disable the os-prober functionality in the `grub` default config file.

#filesrc(part: true, "/etc/default/grub")[
  ```
  GRUB_DISABLE_OS_PROBER=true
  ```
]

===== Generating the `grub` config <generate-grub-config>

Now we can finally generate our `grub.cfg`

#terminal-root("/")[`grub-mkconfig -o /boot/grub/grub.cfg`]

Now you're good to boot into your new system.

=== `limine` <limine>

#pkgtable(aur: "limine")

#tip[
  You will have to switch to your normal user to install the `AUR` package.

  If you're at it though, you could also already install `paru`, to make things easier.

  #pkgtable(
    extra: "asp bat devtools",
    aur: "paru-bin",
  )

  #terminal-root("/")[`su dustvoice`]
  #terminal("~")[
    ```
    git clone https://aur.archlinux.org/paru-bin.git
    
    makepkg -si
    
    rm -rf paru-bin
    ```
  ]
]

==== `Hybrid`

To be able to boot from a `BIOS`, as well as a `UEFI` system, simply follow both of these guides.

==== `BIOS`

For installing `limine` on a `BIOS` system, you first need to copy #filepath("/usr/share/limine/limine.sys") (which replaces the need for a boot partition, like `grub` uses it) to a #filepath("/") or #filepath("/boot") directory of any partition on the disk you want to try and boot from.

#terminal-root("/")[`cp /usr/share/limine/limine.sys /boot/`]

After that deploy `limine` using `limine-deploy`

#terminal-root("/")[`limine-deploy /dev/sda`]

#note[
  Don't specify any partition number when using the `limine-deploy`!
]

==== `UEFI`

Simply copy #filepath("/usr/share/limine/BOOTX64.EFI") to the appropriate location on your `EFI System Partition`

#terminal-root("/")[
  ```
  mkdir -p /boot/EFI/BOOT
  
  cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
  ```
]

#note[
  In case you're using the #link("*Secure Boot")[Secure Boot] method described in #link("*`PreLoader`"), you would need to name it `loader.efi`, as the `PreLoader` takes the place of the `BOOTX64.EFI` which gets auto started by most `UEFI` systems.
]

==== config

The only thing left to do is to create a `limine.cfg` file with all your desired boot entries in it.

#note[
  I usually have multiple kernels installed at a time, which is why my config file is so big.
  Note that I will install the kernels at a later time, but already specify them as boot entries.
  Therefore don't be surprised if those boot entries in turn won't work yet!
]

===== Kernel `cmdline`

First off we'll define a variable which we then use throughout our boot entries, in order to reduce complexity and redundancy and increase readability.

#note[
  You need to replace the `[...]` part with the appropriate values for your system.

  For `[1]` the command to get the "physical" offset of the `swapfile` on `btrfs` is

#terminal-root("/")[`btrfs inspect-internal map-swapfile -r swapfile/swapfile`]

  For `[2]`, getting the `UUID` of the `LUKS` volume is achieved by using `blkid`.
]

#filesrc(part: true, "/boot/limine.cfg")[
  ```
  ${root_device}=root=/dev/mapper/DustPortable rw rootflags=subvol=@ resume=/dev/mapper/DustPortable resume_offset=[1] cryptdevice=UUID=[2]:DustPortable
  ```
]

===== `limine` options

Next we configure some options for `limine`

#filesrc(part: true, "/boot/limine.cfg")[
  ```
  TIMEOUT=no
  INTERFACE_BRANDING=DustPortable
  ```
]

===== Boot entries

Finally, we can specify our boot entries

#filesrc(part: true, "/boot/limine.cfg")[
  ```
  :Arch Linux
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux.img
  
  :Arch Linux (Zen)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-zen
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-zen.img
  
  :Arch Linux (LTS)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-lts
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-lts.img
  
  :Arch Linux (Hardened)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-hardened
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-hardened.img
  
  :Arch Linux (fallback initramfs)
  
  ::Arch Linux
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-fallback.img
  
  ::Arch Linux (Zen)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-zen
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-zen-fallback.img
  
  ::Arch Linux (LTS)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-lts
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-lts-fallback.img
  
  ::Arch Linux (Hardened)
  
  PROTOCOL=linux
  KERNEL_PATH=boot:///vmlinuz-linux-hardened
  CMDLINE=${root_device}
  MODULE_PATH=boot:///intel-ucode.img
  MODULE_PATH=boot:///amd-ucode.img
  MODULE_PATH=boot:///initramfs-linux-hardened-fallback.img
  ```
]

== Configure the `initramfs`

We'll add some custom entries to the #filepath("/etc/mkinitcpio.conf").

#important[
  It is crucial that after you're finished with editing the file, you run

#terminal-root("/")[`mkinitcpio -P`]

  to regenerate the `initramfs`!
]

=== `BINARIES`

First off, we have some binaries to be present in the image, so that if we drop into a recovery shell, we can use them.

#filesrc(part: true, "/etc/mkinitcpio.conf")[
  ```
  BINARIES=(btrfs nvim zsh fish)
  ```
]

=== Hibernation

In order to use the hibernation feature, you should make sure that your `swap` partition/file is at least the size of your RAM.

If you use a `busybox` based `ramdisk`, you need to add the `resume` hook to #filepath("/etc/mkinitcpio.conf"), before `fsck` and definitely after `block`

#note[
  When using `EFISTUB` without `sbupdate`, your motherboard has to support kernel parameters for boot entries.
  If your motherboard doesn't support this, you would need to use some other kind of boot manager (see @boot-manager).
]

=== `HOOKS`

Now we will specify every hook we need.
Mention-worthy additions to the default list are the hooks `colors`, `encrypt`, `btrfs`, and `resume`.

#filesrc(part: true, "/etc/mkinitcpio.conf")[
  ```
  HOOKS=(base udev colors block keyboard keymap consolefont autodetect kms modconf encrypt btrfs resume filesystems fsck)
  ```
]

=== `colors`

#pkgtable(
  extra: "terminus-font",
  aur: "mkinitcpio-colors-git",
)

By creating a file #filepath("/etc/vconsole.conf") we can specify a custom font and color scheme to use

#filesrc("/etc/vconsole.conf")[
  ```
  KEYMAP=us
  FONT=ter-116n
  COLOR_0=282a36
  COLOR_1=ff5555
  COLOR_2=50fa7b
  COLOR_3=f1fa8c
  COLOR_4=6272a4
  COLOR_5=bd93f9
  COLOR_6=8be9fd
  COLOR_7=d8d8d2
  COLOR_8=44475a
  COLOR_9=ff8585
  COLOR_10=80faab
  COLOR_11=f1fabc
  COLOR_12=92a2d4
  COLOR_13=ff79c6
  COLOR_14=bbe9fd
  COLOR_15=f8f8f2
  ```
]

== Switch to a `systemd` based `ramdisk`

#caution[
  I think it is worth noting that lately, I didn't use a `systemd` based `ramdisk` on my portable setup anymore, as I encountered some issues.

  The underlying issue apparently was having the `block` and `keyboard` hooks located after the `autodetect` hook.
  Reversing this so that `block` and `keyboard` precedes `autodetect` seems to fix the issue.
  In any case, the `fallback initramfs` should always work.

  It is worth noting though, that with the `busybox` based one, you lose the ability to unlock multiple `LUKS` encrypted partitions/devices at once if they share the same password.
  In that case, you must use the #filepath("/etc/crypttab").
]

There is nothing particularly better about using a `systemd` based `ramdisk` instead of a `busybox` one; it's just that I prefer it.

Some advantages, at least in my opinion, that the `systemd` based `ramdisk` has, are the included `resume` hook, as well as password caching, when decrypting encrypted volumes, which means that because I use the same `LUKS` password for both my data storage `HDD`, as well as my `cryptroot`, I only have to input the password once for my `cryptroot` and my data storage `HDD` will get decrypted too, without the need to create #filepath("/etc/crypttab") entries, etc.

To switch to a `systemd` based `ramdisk`, you will normally need to substitute the `busybox` specific hooks for `systemd` ones.
You will also need to use `systemd` hooks from now on, for example, `sd-encrypt` instead of `encrypt`.

- `base`

  In my case, I left the `base` hook untouched to get a `busybox` recovery shell, if something goes wrong, although you wouldn't technically need it when using `systemd`.

  Don't remove this, when using `busybox`, unless you absolutely know what you're doing.

- `udev`

  Replace this with `systemd` to switch from `busybox` to `systemd`.

- `keymap` and/or `consolefont`

  If you didn't use one of these two, or one, it needs to be replaced with `sd-vconsole`.
  Everything else stays the same with these.

- `encrypt`

  It isn't used in the default #filepath("/etc/mkinitcpio.conf"), but it could be important later on, for example when using.
  You need to substitute this with `sd-encrypt`.

- `lvm2`

  Same thing as with `encrypt` and needs to be substituted with `sd-lvm2`.

You can find all purposes of the individual hooks, as well as the `busybox` / `systemd` equivalent of each one, in the #linkfn("https://wiki.archlinux.org/title/Mkinitcpio#Common_hooks")[ArchWiki].

== Secure Boot

=== `PreLoader`

#pkgtable(aur: "preloader-signed")

This way of handling secure boot aims at just making everything work!
It is not how Secure Boot was intended to be used, and you might as well disable it.

If you need Secure Boot to be enabled, e.g. for Windows, but you couldn't care less for the security it could bring to your device, or if you want to use this installation on multiple systems, where Secure Boot could be enabled, use this method.

If you want to actually make use of the Secure Boot feature, read @manual-secure-boot.

I know I told you you're ready to boot into your new system.
That is only correct if you're _not_ using Secure Boot.
You can either disable Secure Boot in your firmware settings or use `PreLoader` as a pre-bootloader.

If you decide to use Secure Boot, you must first install the package.
Now we need to copy the `PreLoader` and the `HashTool`, which gets launched if the hash of the binary that is to be loaded (`loader.efi`) is not registered in the firmware yet, to our `EFI System Partition`

#terminal-root("/")[
  ```
  cp /usr/share/preloader-signed/PreLoader.efi /boot/EFI/BOOT/BOOTX64.EFI
  
  cp /usr/share/preloader-signed/HashTool.efi /boot/EFI/BOOT/
  ```
]

#note[
  If you have to use `bcdedit` from within Windows, as explained in the section #link("*`grub` - `UEFI`"), you must adapt the command accordingly.

  #terminal-root("/")[
    ```
    cp /usr/share/preloader-signed/PreLoader.efi /boot/EFI/BOOT/PreLoader.efi
    
    cp /usr/share/preloader-signed/HashTool.efi /boot/EFI/BOOT/
    ```
  ]

  and under Windows

  #terminal-root(windows: true, "C:\\Windows\\System32")[`bcdedit /set {bootmgr} path \EFI\BOOT\PreLoader.efi`]
  ]

You will be greeted by `HashTool` whenever you update your bootloader or kernel.

Just choose "Enroll Hash", choose the appropriate `loader.efi`, and enroll the kernel (`vmlinuz-linux`).

Reboot, and your system should fire up just fine.

=== The manual way <manual-secure-boot>

As this is a very tedious and time-consuming process, it only makes sense when also utilizing some disk encryption, which is why I would advise you to read first.

==== File formats

In the following subsections, we will deal with different file formats.

/ `.key`:
  `PEM` format private keys for `EFI` binary and `EFI` signature list signing.

/ `.crt`:
  `PEM` format certificates for `sbsign`.

/ `.cer`:
  `DER` format certificates for firmware.

/ `.esl`:
  Certificates in `EFI` Signature List for `KeyTool` and/or firmware.

/ `.auth`:
  Certificates in `EFI` Signature List with authentication header (i.e., a signed certificate update file) for `KeyTool` and/or firmware.

==== Create the keys

First off, we have to generate our Secure Boot keys.

These will be used to sign any binary executed by the firmware.

===== `GUID`

First, let's create a `GUID` for the following commands.

#terminal("~/sb")[`uuidgen --random > GUID.txt`]

===== `PK`

We can now generate our `PK` (Platform Key)

#terminal("~/sb")[
  ```
  openssl req
    -newkey rsa:4096
    -nodes
    -keyout PK.key
    -new
    -x509
    -sha256
    -subj "/CN=Platform Key for DustArch/"
    -out PK.crt
  
  openssl x509
    -outform DER
    -in PK.crt
    -out PK.cer
  
  cert-to-efi-sig-list
    -g "$(< GUID.txt)"
    PK.crt PK.esl
  
  sign-efi-sig-list
    -g "$(< GUID.txt)"
    -k PK.key
    -c PK.crt
    PK PK.esl PK.auth
  ```
]

To allow deletion of the `PK` for different firmwares that don't provide this functionality out of the box, we have to sign an empty file.

#terminal("~/sb")[
  ```
  sign-efi-sig-list
    -g "$(< GUID.txt)"
    -k PK.key
    -c PK.crt
    PK /dev/null rm_PK.auth
  ```
]

===== `KEK`

We proceed similarly with the `KEK` (Key Exchange Key)

#terminal("~/sb")[
  ```
  openssl req
    -newkey rsa:4096
    -nodes
    -keyout KEK.key
    -new
    -x509
    -sha256
    -subj "/CN=Key Exchange Key for DustArch/"
    -out KEK.crt
    
  openssl x509
    -outform DER
    -in KEK.crt
    -out KEK.cer

  cert-to-efi-sig-list
    -g "$(< GUID.txt)"
    KEK.crt KEK.esl
    
  sign-efi-sig-list
    -g "$(< GUID.txt)"
    -k PK.key
    -c PK.crt
    KEK KEK.esl KEK.auth
  ```
]

===== `DB`

And finally, the `DB` (Signature Database) key.

#terminal("~/sb")[
  ```
  openssl req
    -newkey rsa:4096
    -nodes
    -keyout db.key
    -new
    -x509
    -sha256
    -subj "/CN=Signature Database key for DustArch"
    -out db.crt
  
  openssl x509
    -outform DER
    -in db.crt
    -out db.cer
  
  cert-to-efi-sig-list
    -g "$(< GUID.txt)"
    db.crt db.esl
  
  sign-efi-sig-list
    -g "$(< GUID.txt)"
    -k KEK.key
    -c KEK.crt
    db db.esl db.auth
  ```
]

==== Windows stuff

As your plan is to be able to control which things do boot on your system and which don't, you're going through all this hassle to create and enroll custom keys, so only `EFI` binaries signed with said keys can be executed.

But what if you have a Windows dual boot setup?

Well, the procedure is actually pretty straightforward.
You grab the #linkfn("https://www.microsoft.com/pkiops/certs/MicWinProPCA2011_2011-10-19.crt")[Microsoft's certificates], convert them into a usable format, sign them, and enroll them.
No need to sign the Windows boot loader.

#terminal("~/sb")[
  ```
  openssl x509
    -inform DER
    -outform PEM
    -in MicWinCert.crt
    -out MicWinCert.pem
  
  cert-to-efi-sig-list
    -g 77fa9abd-0359-4d32-bd60-28f4e78f784b
    MicWinCert.pem MS_db.esl
    
  sign-efi-sig-list
    -a
    -g 77fa9abd-0359-4d32-bd60-28f4e78f784b
    -k KEK.key
    -c KEK.crt
    db MS_db.esl add_MS_db.auth
  ```
]

==== Move the kernel & keys

To ensure a smooth operation with actual security, we need to move some stuff around.

===== Kernel, `initramfs`, microcode

`pacman` will put its unsigned and unencrypted kernel, `initramfs` and microcode images into #filepath("/boot"), which is why it is no longer a good idea to leave your `EFI System Partition` mounted there.
Instead, we will create a new mount point under #filepath("/efi") and modify our `fstab` accordingly.

===== Keys

As you probably want to automate signing sooner or later and only use the ultimately necessary keys for this process and store the other more critical keys somewhere safer and more secure than your `root` home directory, we will move the necessary ones.

I like creating a #filepath("/etc/efi-keys") directory, `chmod`ded to `700`, and placing my `db.crt` and `db.key` there. All the keys will get packed into a `tar` archive, encrypted with a robust symmetric passphrase, and stored somewhere secure and safe.

==== Signing

Signing is the process of signing your `EFI` binaries for them to be allowed to be executed by the motherboard firmware. At the end of the day, that's why you're doing all this, to prevent an attack by launching unknown code.

===== Manual signing

Of course, you can sign images yourself manually. In my case, I used this to sign the boot loader, kernel, and `initramfs` of my USB installation of Arch Linux.

As always, manual signing also comes with its caveats!

If I update my kernel, boot loader, or create an updated `initramfs` on my Arch Linux USB installation, I must sign those files again to boot it on my PC.

Of course, you can always script and automate stuff, but if you want something easier for day-to-day use, I recommend trying out `sbupdate`, which I will explain in the next paragraph @sbupdate.

For example, if I want to sign the kernel image of my USB installation, where I mounted the boot partition to #filepath("/mnt/DustPortable/boot"), I must do the following.

#terminal-root("~/sb")[
  ```
  sbsign
    --key /etc/efi-keys/db.key
    --cert /etc/efi-keys/db.crt
    --output /mnt/DustPortable/boot/vmlinuz-linux
    /mnt/DustPortable/boot/vmlinuz-linux
  ```
]

===== `sbupdate` <sbupdate>

#pkgtable(aur: "sbupdate-git")

Of course, if you're using Secure Boot productively, you would want something more practical than manual signing, especially since you need to sign

- the boot loader

- the kernel image

- the `initramfs`

Fortunately, an easy and uncomplicated tool does everything for you: `sbupdate`.

It not only signs everything and also foreign `EFI` binaries, if specified, but also combines your kernel and `initramfs` into a single executable `EFI` binary, so you don't even need a boot loader if your motherboard implementation supports booting those.

After installing `sbupdate`, we can edit the #filepath("/etc/sbupdate.conf") file to set everything up.

Everything in this config should be self-explanatory.

You will probably need to

- set `ESP_DIR` to #filepath("/efi")

- add any other `EFI` binary you want to have signed to `EXTRA_SIGN`

- add your kernel parameters, for example

  - `rd.luks.name`

  - `root`

  - `rw`

  - `resume`

  - etc.

  to `CMDLINE_DEFAULT`

After you've successfully configured `sbupdate`, you can run it as root, to create all the signed files.

`sbupdate` will be executed upon kernel updates by `pacman`, but not if you change your `initramfs` with something like `mkinitcpio`.
In that case, you will have to run `sbupdate` manually.

==== Add `EFI` entries

#pkgtable(core: "efibootmgr")

Now the only thing left to do, if you want to stay boot loader free, is to add the signed images to your `NVRAM` boot list.
You can do this with `efibootmgr`.

#terminal-root("~/sb")[
  ```
  efibootmgr
    -c -d /dev/sda -p 1
    -L "Arch Linux fallback"
    -l "EFI\\Arch\\linux-fallback-signed.efi"
  
  efibootmgr
    -c -d /dev/sda -p 1
    -L "Arch Linux"
    -l "EFI\\Arch\\linux-signed.efi"
  ```
]

Of course, you can extend this list with whichever entries you need.

==== Enrolling everything

First off, copy all `.cer`, `.esl`, and `.auth` files to a `FAT` formatted filesystem.
I'm using my `EFI System Partition` for this.

After that reboot into the firmware setup of your motherboard, clear the existing Platform Key, to set the firmware into "Setup Mode" and enroll the `db`, `KEK`, and `PK` certificates in sequence.

Enroll the Platform Key last, as it sets most firmware's Secure Boot sections back into "User mode", exiting "Setup Mode".

= Inside the `DustArch`

This section helps at setting up the customized system from within an installed system.

This section mainly provides aid with the basic setup tasks, like networking, dotfiles, etc.

Not everything in this section is mandatory.

This section is rather a guideline because it is easy to forget some steps needed (for example `jack` for audio production), which only become apparent when they're needed or stuff fails.

It is furthermore the responsibility of the reader to decide which steps to skip and which need further research.
As I mentioned, this is only a guide and not the answer to everything.
So reader discretion is advised!

== Someone there?

First, we have to check if the network interfaces are set up properly.

To view the network interfaces with all their properties, we can issue

#terminal("~")[`ip link`]

To make sure that you have a working _Internet_ connection, issue

#terminal("~")[`ping archlinux.org`]

Everything should run smoothly if you have a wired connection.

If there is no connection and you're indeed using a wired connection,
try restarting the `NetworkManager` service

#terminal-root("~")[`systemctl restart NetworkManager.service`]

and then try #cmd[`ping`]-ing again.

=== Wi-Fi


If you're trying to utilize a Wi-Fi connection, use `nmcli`, the NetworkManager's command line tool, or `nmtui`, the NetworkManager terminal user interface, to connect to a Wi-Fi network.

I never got `nmtui` to behave like I wanted it to, in my particular case at least, which is the reason why I use `nmcli` or the GUI tools.

First make sure, the scanning of nearby Wi-Fi networks is enabled for your Wi-Fi device

#terminal("~")[`nmcli radio`]

and if not, enable it

#terminal("~")[`nmcli radio wifi on`]

Now make sure your Wi-Fi interface appears under

#terminal("~")[`nmcli device`]

Rescan for available networks

#terminal("~")[`nmcli device wifi rescan`]

and list all found networks

#terminal("~")[`nmcli device wifi list`]

After that connect to the network

#terminal("~")[`nmcli device wifi connect --ask`]

Now try #cmd[`ping`]-ing again.

== Update and upgrade

After making sure that you have a working Internet connection, you can then proceed to update and upgrade all installed packages by issuing

#terminal-root("~")[`pacman -Syu`]

== Enabling the `multilib` repository

In order to make 32-bit packages available to `pacman`, we'll need to enable the `multilib` repository in #filepath("/etc/pacman.conf") first.
Simply uncomment

#filesrc("/etc/pacman.conf")[
  ```
  [multilib]
  Include = /etc/pacman.d/mirrorlist
  ```
]

and update `pacman`'s package repositories afterward

#terminal-root("~")[`pacman -Syu`]

== `nu` for president

Of course, you can use any shell you want. In my case, I'll be using the
`nushell`.

I am using `nushell` because of its nice functionality and because I'm a sucker for `rust` software.

If you remember correctly, we set the login shell to `bash` when creating the `dustvoice` user, so you might wonder why we didn't directly set it to `nu`.
Well `nushell` isn't completely `POSIX` compliant, and neither does it want to be.
Therefore running `nu` as a login shell might not be the absolute best experience you ever had.

Instead, we populate our `.bashrc` with some scripting that will let `nu` take over any _interactive_ shell, while scripts, etc. that expect a `POSIX` compliant shell can have their way.

#note[
  You can replicate the following instructions directly for the `root` user, to get the same kind of experience there
]

#filesrc("~/.bashrc")[
  ```
  if [[ $- == *i* && $(ps --no-header --pid $PPID --format comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
  then
    exec fish
  fi
  ```
]

Don't worry about the looks, by the way, we're gonna change all that in just a second.

== `git`

#pkgtable(extra: "git")

Install the package and you're good to go for now, as we'll care about the `.gitconfig` in just a second.

== Security is important

#pkgtable(core: "gnupg")

If you've followed the tutorial using a recent version of the archiso, you'll probably already have the most recent version of `gnupg` installed by default.

=== Smartcard shenanigans

#pkgtable(
  extra: "ccid libusb-compat opensc pcsclite usbip",
)

After that, you'll still have to set up `gnupg` correctly.
In my case I have my private keys stored on a smartcard.

To use it, I'll have to install the listed packages and then enable and start the `pcscd.service` service

#terminal-root("~")[
  ```
  systemctl enable pcscd.service
  
  systemctl start pcscd.service
  ```
]

After that, you should be able to see your smartcard being detected

#terminal("~")[`gpg --card-status`]

If your smartcard still isn't detected, try logging off completely or even restarting, as that sometimes is the solution to the problem.

== Additional required tools

#pkgtable(
  core: "make openssh",
  extra: "atuin bat clang cmake exa jdk-openjdk pass python python-pynvim starship zoxide",
)

To minimize the effort required by the following steps, we'll install most of the required packages beforehand

This will ensure, we proceed through the following section without the need for interruption because a package needs to be installed so that the following content can be condensed to the relevant information.

== Setting up a `home` environment <home_setup>

In this step we're going to set up a home environment for both the `root` and my personal `dustvoice` user.

In my case, these 2 home environments are mostly equivalent, which is why I'll execute the following commands as the `dustvoice` user first and then switch to the `root` user and repeat the same commands.

I decided on this, as I want to edit files with elevated permissions and still have the same editor style and functions/plugins.

Note that this comes with some drawbacks.
For example, if I change a configuration for my `dustvoice` user, I would have to update it for the `root` user too regularly.

Also, I have to register my smart card for the root user.
This in turn is problematic, because the `gpg-agent` used for `ssh` authentication, doesn't behave well when used within a #cmd[`su`] or #cmd[`sudo -i`] session.
So in order to update `root`'s config files I would either need to symlink everything, which I won't do, or I'll need to log in as the `root` user now and then, to update everything.

In my case, I want to access all my `git` repositories with my `gpg` key on my smartcard.
For that, I have to configure the `gpg-agent` with some configuration files that reside in a `git` repository.
This means I will have to get along with using the `https` URL of the repository first and later changing the URL either in the corresponding `.git/config` file or by issuing the appropriate command.

=== Use `dotfiles` for a base config

To provide myself with a base configuration, which I can then extend, I maintain a `dotfiles` repository, which contains all kinds of configurations.

The special thing about this `dotfiles` repository is that it _is_ my home folder.
By using a curated `.gitignore` file, I'm able only to include the configuration files I want to keep between installs into the repository and ignore everything else.

To achieve this very specific setup, I have to turn my home directory into said `dotfiles` repository first

#terminal("~")[
  ```
  git init
  
  git remote add origin https://gitlab.dustvoice.de/DustVoice/dotfiles.git
  
  git fetch
  
  git reset origin/main --hard
  
  git branch --set-upstream-to=origin/main main
  ```
]

#important[
  This has lead to some problems in the past.
  Generally I would try and use the new #cmd[`git switch`] command like so:

  #terminal("~")[
    ```
    git init
  
    git remote add origin https://gitlab.dustvoice.de/DustVoice/dotfiles.git
  
    git fetch
  
    git switch -C main origin/main
    ```
  ]
]

Now I can issue any `git` command in my `$HOME` directory because it now is a `git` repository.

=== Set up `gpg`

As I wanted to keep my `dotfiles` repository as modular as possible, I utilized `git`'s `submodule` feature.
Furthermore, I want to use my `nvim` repository, which contains all my configurations and plugins for `neovim`, on Windows, but without all the Linux-specific configuration files.
I also use the `Pass` repository on my Android phone and Windows PC, where I only need this repository without the other Linux configuration files.

Before we are able to update the `submodule`s (`nvim` config files and `pass`) though, we will have to set up our `gpg` key as an `ssh` key, as I use it to authenticate

#terminal("~")[
  ```
  chmod 700 .gnupg
  
  gpg --card-status
  
  gpg --card-edit
  ```
]

#terminal("~")[
  ```
  fetch
  
  q
  ```
]

#terminal("~")[`gpg-connect-agent updatestartuptty /bye`]

You would have to adapt the `keygrip` present in the #filepath("~/.gnupg/sshcontrol") file to your specific `keygrip`, retrieved with #cmd[`gpg -K --with-keygrip`].

#important[
  If you're inside a VM, you of course need to pass the smartcard somehow to said VM.

  #pkgtable(extra: "usbip")

  If you're inside a `Hyper-V` VM, you need to utilize `usbip`.
  If you're using `fish`, there's a script under #filepath("~/.config/fish/usbip-man.fish")
]

Now, as mentioned before, I'll switch to using `ssh` for authentication, rather than `https`

#terminal("~")[`git remote set-url origin gitlab@gitlab.dustvoice.de:DustVoice/dotfiles.git`]

The best method to make `fish` recognize all the configuration changes, as well as the `gpg-agent` behave properly, is to re-login.
We'll do just that

#terminal("~")[`exit`]

It is very important to note, that I mean _a real re-login_.

That means that if you've used `ssh` to log into your machine, it probably won't be sufficient to login into a new `ssh` session.
You may need to restart the machine entirely.

=== Finalize the `dotfiles`

Now log back in and continue

#terminal("~")[`git submodule update --recursive --init`]

==== Setup `nvim`

If you plan on utilizing `nvim` with my config, you need to set up things first

#terminal("~/.config/nvim")[
  ```
  echo 'let g:platform = "linux"' >> platform.vim
  
  echo 'let g:use_autocomplete = 3' >> custom.vim
  
  echo 'let g:use_clang_format = 1' >> custom.vim
  
  echo 'let g:use_font = 0' >> custom.vim
  
  nvim --headless +PlugInstall +qa
  ```
]
#terminal("~/.config/nvim/plugged/YouCompleteMe")[`python3 install.py --clang-completer --java-completer`]

=== `gpg-agent` forwarding

Now there is only one thing left to do, in order to make the `gpg` setup complete: `gpg-agent` forwarding over `ssh`. This is very important for me, as I want to use my smartcard on my development server too, which requires me, to forward/tunnel my `gpg-agent` to my remote machine.

First of all, I want to set up a config file for `ssh`, as I don't want to pass all parameters manually to ssh every time.

```fish
Host <connection name>
    HostName <remote address>
    ForwardAgent yes
    ForwardX11 yes
    RemoteForward <remote agent-socket> <local agent-extra-socket>
    RemoteForward <remote agent-ssh-socket> <local agent-ssh-socket>
```

You would of course, need to adapt the content in between the `<` and `>` brackets.

To get the paths needed as parameters for `RemoteForward`, issue

#terminal("~")[`gpgconf --list-dirs`]

An example for a valid #filepath("~/.ssh/config") would be

```fish
Host archserver
    HostName pc.dustvoice.de
    ForwardAgent yes
    ForwardX11 yes
    RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
    RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh /run/user/1000/gnupg/S.gpg-agent.ssh
```

Now you'll still need to enable some settings on the remote machines.

```fish
StreamLocalBindUnlink yes
AllowAgentForwarding yes
X11Forwarding yes
```

Now just restart your remote machines and you're ready to go.

If you use `alacritty`, to connect to your remote machine over `ssh`, you will need to install the `alacritty` package on the remote machine too, as `alacritty` uses its own `$TERM`.

Another option would be changing that variable for the `ssh` command

#terminal("~")[`TERM=xterm-256colors ssh remote-machine`]

=== Back to your `root`'s

As mentioned before, you would now switch to the `root` user, either by logging in as `root`, or by using

#terminal-root("~")[`-iu root`]

Now go back to @home_setup to repeat all commands for the `root` user.

A native login would be better compared to #cmd[`sudo -iu root`], as there could be some complications, like already running `gpg-agent` instances, etc., which you would need to manually resolve when using #cmd[`sudo -iu root`].

== Audio

Well, why wouldn't you want audio ...

=== `alsa`

#pkgtable(extra: "alsa-utils")

#note[
  You're probably better off using #link("*`pulseaudio`")[`pulseaudio`], #link("*`jack`")[`jack`] and/or #link("*`pipewire`")[`pipewire`].
]

Now choose the sound card you want to use

#terminal("~")[`cat /proc/asound/cards`]

and then create #filepath("/etc/asound.conf")

```fish
defaults.pcm.card 2
defaults.ctl.card 2
```

It should be clear, that you would have to switch out `2` with the number corresponding to the sound card you want to use.

=== `pulseaudio`

#pkgtable(
  extra: "pavucontrol pulseaudio pulsemixer",
)

Some applications require `pulseaudio`, or work better with it, for example, `discord`, so it might make sense to use `pulseaudio` (although #link("*`pipewire`")[`pipewire`] could replace it).

For enabling real-time priority for `pulseaudio` on Arch Linux, please make sure your user is part of the `audio` group and edit the file #filepath("/etc/pulse/daemon.conf"), so that you uncomment the lines

```fish
high-priority = yes
nice-level = -11

realtime-scheduling = yes
realtime-priority = 5
```

If your system can handle the load, you can also increase the remixing quality, by changing the `resample-method`

```fish
resample-method = speex-float-10
```

Of course, a restart of the `pulseaudio` daemon is necessary to reflect the changes you just made

#terminal("~")[
  ```
  pulseaudio --kill
  
  pulseaudio --start
  ```
]

=== `jack`

#pkgtable(
  extra: "cadence jack2 pulseaudio-jack",
)

If you either want to manually control audio routing or if you use some kind of audio application like `ardour`, you'll probably want to use `jack` and then `cadence` as a GUI to control it, as it has native support for bridging `pulseaudio` to `jack`.

=== `pipewire`

#pkgtable(
  extra: "pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse qpwgraph wireplumber",
)

#tip[
  If you don't want to have conflicts, you need to stop `pulseaudio.service` and start `pipewire-pulse.service`

  #terminal-root("/")[
    ```
    systemctl stop pulseaudio.service
    
    systemctl start pipewire-pulse.service
    ```
  ]

  You can check if `pipewire-pulse` is working correctly with
  
  #terminal("~")[`pactl info`]
]

=== Audio handling

#pkgtable(
  extra: "libao libid3tag libmad libpulse opus sox twolame wavpack",
)

To also play audio, we need to install the mentioned packages and then do

#terminal("~")[
  ```
  play audio.wav
  
  play audio.mp3
  ```
]

to play audio.

== Bluetooth

#pkgtable(
  extra: "blueman bluez bluez-utils pulseaudio-bluetooth",
)

To set up Bluetooth, we need to install the `bluez` and `bluez-utils` packages to have at least a command line utility `bluetoothctl` to configure connections.

Now we need to check if the `btusb` kernel module was already loaded

#terminal-root("~")[`lsmod | grep btusb`]

After that, we can enable and start the `bluetooth.service` service

#terminal-root("~")[
  ```
  systemctl enable bluetooth.service
  
  systemctl start bluetooth.service
  ```
]

To use `bluetoothctl` and access your PC's Bluetooth device, your user must be a member of the `lp` group.

Now enter `bluetoothctl`

#terminal("~")[`bluetoothctl`]

In most cases, your Bluetooth interface will be preselected and defaulted, but in some cases, you might need to first select the Bluetooth controller

#codeblock[
  ```
  list
  
  select <MAC_address>
  ```
]

After that, power on the controller

#codeblock[
  ```
  power on
  ```
]

Now enter device discovery mode

#codeblock[
  ```
  scan on
  ```
]

and list found devices

#codeblock[
  ```
  devices
  ```
]

You can turn device discovery mode off again after your desired device has been found

#codeblock[
  ```
  scan off
  ```
]

Now turn on the agent

#codeblock[
  ```
  agent on
  ```
]

and pair it with your device

#codeblock[
  ```
  pair <MAC_address>
  ```
]

If your device doesn't support PIN verification, you might need to trust the device manually

#codeblock[
  ```
  trust <MAC_address>
  ```
]

Finally, connect to your device

#codeblock[
  ```
  connect <MAC_address>
  ```
]

If your device is an audio device, you might have to install `pulseaudio-bluetooth`.

You will then also need to append 2 lines to #filepath("/etc/pulse/system.pa")

#filesrc("/etc/pulse/system.pa")[
  ```
  load-module module-bluetooth-policy
  load-module module-bluetooth-discover
  ```
]

and restart `pulseaudio`

#terminal("~")[
  ```
  pulseaudo --kill
  
  pulseaudo --start
  ```
]

If you want a GUI to do all this, install `blueman` and launch `blueman-manager`.

== Graphical desktop environment

If you decide that you want to use a graphical desktop environment, you
have to install additional packages for that to work.

Things differ a little bit though, depending on whether you want to use `xorg` or `wayland`.

=== Xorg

#pkgtable(
  core: "nerd-fonts",
  extra: "alacritty arandr bspwm dmenu sxhkd xclip xorg-xinit",
  aur: "polybar",
  groups: "xorg xorg-drivers",
)

`xclip` is useful when sending something to the `X` clipboard.
It is also required for `neovim`'s clipboard to work
correctly. It is not required, though.

==== NVIDIA

#pkgtable(
  extra: "nvidia nvidia-utils nvidia-settings opencl-nvidia",
)

If you also want to utilize special NVIDIA functionality, for example
for `davinci-resolve`, you'll most likely need to install their
proprietary driver.

To configure the `X` server correctly, one can use `nvidia-xconfig`

#terminal-root("~")[`nvidia-xconfig`]

If you want to further tweak all settings available, you can use
`nvidia-settings`.

#terminal-root("~")[`nvidia-settings`]

will enable you to _"Save to X Configuration File"_, which merges your
changes with #filepath("/etc/X11/xorg.conf").

With

#terminal("~")[`nvidia-settings`]

you'll only be able to save the current configuration to #filepath("~/.nvidia-settings-rc"), which you have to source after `X` startup with

#terminal("~")[`nvidia-settings --load-config-only`]

You will have to reboot sooner or later after installing the NVIDIA
drivers, so you might as well do it now before any complications come
up.

==== Launching the graphical environment

After that, you can now do `startx` in order to launch the graphical
environment.

If anything goes wrong in the process, remember that you can press
`Ctrl+Alt+<Number>` to switch `tty`s.

===== The NVIDIA way

#pkgtable(extra: "bbswitch", aur: "nvidia-xrun")

If you're using an NVIDIA graphics card, you might want to use
#pkg-aur("nvidia-xrun") instead of `startx`. This has the advantage, of
the `nvidia` kernel modules, as well as the `nouveau` ones not loaded at
boot time, thus saving power. #pkg-aur("nvidia-xrun") will then load the
correct kernel modules, and run the `.nvidia-xinitrc` script in your home
directory (for more file locations look into the documentation for
#pkg-aur("nvidia-xrun")).

At the time of writing, #pkg-aur("nvidia-xrun") needs `sudo` permissions
before executing its task.

#pkgtable(aur: "nvidia-xrun-pm")

If your hardware doesn't support `bbswitch`, you would need to use
#pkg-aur("nvidia-xrun-pm") instead.

Now we need to blacklist _both `nouveau` and `nvidia`_ kernel modules.

To do that, we first have to find out, where our active `modprobe.d`
directory is located. There are 2 possible locations, generally
speaking: #filepath("/etc/modprobe.d") and #filepath("/usr/lib/modprobe.d"). In my case, it was
the latter, which I could tell, because this directory already had files
in it.

Now I'll create a new file named `nvidia-xrun.conf` and write the
following into it

```fish
blacklist nvidia
blacklist nvidia-drm
blacklist nvidia-modeset
blacklist nvidia-uvm
blacklist nouveau
```

With this config in place,

#terminal("~")[`lsmod | grep nvidia`]

and

#terminal("~")[`lsmod | grep nouveau`]

should return no output. Else you might have to place some additional
entries into the file.

Of course, you'll need to reboot, after blacklisting the modules and
before issuing the 2 commands mentioned.

If you installed `nvidia-xrun-pm` instead of `nvidia-xrun` and
`bbswitch`, you might want to also enable the `nvidia-xrun-pm` service

#terminal-root("~")[`systemctl enable nvidia-xrun-pm.service`]

The required `.nvidia-xinitrc` file, mentioned previously, should
already be provided in the `dotfiles` repository.

Now instead of `startx`, just run `nvidia-xrun`, and enter your `sudo`
password and you're good to go.

=== Wayland

Things behave a little different with `wayland`.
But fear not!

As I'm using `sway` as my `wayland` compositor and it almost is a drop-in replacement for `i3`, you shouldn't be long from `GUI`'ing away.

== Additional `console` software

Software that is useful in combination with a `console`.

=== `tmux`

#pkgtable(extra: "tmux")

I would recommend installing `tmux` which enables you to have multiple
terminal instances (called `windows` in `tmux`) open at the same time.
This makes working with the linux terminal much easier.

To view a list of keybindings, you just need to press `Ctrl+b` followed by
`?`.

=== Communication

Life is all about communicating. Here are some pieces of software to do
exactly that.

==== `weechat`

#pkgtable(extra: "weechat")

`weechat` is an `IRC` client for the terminal, with the best features
and even a `vim` mode, by using a plugin

To configure everything, open `weechat`

#terminal("~")[`weechat`]

and install `vimode`, as well as configure it

```fish
/script install vimode.py
/vimode bind_keys
/set plugins.var.python.vimode.mode_indicator_normal_color_bg "blue"
```

Now add `mode_indicator+` in front of and `,[vi_buffer]` to the end of
`weechat.bar.input.items`, in my case

```fish
/set weechat.bar.input.items
  "mode_indicator+[input_prompt]+(away),
   [input_search], [input_paste],
   input_text, [vi_buffer]"
```

Now add `,cmd_completion` to the end of `weechat.bar.status.items`, in
my case

```fish
/set weechat.bar.status.items
  "[time], [buffer_last_number], [buffer_plugin],
   buffer_number+:+buffer_name+(buffer_modes)
  +{buffer_nicklist_count}+buffer_zoom+buffer_filter,
   scroll, [lag], [hotlist], completion, cmd_completion"
```

Now enable `vimode` searching

```fish
/set plugins.var.python.vimode.search_vim on
```

Now you just need to add a new connection, for example
`irc.freenode.net`

```fish
/server add freenode irc.freenode.net
```

and connect to it

```fish
/connect freenode
```

You might need to authenticate with `NickServ`, before being able to
write in a channel

```fish
/msg NickServ identify <password>
```

Instead of directly `/set`ting the values specified above, you can also
do

```fish
/fset weechat.var.name
```

after that, using the cursor, select the entry you want to modify (for
example `plugins.var.python.vimode`) and then press `s` (make sure
you're in `insert` mode) and `Return`, in order to modify the existing
value.

=== PDF viewer

#pkgtable(extra: "fbida ghostscript")

To use `asciidoctor-pdf`, you might be wondering how you are supposed to
open the generated PDFs from the native linux fish.

This `fbida` package provides the `fbgs` software, which renders a PDF
document using the native frame buffer.

To view this PDF document (`Documentation.pdf`) for example, you would
run

#terminal("~")[`fbgs Documentation.pdf`]

You can view all the controls by pressing `h`.

== Additional `hybrid` software

Some additional software provides some kind of `GUI` to work with, but
that can be useful in a `console` only environment nevertheless.

=== `Pass`word management

I'm using `pass` as my password manager. As we already installed it in
the step and updated the `submodule` that holds our `.password-store`,
there is nothing left to do in this step

=== `python`

#pkgtable(extra: "python")

Python has become really important for a magnitude of use cases.

=== `ruby` & `asciidoctor`

#pkgtable(extra: "ruby rubygems")

In order to use `asciidoctor`, we have to install `ruby` and `rubygems`.
After that, we can install `asciidoctor` and all its required gems.

If you want to have pretty and highlighted source code, you'll need to
install a code-formatter too.

For me, there are mainly two options

#list[
  `pygments.rb`, which requires `python` to be installed

#terminal("~")[`gem install pygments.rb`]
][
  `rouge` which is a native `ruby` gem

#terminal("~")[`gem install rouge`]
]

Now the only thing left, in my case at least, is adding #filepath("~/.gem/ruby/2.7.0/bin") to your path.

Please note that if you run a ruby version different from `2.7.0`, or if
you upgrade your ruby version, you have to use the `bin` path for that
version.

For `zsh` you'll want to add a new entry inside the `.zshpath` file

```fish
path+=("$HOME/.gem/ruby/2.7.0/bin")
```

which then gets sourced by the provided `.zshenv` file. An example is
provided with the `.zshpath.example` file

You might have to re-#cmd[`source`] the `.zshenv` file to make the changes
take effect immediately

#terminal("~")[`source .zshenv`]

If you want to add a new entry to the `path` variable, you have to
append it to the array

```fish
path+=("$HOME/.gem/ruby/2.7.0/bin" "$HOME/.gem/ruby/2.6.0/bin")
```

If you use another shell than `zsh`, you might have to do something
different, to add a directory to your `PATH`.

=== `JUCE` and `FRUT`

`JUCE` is a library for `C++` that enables you to develop cross-platform
applications with a single codebase.

`FRUT` makes it possible to manage `JUCE` projects purely from `cmake`.

Note that apparently in the new `JUCE` version, `cmake` support is
integrated. It remains to be seen how well this will work and if `FRUT`
will become obsolete.

The information in this guide should be updated ASAP if it is apparent
that `FRUT` has now become obsolete.

#terminal("~")[`git clone https://github.com/WeAreROLI/JUCE.git`]
#terminal("~/JUCE")[`git checkout develop`]
#terminal("~")[`git clone https://github.com/McMartin/FRUT.git`]

==== Using `JUCE`

#pkgtable(
  core: "gcc gnutls",
  extra: "alsa-lib clang freeglut freetype2 jack2 ladspa libcurl-gnutls libx11 libxcomposite libxinerama libxrandr mesa webkit2gtk",
  multilib: "lib32-freeglut",
)

In order to use `JUCE`, you'll need to have some dependency packages
installed, where `ladspa` and `lib32-freeglut` are not necessarily
needed.

=== Additional development tools

Here are just some examples of development tools one could install in
addition to what we already have.

==== Code formatting

#pkgtable(extra: "astyle")

We already have `clang-format` as a code-formatter, but this only works
for `C`-family languages. For `java` stuff, we can use `astyle`

==== Documentation

#pkgtable(extra: "doxygen")

To generate documentation from source code, I mostly use `doxygen`

==== Build tools

#pkgtable(extra: "ninja")

In addition to `make`, I'll often times use `ninja` for my builds

=== Android file transfer

#pkgtable(
  extra: "gvfs-mtp libmtp",
)

Now you should be able to see your phone inside either your preferred
filemanager, in my case `thunar`, or #pkg-aur("gigolo").

If you want to access the android's file system from the command line,
you will need to either install and use #pkg-aur("simple-mtpfs"), or `adb`

==== #pkg-aur("simple-mtpfs")

#pkgtable(aur: "simple-mtpfs")

Edit #filepath("/etc/fuse.conf") to uncomment

```fish
user_allow_other
```

and mount the Android device

#terminal("~")[
  ```
  simple-mtpfs -l
  
  mkdir ~/mnt
  
  simple-mtpfs --device <number> ~/mnt -allow_other
  ```
]

and respectively unmount it

#terminal("~")[
  ```
  fusermount -u mnt
  
  rmdir mnt
  ```
]

==== `adb`

#pkgtable(extra: "android-tools")

Kill the `adb` server, if it is running

#terminal("~")[`adb kill-server`]

If the server is currently not running, #cmd[`adb`] will output an error
with a `Connection refused` message.

Now connect your phone, unlock it, and start the `adb` server

#terminal("~")[`adb start-server`]

If the PC is unknown to the Android device, it will display a
confirmation dialog. Accept it and ensure that the device was recognized

#terminal("~")[`adb devices`]

Now you can `push`/`pull` files.

#terminal("~")[
  ```
  adb pull /storage/emulated/0/DCIM/Camera/IMG.jpg .
  
  adb push IMG.jpg /storage/emulated/0/DCIM/Camera/IMG2.jpg
  
  adb kill-server
  ```
]

Of course, you would need to have the _developer options_ unlocked, as
well as the _USB debugging_ option enabled within them, for `adb` to
even work.

=== Partition management

#pkgtable(
  extra: "gparted parted",
)

You may also choose to use a graphical partitioning software instead of
`fdisk` or `cfdisk`. For that, you can use `gparted`. Of course, there is
also the `console` equivalent `parted`.

=== PDF viewer

#pkgtable(
  extra: "evince zathura zathura-pdf-mupdf",
)

To use `asciidoctor-pdf`, you might be wondering how you are supposed to
open the generated PDFs using the GUI.

The software `zathura` has a minimalistic design and UI with a focus on
vim keybinding, whereas `evince` is a more desktop-like experience, with
things like a print dialogue, etc.

=== Process management

#pkgtable(
  extra: "htop xfce4-taskmanager",
)

The native tool is `top`.

The next evolutionary step would be `htop`, which is an improved version
of `top` (like `vi` and `vim` for example)

If you prefer a GUI for that kind of task, use `xfce4-taskmanager`.

=== Video software

Just some additional software related to videos.

==== Live streaming a terminal session

#pkgtable(extra: "tmate")

For this task, you'll need a program called `tmate`.

== Additional `GUI` software

As you now have a working graphical desktop environment, you might want
to install some software to utilize your newly gained power.

=== Session Lock

#pkgtable(
  extra: "xsecurelock xss-lock",
)

Probably the first thing you'll want to set up is a session locker,
which locks your `X`-session after resuming from sleep, hibernation,
etc. It then requires you to input your password again, so no
unauthorized user can access your machine.

I'll use `xss-lock` to hook into the necessary `systemd` events and then
use `xsecurelock` as my locker.

You need to make sure this command gets executed upon the start of the
`X`-session, so hook it into your window manager startup script, or in a
file called by your desktop environment

#terminal("~")[`xss-lock -l -- xsecurelock &`]

=== #pkg-aur("xfce-polkit")

#pkgtable(aur: "xfce-polkit")

In order for GUI applications to acquire `sudo` permissions, we need to
install a `PolicyKit` authentication agent.

We could use `gnome-polkit` for that purpose, which resides inside the
official repositories, but I decided on using #pkg-aur("xfce-polkit").

Now you just need to start up #pkg-aur("xfce-polkit") before trying to
execute something like `gparted` and you'll be prompted for your
password.

As I already launch it as a part of my `bspwm` configuration, I won't
have to worry about that.

=== Desktop background

#pkgtable(extra: "nitrogen")

You might want to consider installing `nitrogen`, in order to be able to
set a background image

=== Compositing software

#pkgtable(extra: "picom")

To get buttery smooth animation as well as e.g. smooth video playback in
`brave` without screen tearing, you might want to consider using a
compositor, in my case one named `picom`

In order for `obs`' screen capture to work correctly, you need to kill
`picom` completely before using `obs`.

#terminal("~")[`killall picom`]

or

#terminal("~")[
  ```
  ps aux | grep picom
  
  kill -9 <pid>
  ```
]

=== `networkmanager` applet

#pkgtable(extra: "network-manager-applet")

To install the `NetworkManager` applet, which lives in your tray and
provides you with a quick method to connect to different networks, you
have to install the `network-manager-applet` package

Now you can start the applet with

#terminal("~")[`nm-applet &`]

If you want to edit the network connections with a more fullscreen
approach, you can also launch #cmd[`nm-connection-editor`].

The `nm-connection-editor` doesn't search for available Wi-Fi. You
would have to set up a Wi-Fi connection completely by hand, which could
be desirable depending on how difficult it is to set up your Wi-Fi.

=== Show keyboard layout

#pkgtable(aur: "xkblayout-state")

To show, which keyboard layout and variant is currently in use, you can
use #pkg-aur("xkblayout-state")

Now simply issue the `layout` alias, provided by my custom `zsh`
configuration.

=== X clipboard

#pkgtable(extra: "xclip")

To copy something from the terminal to the `xorg` clipboard, use `xclip`

=== Taking screenshots

#pkgtable(extra: "scrot")

For this functionality, especially in combination with `rofi`, use
`scrot`.

#cmd[`scrot ~/Pictures/filename.png`] then saves the screen shot under #filepath("~/Pictures/filename.png").

=== Image viewer

#pkgtable(extra: "ristretto")

Now that we can create screenshots, we might also want to view those

#terminal("~")[`ristretto filename.png`]

=== File manager

#pkgtable(
  extra: "gvfs thunar",
  aur: "gigolo",
)

You probably also want to use a file manager. In my case, `thunar`, the
`xfce` file manager, worked best.

To also be able to mount removable drives, without being `root` or using
`sudo`, and in order to have a GUI for mounting stuff, you would need to
use #pkg-aur("gigolo") and `gvfs`.

=== Archive manager

#pkgtable(
  extra: "cpio unrar unzip xarchiver zip",
)

As we now have a file manager, it might be annoying, to open up a
terminal every time you simply want to extract an archive of some sort.
That's why we'll use `xarchiver`.

=== Web browser

#pkgtable(
  extra: "browserpass firefox firefox-i18n-en-us",
)

As you're already using a GUI, you also might be interested in a web
browser. In my case, I'm using `firefox`, as well as `browserpass` from
the official repositories, the #linkfn("https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/")[uBlock Origin], #linkfn("https://addons.mozilla.org/en-US/firefox/addon/darkreader/")[Dark Reader], #linkfn("https://addons.mozilla.org/en-US/firefox/addon/duckduckgo-for-firefox/")[DuckDuckGo Privacy Essentials], #linkfn("https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/")[Vimium] and finally #linkfn("https://addons.mozilla.org/en-US/firefox/addon/browserpass-ce/")[Browserpass] add-ons,
in order to use my passwords in `firefox` and have the best protection in
regard to privacy, while browsing the web.

We still have to set up `browserpass`, after installing all of this

#terminal("/usr/lib/browserpass")[`make hosts-firefox-user`]

==== Entering the dark side

#pkgtable(aur: "tor-browser")

You might want to be completely anonymous whilst browsing the web at
some point. Although this shouldn't be your only precaution, using
#pkg-aur("tor-browser") would be the first thing to do

You might have to check out how to import the `gpg` keys on the `AUR`
page of `tor-browser`.

=== Office utilities

#pkgtable(extra: "libreoffice-fresh")

I'll use `libreoffice-fresh` for anything that I'm not able to do with
`neovim`.

==== Printing

#pkgtable(
  extra: "avahi cups cups-pdf nss-mdns print-manager system-config-printer",
)

In order to be able to print from the `gtk` print dialog, we'll also
need `system-config-printer` and `print-manager`.

#terminal-root("~")[
  ```
  systemctl enable avahi-daemon.service
  
  systemctl start avahi-daemon.service
  ```
]

Now you have to edit #filepath("/etc/nsswitch.conf") and add
#raw("mdns4_minimal [NOTFOUND`return]=")

#filesrc("/etc/nsswitch.conf")[
  #raw(block: true, "hosts: files mymachines myhostname mdns4_minimal [NOTFOUND`return] resolve [!UNAVAIL`return] dns")
]

Now continue with this

#terminal("~")[
  ```
  avahi-browse --all --ignore-local --resolve --terminate
  ```
]
#terminal-root("~")[
  ```
  systemctl enable org.cups.cupsd.service
  
  systemctl start org.cups.cupsd.service
  ```
]

Just open up `system-config-printer` now and configure your printer.

To test if everything is working, you could open up `brave`, then go to
_Print_ and then try printing.

=== Communication

Life is all about communicating. Here are some pieces of software to do
exactly that.

==== Email

#pkgtable(extra: "thunderbird")

There is nothing better than some classical email.

==== Telegram

#pkgtable(extra: "telegram-desktop")

Do you want to have your `telegram` messages on your desktop PC?

==== TeamSpeak 3

#pkgtable(extra: "teamspeak3")

Wanna chat with your gaming friends and they have a `teamspeak3` server?

==== Discord

#pkgtable(extra: "discord")

You'd rather use `discord`?

=== Video software

Just some additional software related to videos.

==== Viewing video

#pkgtable(extra: "vlc")

You might consider using `vlc`

==== Creating video

#pkgtable(
  aur: "obs-linuxbrowser-bin obs-glcapture-git obs-studio-git",
)

#pkg-aur("obs-studio-git") should be the right choice.

You can also make use of the plugins provided in the package list above.

===== Showing keystrokes

#pkgtable(aur: "screenkey")

In order to show the viewers what keystrokes you're pressing, you can
use something like #pkg-aur("screenkey")

For ideal use with `obs`, my `dotfiles` repository already provides you
with the #cmd[`screenkey-obs`] alias for you to run with `zsh`.

==== Editing video

#pkgtable(aur: "davinci-resolve")

In my case, I'm using #pkg-aur("davinci-resolve").

==== Utilizing video

#pkgtable(aur: "teamviewer")

Wanna remote control your own or another PC?

#pkg-aur("teamviewer") might just be the right choice for you

=== Audio Production

You might have to edit #filepath("/etc/security/limits.conf"), to increase the
allowed locked memory amount.

In my case, I have 32GB of RAM and I want the `audio` group to be able to
allocate most of the RAM, which is why I added the following line to the
file

```fish
@audio - memlock 29360128
```

==== Ardour

#pkgtable(extra: "ardour")

To e.g. edit and produce audio, you could use `ardour` because it's
easy to use, stable, and cross-platform.

#pkgtable(extra: "ffmpeg")

Ardour won't natively save in the `mp3` format, due to licensing stuff.
In order to create `mp3` files, for sharing with other devices, because
they have problems with `wav` files, for example, you can just use
`ffmpeg`.

and after that, we're going to convert `in.wav` to `out.mp3`

#terminal("~")[`ffmpeg -i in.wav -acodec mp3 out.mp3`]

==== Reaper

#pkgtable(aur: "reaper-bin")

Instead of `ardour`, I'm using `reaper`, which is available for linux as
a beta version, in my case more stable than `ardour` and easier to
use for me.

=== Virtualization

#pkgtable(
  extra: "virtualbox virtualbox-host-modules-arch",
)

You might need to run another OS, for example, Mac OS, from within Linux,
e.g. for development/testing purposes. For that, you can use
`virtualbox`.

Now when you want to use `virtualbox` just load the kernel module

#terminal-root("~")[`modprobe vboxdrv`]

and add the user which is supposed to run #cmd[`virtualbox`] to the
`vboxusers` group

#terminal-root("~")[`usermod -a G vboxusers $USER`]

and if you want to use the `rawdisk` functionality, also the `disk` group

#terminal-root("~")[`usermod -a G disk $USER`]

Now just re-login and you're good to go.

=== Gaming

#pkgtable(
  extra: "lutris pulseaudio pulseaudio-alsa",
  multilib: "lib32-libpulse lib32-nvidia-utils steam",
)

The first option for native/emulated gaming on Linux is obviously
`steam`.

The second option would be `lutris`, a program, that configures a wine
instance correctly, etc.

=== Wacom

#pkgtable(
  extra: "libwacom xf86-input-wacom",
)

In order to use a Wacom graphics tablet, you'll have to install some
packages

You can now configure your tablet using the `xsetwacom` command.

=== `VNC` & `RDP`

#pkgtable(extra: "libvncserver, remmina", aur: "freerdp")

In order to connect to a machine over `VNC` or to connect to a machine
using the `Remote Desktop Protocol`, for example, to connect to a Windows
machine, I'll need to install #pkg-aur("freerdp"), as well as
`libvncserver`, for `RDP` and `VNC` functionality respectively, as well
as `remmina`, to have a GUI client for those two protocols.

Now you can set up all your connections inside `remmina`.

= Upgrading the system

You're probably wondering why this gets a dedicated section.

You'll probably think that it would be just a matter of issuing

#terminal-root("~")[`pacman -Syu`]

That's both true and false.

You have to make sure, _that your boot partition is mounted at #filepath("/boot")_ in order for everything to upgrade correctly. That's because the moment you upgrade the `linux` package without having the correct partition mounted at #filepath("/boot"), your system won't boot. You also might have to do #cmd[`grub-mkconfig -o /boot/grub/grub.cfg`] after you install a different kernel image.

If your system _indeed doesn't boot_ and _boots to a recovery fish_, then double check that the issue really is the not perfectly executed kernel update by issuing

#terminal("~")[
  ```
  uname -a
  
  pacman -Q linux
  ```
]

_The version of these two packages should be exactly the same!_

If it isn't there is an easy fix for it.

== Fixing a faulty kernel upgrade

First off we need to restore the old `linux` package.

For that note the version number of

#terminal-root("~")[`uname -a`]

Now we'll make sure first that nothing is mounted at #filepath("/boot"), because
the process will likely create some unwanted files. The process will
also create a new #filepath("/boot") folder, which we're going to delete
afterward.

#terminal-root("~")[`umount /boot`]

Now `cd` into `pacman`'s package cache

#terminal-root("~")[`cd /var/cache/pacman/pkg`]

There should be a file located named something like `linux-<version>.pkg.tar.xz`, where `<version>` would be somewhat equivalent to the previously noted version number

Now downgrade the `linux` package

#terminal-root("~")[`pacman -U linux-<version>.pkg.tar.xz`]

After that remove the possibly created #filepath("/boot") directory

#terminal-root("/")[
  ```
  rm -rf /boot
  
  mkdir /boot
  ```
]

Now reboot and mount the `boot` partition, in my case an EFI System
partition.

Now simply rerun

#terminal-root("~")[`pacman -Syu`]

and you should be fine now.

= Glossary <glossary>

This documentation is structured in a way that allows you to keep a printed version up to date without the need to reprint the whole thing.
This is why every section starts on a new page and page numbers are omitted.

In the following sections, I will quickly describe the meaning of a handfull of special markup, which hopefully makes the whole document more readable and structured.

== Blocks

There are special blocks that are supposed to draw your attention and seperate their contents:

#note[
  This is a *note*.
  This annotates some special edge cases, some #emph[gotcha]s, noteworthy stuff, etc.
]

#tip[
  This is a *tip*.
  This will often be employed if there is a scenario I often times struggled with, or if some special or unusual procedure is needed.
]

#important[
  This is *important*.
  Should probably be read and adhered to unless you know what you're doing.
]

#warning[
  This gives you a *warning*.
  In general, this includes big #emph[gotcha]s, problems, potentially breaking stuff, etc.
]

#caution[
  This gives you the hint to proceed with *caution* and double-check!
]


== Programs, tools & terms

Terms denoted by a `monospaced font` are mostly commands/programs or specific terms that are generally accepted to be a universal name for what they describe.

For example when I say that you need to `cd` into the directory, `cd` denotes the program/command I intend you to use.
If I say you need to read the `PKGBUILD` or that you need to create an `EFI System Partition`, that in turn is the universally accepted name for both of those things.

#note[
  Note however that in case of the mentioned programs, _`cd` into the direcory_, or reading the _`PKGBUILD`_, this is just the lowest level / highest abstraction version. I could instead use:

  - #pkg-aur("sbupdate-git") instead of e.g. `sbupdate-git`, if I assume you don't have the program yet and need the package / repository link _(explained in @packages)_
  - #cmd[`rm -rf folder/*.txt`], instead of the simple `rm -rf folder/*.txt` _(explained in @commands)_
  - #filepath("PKGBUILD") as a filepath descriptor, in place of  `PKGBUILD` _(explained in @files)_
]

== Links <links>

Normally, you would simply embed a #link("https://archlinux.org")[link] into the document.

But a reader of this guide who uses `Dead-Tree-Format`#emoji.tm aka. paper, will neither be able to distinguish the link from the rest of the text, nor be able to get any information regarding the target of the link.

This is why I try and provide every link as a #linkfn("https://archlinux.org")[footnote-link], which works exactly like a regular link with the big difference that the link target is fully written out in the footnotes of the page.

#note[
  The footnote numbering resets for each page, to ensure the `hot-swap`-ability of the pages as mentioned in @glossary.
]

== Packages <packages>

In order to
- not clutter the pages with install instructions / packages required for specific sections,
- group packages together so you can install everything in one go,
- and make them visibly stand out
I use two different markups for packages.

If a package is simply mentioned within a paragprah, e.g. #pkg("alacritty"), it will be visually separated from the rest of the content and a link provided in the footnotes (see @links).

This way you can also easily tell a normal package #pkg("alacritty") apart from an `AUR` package #pkg-aur("sbupdate-git").
Both the packge name and the footnote-link are clickable and lead you to the generated URL.
#pagebreak()
The second option is a package-table which categorizes the packages into repositories.

#pkgtable(
  core: "base linux",
  extra: "neovim pulseaudio",
  multilib: "lib32-libpulse",
)

In this case, you can click the globe symbol #emoji.globe.eu.af to get to the repository overview, or the package itself to get to the package.
The packages are, as you can see, also grouped together by repository.

#important[
  As of _May 21st, 2023_, ArchLinux migrated to `git` packaging and in the process merged the `community` repository into `extra`.
  This change will also be reflected in this document.

  Read #linkfn("https://archlinux.org/news/git-migration-completed/")[the announcment] for further information on how to proceed and update your system.
]

== Commands <commands>

Furthermore, I will denote a command execution in a shell with syntax highlighting and a different background: #cmd[`uname -a`].
If a root shell is needed, I will denote it with a preceding #emoji.lock: #cmd(root: true)[`touch /root/testfile`].

This then mostly includes any needed command line arguments.

== Console blocks

Multiple commands, where the execution user or rather the privilege needed, as well as the current working directory, are of interest, are displayed in a command execution block.
You can infer the privilege the command was executed by looking at the #emoji.lock symbol before the path.

#note[
  Even when the command is executed in a root shell, the path #filepath("~") always refers to the local, _normal_ user's home directory (usually #filepath("/home/username")).

  Technically #filepath("~") #sym.eq.def #filepath("/root") is true, when in a root shell, but to reduce visual clutter, I decided to use this convention instead.
]

In any case, the first line always contains the current working directory and the next line is the prompt:

#terminal("~")[`git init`]
#terminal-root("/etc")[`rm fstab`]

#pagebreak(weak: true)

In case of a windows `cmd` command, you can easily distinguish it from the `linux` shell commands by the filepath descriptor, which of course uses Windows syntax, as well as a #emph("Window")s #emoji.window symbol:

#terminal(windows: true, "C:\\Program Files (x86)\Common Files")[`dir`]

== Files <files>

For the content of a file, a file listing is used, showing the content of the file as well as the full filepath:
#filesrc("~/test.sh")[
  ```sh
  #!/bin/bash
  export var="value"
  ```
]

If the file is only partially displayed, or only an addition is shown, it is denoted by three dots #sym.dots being appended to the file path:
#filesrc(part: true, "~/test.sh")[
  ```sh
  echo "appendage"
  ```
]

In case the file is _readonly_, I will use the glasses symbol #emoji.glasses, if you need elevated or specific permissions, the lock symbol #emoji.lock and if the file needs to be executable, the joystick symbol #emoji.joystick:
#filesrc(part: true, readonly: true, perm: true, "/etc/sudoers")[
  ```
  %wheel      ALL=(ALL:ALL) ALL
  ```
]
#filesrc(exec: true, perm: true, "/root/prank.sh")[
  ```sh
  #!/bin/bash
  echo "It's just a prank"
  ```
]

If I only want to _mention_ a file or path, I will denote it like this #filepath("~/test.sh").

== Explanations

If any term needs an explanation, I will explain it briefly in the following form:

/ Term: Short explanation
/ 2#super[nd] Term:
  This is a long explanation.\
  With multiple lines and everything.\

There is also a variant with more space between the items:

/ Term: Short explanation

/ Another term: Another short explanation

== Example section

#pkgtable(
  core: "base-devel",
  extra: "ardour cadence git jsampler linuxsampler qsampler",
  aur: "sbupdate-git",
)

#note[
  You have to configure #pkg("sample-package"), or rather #pkg-aur("sample-package-git"), by editing #filepath("/etc/sample.conf") with e.g. #cmd[`nvim /etc/sample.conf`]

  #filesrc("/etc/sample.conf")[
    ```
    Sample.text=useful
    ```
  ]
]

If there is someting unusual going on, which you don't understand, try turning it off and on again.

#caution[
  Bad joke detected!
]

= Additional notes

If you've printed this guide, you might want to add some additional
blank pages for notes.
