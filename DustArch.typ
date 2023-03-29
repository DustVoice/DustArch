#let border_block(color, content) = block(
  align(left, content),
  stroke: .25em + rgb(color),
  inset: 1em,
  radius: .5em,
  width: 100%
)
#let fill_block(color, content) = block(
  align(left, content),
  fill: rgb(color),
  inset: 1em,
  radius: .5em,
  width: 100%
)

#let border_box(color, content) = box(
  content,
  stroke: .25em + rgb(color),
  inset: .25em,
  radius: .25em
)
#let fill_box(color, content) = box(
  content,
  fill: rgb(color),
  inset: .25em,
  radius: .25em
)

#set text(font: "DejaVu Sans", size: 12pt)

#set document(
  title: "DustArch",
  author: "DustVoice"
)

#set page(
  paper: "a5",
  header: align(
    center,
    block(spacing: 0pt)[
      #text(1.5em, fill: rgb("#ff79c6"))[DustArch]\
      #text(0.5em, fill: rgb("#bd93f9"))[DustVoice's Arch Linux from scratch]
    ]
  ),
  numbering: none
)

#set par(justify: true)

#set figure(numbering: none)

#set heading(numbering: "1.1.")

#let code(lang: "", content) = raw(lang: lang, block: false, content)
#let cmd(content) = code(lang: "fish", content)

#let _path(content) = fill_box("#8be9fd", content)
#let path(content) = _path(raw(content))

#let filesrc(filename, content) = figure(
  caption: path(filename),
  border_block("#8be9fd", content)
)

#let pkgtable(core, extra, community, aur) = figure(
  table(
    columns: 4,
    align: center,
    [*core*], [*extra*], [*community*], [*AUR*],
    core, extra, community, aur
  )
)

#let NOTE(content) = figure()[
  #border_block("#6272a4", content)
]
#let TIP(content) = figure()[
  #border_block("#f1fa8c", content)
]
#let IMPORTANT(content) = figure()[
  #border_block("#ff5555", content)
]
#let WARNING(content) = figure()[
  #border_block("#ffb86c", content)
]
#let CAUTION(content) = figure()[
  #border_block("#ff79c6", content)
]

// CONTENT START

#outline(indent: true)

#show heading: heading => {
  pagebreak()
  text(1.25em, heading)
}

= Inside the `archiso`

This chapter is aimed at assisting with the general setup of a customized Arch Linux installation, using an official Arch Linux image (`archiso`).

#NOTE[
  As Arch Linux is a rolling release GNU/Linux distribution, it is advised, to have a working internet connection, in order to get the latest package upgrades and to install additional software, as the `archiso` doesn't have all packages available from cache, especially the ones that need to be installed from the `AUR`.

  / AUR (Arch User Repository):
    A huge collection of packages, contributed and maintained by the community, which in order to install you need to download and build.\
    Accessable and browsable under #link("https://aur.archlinux.org/")[aur.archlinux.org].

  Furthermore, one should bear in mind that depending on the version, or rather modification date, of this guide, the exact steps taken may already be outdated.
  If you encounter any problems along the way, you will either have to resolve the issue yourself, or utilize the great #link("https://wiki.archlinux.org/")[ArchWiki], or the #link("https://bbs.archlinux.org/")[Arch Linux forums].
]

To get some explanation on how this document is formatted, look into the @glossary

== Syncing up `pacman`


First of all we need to sync up `pacman`'s package repository, in order to be able to install the latest, as well as new packages to the `archiso` and our new system.

```fish
> pacman -Sy
```

#WARNING[
  Using #cmd("> pacman -Sy") should be sufficient, in order to be able to search for packages from within the `archiso`, without upgrading the system, but might break your system, if you use this command on an existing installation!

  To be on the safe side, it is advised to always use #cmd("> pacman -Syu") instead!

  `pacstrap` uses the latest packages anyways.
]

=== Official repositories

After doing that, we can now install any software from the official repositories by issuing

```fish
root in /
> pacman -S <package_name>
```

where you would replace `<package_name>` with the actual package name.

If you want to remove an installed package, just use

```fish
root in /
> pacman -Rsu <package_name>
```

If you don't know the exact package name, or if you just want to search for a keyword, for example `xfce`, to list all packages having something to do with `xfce`, use

```fish
root in /
> pacman -Ss <keyword>
```

If you really need to force remove a package, which you should use _with extreme caution_, you could use

```fish
root in /
> pacman -Rdd <package_name>
```

=== `AUR`

If you want to install a package from the #link("https://aur.archlinux.org/")[AUR], I would advise proceeding in the following manner, in order to install the `AUR`-helper #link("https://aur.archlinux.org/packages/paru")[paru].

#enum[
  Clone the package with `git`

```fish
~
> git clone https://aur.archlinux.org/paru.git

```

   If you are on a slow PC, or don't want to compile `paru` from scratch, you can also use #link("https://aur.archlinux.org/packages/paru-bin")[paru-bin].
 ][
   Switch to the package directory

```fish
~
> cd paru

```
 ][
   Execute #cmd("> makepkg")

```fish
~/paru
> makepkg -si

```
 ][
   Delete all files created, as `paru` will now be handling all the
   `AUR` stuff.

```fish
~/paru
> cd ..

~
> rm -rf paru

```
 ]

If you only install `AUR` packages the manual way, you might have to resolve some `AUR` dependencies manually, which can't be automatically resolved by `makepkg`'s `-s` option, which uses `pacman`.

In order to install a desired `AUR` package, you _must_ switch to your normal, non-`root` user, because `makepkg` doesn't run as `root`.

=== Software categories

In this guide, software is categorized in three different categories

/ `console`: Intended to be used with either the native linux console, or with a terminal emulator

/ `GUI`: Intended to be used within a graphical desktop environment

/ `hybrid`: To be used either within both a console and a graphical desktop environment (e.g. `networkmanager`), or there are packages available for both a console and a graphical desktop environment (e.g. `pulseaudio` with `pulsemixer` for `Console` and `pavucontrol` for `GUI`)

=== Software installation

In this guide, I'll be explicitly listing the packages installed in a specific section at the beginning of the individual sections.

This allows you to

- clearly see what packages get installed / need to be installed in a specific section

- install packages before you start with the section in order to minimize waiting time

The packages are always the recommended packages.

For further clarification for specific packages (e.g. `UEFI` specific packages), continue reading the section, as there is most certainly an explanation or follow-up section there.

Of course, as always, you can and *should* adapt everything according to your needs, as this guide is, again, _no tutorial, but a guide_.

==== Example section

#pkgtable(
  "libutil-linux",

  "git",

  "ardour
  cadence
  jsampler
  linuxsampler
  qsampler
  sample-package",

  "sbupdate"
)
You have to configure `sample-package`, by editing #path("/etc/sample.conf")

#filesrc("/etc/sample.conf")[
```
Sample.text=useful
```
]

== Formatting the drive

First, you probably want to get a list of all available drives, together with their corresponding device name, by issuing

```fish
root in /
> fdisk -l
```

The output of #cmd("> fdisk -l") is dependent on your system configuration and many other factors, like `BIOS` initialization order, etc.

#CAUTION[
  Don't assume the same path of a device between reboots!

  Always double check!

  There is nothing worse than formatting a drive you didn't mean to format!
]

=== The standard way

In my case, the partition I want to install the root file system on will be `/dev/mapper/DustPortable`, which is an unlocked `luks2` volume which will be located on `/dev/sda2`. For my `swap`, I will use a swapfile.

#NOTE[
  A `swap` size twice the size of your RAM is recommended by a lot of people.

  To be exact, every distribution has different recommendations for `swap` sizes. Also `swap` size heavily depends on whether you want to be able to hibernate, etc.
]

==== In my opinion

You should make the `swap` size at least your RAM size and for RAM sizes over `4GB` with the intention to hibernate, at least one and a half times your RAM size.

If you haven't yet partitioned your disk, please refer to the #link("https://wiki.archlinux.org/index.php/Partitioning")[general partitioning tutorial] in the ArchWiki.

=== Full system encryption


#NOTE[
  This is only one way to do it (read: it is the way I have previously done it).
]

I'm using a `LUKS` setup, with `btrfs` and `luks2`.
For more information look into the #link("https://wiki.archlinux.org/")[ArchWiki].

This setup has different partitions, used for the `EFI System Partition`, `root` partition, etc. compared to the ones used in the rest of the guide.
The only part of the guide, which currently uses the drives & partitions used in this section is #link("*The manual way").

To start things, we first have to decide, which disk, or partition, is going to be `luks2` encrypted.

In my case I'll be using my SSD in an USB-C enclosure to be ablet to take the system with me on the go.
For that I will use a `GPT` partition scheme.
I will then create a `2 GiB` `EFI System partition` (I have multiple kernels installed at a time), in my case `/dev/sda1`, defined as a `EFI System partition` type in `gdisk`, as well as the main `luks2` volume, in my case `/dev/sda2`, defined as a `Linux filesystem` partition type in `gdisk`.

After partitioning our disk, we now have to set everything up.

==== `EFI System Partition`

#pkgtable("dosfstools", "", "", "")

I won't setup my `EFI System Partition` with `cryptsetup`, as it makes no sense in my case.

Every `EFI` binary (or `STUB`) will have to be signed with my custom Secure Boot keys, as described in #link("*The manual way"), so tempering with the `EFI System Partition` poses no risk to my system.

Instead I will simply format it with a `FAT32` filesystem

```fish
root in /
> mkfs.fat -F 32 -n EFI /dev/sda1
```

We will bother with mounting it later on.

When you _do_ want to encrypt your `EFI System Partition`, in conjunction with e.g. `grub`, please either use `LUKS 1`, or make sure to have the latest version of `grub` installed on your system, to make it work with `LUKS 2`!
I will use `limine` though, so for me all of this isn't a consideration.

==== `LUKS`

#pkgtable("cryptsetup", "", "", "")

First off we have to create the `LUKS` volume

```fish
root in /
> cryptsetup luksFormat --type luks2 /dev/sda2
```

In my case, I will convert the keyslot to `pbkdf2`, as `luks2` defaults to `argon2id`, which doesn't play well with my portable setup, namely the differing RAM sizes.

#NOTE[
  / pbkdf: Password-Based Key Derivation Function
]
```fish
root in /
> cryptsetup luksConvertKey --pbkdf pbkdf2 /dev/sda2
```

After that we have to open the volume

```fish
root in /
> cryptsetup open /dev/sda2 DustPortable
```

The volume is now accessible under `/dev/mapper/DustPortable`.

==== `btrfs`

#pkgtable("btrfs-progs", "", "", "")

Fist off we need to create the filesystem

```fish
root in /
> mkfs.btrfs -L DustPortable /dev/mapper/DustPortable
```

After that we mount the `btrfs` root under `/mnt/meta`

```fish
root in /
> mkdir /mnt/meta

root in /
> mount /dev/mapper/DustPortable /mnt/meta
```

Now we create the desired filesystem layout.

We will create 5 top level subvolumes that will be mounted at the appropriate places later on.

```fish
root in /mnt/meta
> btrfs subvolume create @

root in /mnt/meta
> btrfs subvolume create @home

root in /mnt/meta
> btrfs subvolume create @snapshots

root in /mnt/meta
> btrfs subvolume create @var_log

root in /mnt/meta
> btrfs subvolume create @swapfile
```

== Preparing the `chroot` environment

As a first step it might make sense to edit `/etc/pacman.d/mirrorlist` to move the mirrors geographically closest to you to the top.

=== `pacstrap` in

Generally we need to `pacstrap` the _minimum packages_ needed.
We will install all other packages later on.

#pkgtable(
  "base
  base-devel
  linux
  linux-firmware",
  "",
  "",
  ""
)

This is the actual command used in my case

```fish
root in /
> pacstrap /mnt/meta/@ base base-devel linux linux-firmware
```

=== Mounting party

Now we have to mount the subvolumes and boot partition we created earlier to the appropriate locations.

First off, we mount the `/` subvolume `@`

```fish
root in /
> mkdir /mnt/DustPortable

root in /
> mount -o subvol=@ /dev/mapper/DustPortable /mnt/DustPortable
```

Now we can mount the `/home` subvolume `@home`

```fish
root in /mnt/DustPortable
> mount -o subvol=@home /dev/mapper/DustPortable home
```

The `/.snapshots` subvolume `@snapshots` closely follows

```fish
root in /mnt/DustPortable
> mkdir .snapshots

root in /mnt/DustPortable
> mount -o subvol=@snapshots /dev/mapper/DustPortable .snapshots
```

After that we have to move the log dir `/var/log` to the appropriate subvolume `@var_log`

```fish
root in /mnt/DustPortable
> mv var/log var/log_bak

root in /mnt/DustPortable
> mount -o subvol=@var_log /dev/mapper/DustPortable var/log

root in /mnt/DustPortable
> mkdir var/log

root in /mnt/DustPortable
> mv var/log_bak/* var/log/

root in /mnt/DustPortable
> rmdir var/log_bak
```

Finally we can generate the `swapfile`

```fish
root in /mnt/DustPortable
> mkdir swapfile

root in /mnt/DustPortable
> mount -o subvol=@swapfile /dev/mapper/DustPortable swapfile

root in /mnt/DustPortable
> btrfs filesystem mkswapfile --size 128G swapfile/swapfile

root in /mnt/DustPortable
> swapon swapfile/swapfile
```

#IMPORTANT[
  I use my SSD inside a USB-C enclosure (although it is rated at 40Gbps it is *not* Thunderbolt 3!), which means that it _doesn't_ support `TRIM`.
  This is why I personally need to add `nodiscard` to every `mount` command option, which would look something along the lines of this

```fish
root in /
> mount -o subvol=@,nodiscard /dev/mapper/DustPortable /mnt/DustPortable
```
]

The only thing left to do now is mounting the boot partition, namely my `EFI System Partition`

```fish
root in /mnt/DustPortable
> mv boot boot_bak

root in /mnt/DustPortable
> mkdir boot

root in /mnt/DustPortable
> mount /dev/sda1 boot

root in /mnt/DustPortable
> mv boot_bak/* boot/

root in /mnt/DustPortable
> rmdir boot_bak
```

After that we can generate the `/etc/fstab` using `genfstab`

```fish
root in /
> genfstab -U /mnt/DustPortable >> /mnt/DustPortable/etc/fstab
```

and you're ready to enter the `chroot` environment.

=== Outdated `archiso`

If you're using an older version of the `archiso`, you might want to replace the mirrorlist present on the `archiso` with the newest #link("https://archlinux.org/mirrorlist/all")[online one]

```fish
root in /
> curl https://archlinux.org/mirrorlist/all > /etc/pacman.d/mirrorlist
```

#pkgtable("", "", "reflector", "")

The best way to do this tho, is using a package from the official repositories named `reflector`.
It comes with all sorts of options, for example sorting mirrors by speed, filtering by country, etc.

```fish
root in /
> reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist
```

After that you would need to reinstall the `pacman-mirror` package and
run

```fish
root in /
> pacman -Syyuu
```

for best results.

#CAUTION[
  Be wary though as there could arise keyring issues etc.
  Normally the `pacstrap` command takes care of syncing everything etc.
]

=== Living behind a proxy

If you're sitting behind a proxy, you're generally in for an unpleasant time.
Generally you need to set the `http_proxy`, `https_proxy`, `ftp_proxy` variables as well as their *upper case* counterparts.

```fish
root in /
> export http_proxy="http://ldiproxy.lsjv.rlp.de:8080"

root in /
> export https_proxy=$http_proxy

root in /
> export ftp_proxy=$http_proxy

root in /
> export HTTP_PROXY=$http_proxy

root in /
> export HTTPS_PROXY=$http_proxy

root in /
> export FTP_PROXY=$http_proxy
```

If you can't `pacstrap` after that, you probaby have the issue thatthe `systemd-timesyncd`, as well as `pacman-init` service didn't execute correctly.

```fish
root in /
> systemctl status systemd-timesyncd.service

root in /
> systemctl status pacman-init.service
```

To mitigate this, you need to initialize `pacman` yourself.

First off check whether the correct time is set.

```fish
root in /
> timedatectl
```

In my case the time zone was not correctly set, why my time was off by one hour, so I had to set it manually.

```fish
root in /
> timedatectl set-timezone Europe/Berli
```

After that we have to execute the `pacman-init` stuff manually

```fish
root in /
> pacman-key --init

root in /
> pacman-key --populate
```

#NOTE[
  You might also want to add the following lines to `/etc/sudoers`, in order to keep the proxy environment variables alive when executing a command through `sudo`

  #filesrc("/etc/sudoers")[
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
// #+end_NOTE

= Entering the `chroot`

#pkgtable("", "arch-install-scripts", "", "")

#NOTE[
  As we want to set up our new system, we need to have access to the different partitions, the internet, etc. which we wouldn't get by solely using `chroot`.

  That's why we are using `arch-chroot`, provided by the `arch-install-scripts` package, which is shipped with the `archiso`. This script takes care of all the afforementioned stuff, so we can set up our system properly.
]

```fish
root in /
> arch-chroot /mnt/DustPortable
```

Et Voil ! You successfully `chroot`-ed inside your new system and you'll be greeted by a `bash` prompt, which is the default shell on fresh Arch Linux installations.

== Installing additional packages

#pkgtable(
  "amd-ucode
  base-devel
  btrfs-progs
  diffutils
  dmraid
  dnsmasq
  dosfstools
  efibootmgr
  emacs-nativecomp
  exfat-utils
  iputils
  linux-headers
  openssh
  sudo
  usbutils",

  "efitools
  git
  intel-ucode
  networkmanager
  networkmanager-openconnect
  networkmanager-openvpn
  parted
  polkit
  rsync
  zsh",

  "fish
  neovim",

  "limine"
)

There are many command line text editors available, like `nano`, `vi`,
`vim`, `emacs`, etc.

I'll be using `neovim` as my simple text editor, until a certain point, at which I'll replace it with my doom-`emacs` setup, though it shouldn't matter what editor you choose for the rest of the guide.

Make sure to enable the `NetworkManager.service` service, in order for the Internet connection to work correctly, upon booting into the fresh system later on.

```fish
root in /
> systemctl enable NetworkManager.service
```

With `polkit` installed, create a file to enable users of the `network` group to add new networks without the need of `sudo`.

#filesrc("/etc/polkit-1/rules.d/50-org.freedesktop.NetworkManager.rules")[
```
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") `` 0 && subject.isInGroup("network")) {
        return polkit.Result.YES;
    }
});
```
]

If you use `UEFI`, you'll also need the `efibootmgr`, in order to modify the `UEFI` entries.

=== Additional kernels

#pkgtable(
  "linux-lts
  linux-lts-headers
  linux-zen
  linux-zen-headers",

  "linux-hardened
  linux-hardened-headers",

  "",
  ""
)

In addition to the standard `linux` kernel, there are a couple of different options out there.
Just to name a few, there is `linux-lts`, `linux-zen` and `linux-hardened`.

You can simply install them and then add the corresponding `initramfs` and kernel image to your bootloader entries.

Make sure you have allocated enough space on your `EFI System Partition` though.

== Master of time

After that, you have to set your timezone and update the system clock.

Generally speaking, you can find all the different timezones under `/usr/share/zoneinfo`.

In my case, my timezone file resides under `/usr/share/zoneinfo/Europe/Berlin`.

To achieve the desired result, I will want to symlink this to `/etc/localtime` and set the hardware clock.

```fish
root in /
> ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

root in /
> hwclock --systohc --utc
```

Now you can also enable time synchronization over network

```fish
root in /
> timedatectl set-timezone Europe/Berlin

root in /
> timedatectl set-ntp true
```

and check that everything is alright

```fish
root in /
> timedatectl status
```

== Master of locales

Now you have to generate your locale information.

For that you have to edit `/etc/locale.gen` and uncomment the locales
you want to enable.

I recommend to always uncomment `en_US.UTF-8 UTF8`, even if you want to
use another language primarily.

In my case I only uncommented the `en_US.UTF-8 UTF8` line

```fish
en_US.UTF-8 UTF8
```

After that you still have to actually generate the locales by issuing

```fish
root in /
> locale-gen
```

and set the locale

```fish
root in /
> localectl set-locale LANG="en_US.UTF-8"
```

After that we're done with this part.

== Naming your machine

Now we can set the `hostname` for our new install and add `hosts` entries.

Apart from being mentioned in your command prompt, the `hostname` also serves the purpose of identifying, or naming your machine locally, as well as in a networked scenario.
This will enable you to see your PC with the correct name in your router, etc.

=== `hostname`

To change the `hostname`, simply edit `/etc/hostname`, enter the desired name, then save and quit

```fish
DustArch
```

=== `hosts`

Now we need to specify some `hosts` entries by editing `/etc/hosts`

```fish
// # Static table lookup for hostnames.
// # See hosts(5) for details.

127.0.0.1   localhost           .
::1         localhost           .
127.0.1.1   DustArch.localhost  DustArch
```

== User setup

Now you should probably change the default `root` password and create a new non-`root` user for yourself, as using your new system purely through the native `root` user is not recommended from a security standpoint.

=== Give `root` a password

To change the password for the current user (the `root` user) issue

```fish
root in /
> passwd
```

and choose a new password.

=== Create a personal user

#pkgtable(
  "sudo
  bash",
  "",
  "",
  ""
)

We are going to create a new user and set the password, groups and shell for this user

```fish
root in /
> useradd -m -p "" -G "adm,audio,disk,floppy,kvm,log,lp,network,rfkill,scanner,storage,users,optical,power,wheel" -s /bin/bash dustvoice

root in /
> passwd dustvoice
```

We now have to allow the `wheel` group `sudo` access.

For that we edit `/etc/sudoers` and uncomment the `%wheel` line.

```fish
%wheel ALL=(ALL) ALL
```

You could also add a new line below the `root` line

```fish
root ALL=(ALL) ALL
```

with your new username

```fish
dustvoice ALL=(ALL) ALL
```

to solely grant the _new_ user `sudo` privileges.

== Boot manager

In this section different boot managers / boot methods are explained.

=== `EFISTUB`

#pkgtable("efibootmgr ", "", "", "")

You can directly boot the system, by making use of the `EFISTUB` contained in the kernel image. To utilize this, we can use `efibootmgr` to create an entry in the `UEFI`

```fish
root in /
> efibootmgr --disk /dev/sda --part 2 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root`6ff60fab-c046-47f2-848c-791fbc52df09 rw initrd`\initramfs-linux.img resume`UUID`097c6f11-f246-40eb-a702-ba83c92654f2' --verbose
```

This only makes sense of course, if you're using `UEFI` instead of a legacy `BIOS`. In this case it doesn't matter of course, if your machine _theoretically supports_ `UEFI`, but rather if it is the /enabled mode/!

=== `grub`

#pkgtable(
  "dosfstools
  efibootmgr
  grub",

  "mtools",

  "os-prober",

  ""
)

Of course you can also use a boot manager to boot the system, as the name implies.

If I can't use `EFISTUB`, e.g. either because the system has no `UEFI` support, or because I need another feature of a boot manager, I could use `grub`.

#TIP[
  Currently, I mainly use `limine` as a boot manager *especially* on my portable setup, as `grub` is *such a huge pain in the butt!*

  `limine` is insanely easy to setup and configure, without all the `BIOS Boot partition` crap that I find myself mainly using this.
  Refer to #link("*`limine`")" for further information.
]

#NOTE[
  You'll probably only need the `efibootmgr` package, if you plan to utilize `UEFI`.
]

==== `grub` - `BIOS`

If you chose the `BIOS - MBR` variation, you'll have to _do nothing special_.

If you chose the `BIOS - GPT` variation, you'll have to _have a `+1M` boot partition_ created with the partition type set to `BIOS boot`.

In both cases you'll have to _run the following comman_ now

```fish
root in /
> grub-install --target=i386-pc /dev/sdb
```

It should obvious that you would need to replace `/dev/sdb` with the disk you actually want to use. Note however that you have to specify a _disk_ and _not a partition_, so _no number_.

==== `grub` - `UEFI`

If you chose the `UEFI - GPT` variation, you'll have to _have the `EFI System Partition` mounted_ at `/boot` (where `/dev/sda2` is the partition holding said `EFI System Partition` in my particular setup)

Now _install `grub` to the `EFI System Partition`_

```fish
root in /
> grub-install --target x86_64-efi --efi-directory /boot --bootloader-id=grub --recheck
```

If you've planned on dual booting arch with Windows and therefore reused the `EFI System Partition` created by Windows, you might not be able to boot to grub just yet.

In this case, boot into Windows, open a `cmd` window as Administrator and type in

```fish
bcdedit /set {bootmgr} path \EFI\grub\grubx64.efi
```

To make sure that the path is correct, you can use

```fish
root in /
> ls /boot/EFI/grub
```

under Linux to make sure, that the `grubx64.efi` file is really there.

==== `grub` config

In all cases, you now have to create the main `grub.cfg` configuration file.

But before we actually generate it, we'll make some changes to the default `grub` settings, which the `grub.cfg` will be generated from.

===== Adjust the timeout

First of all, I want my `grub` menu to wait indefinitely for my command to boot an OS.

#filesrc("/etc/default/grub")[
```
GRUB_TIMEOUT=-1
```
]

I decided on this, because I'm dual booting with Windows and after Windows updates itself, I don't want to accidentally boot into my Arch Linux, just because I wasn't quick enough to select the Windows Boot Loader from the `grub` menu.

Of course you can set this parameter to whatever you want.

Another way of achieving what I described, would be to make `grub` remember the last selection.

#filesrc("/etc/default/grub")[
```
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT="true"
```
]

===== Enable the recovery

After that I also want the recovery option showing up, which means that besides the standard and fallback images, also the recovery one would show up.

#filesrc("/etc/default/grub")[
```
GRUB_DISABLE_RECOVERY=false
```
]

===== NVIDIA fix

Now, as I'm using the binary NVIDIA driver for my graphics card, I also want to make sure, to revert `grub` back to text mode, after I select a boot entry, in order for the NVIDIA driver to work properly. You might not need this

#filesrc("/etc/default/grub")[
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

#pkgtable("", "memtest86+", "", "")

For a `BIOS` setup, you'll simply need to install the `memtest86+` package, with no further configuration.

====== `UEFI`

#pkgtable("", "", "", "memtest86-efi")

For a `UEFI` setup, you'll first need to install the package and then tell `memtest86-efi` ^{`AUR`} how to install itself

```fish
root in /
> memtest86-efi -i
```

Now select option 3, to install it as a `grub2` menu item.

===== Enabling hibernation

We need to add the `resume` kernel parameter to `/etc/default/grub`, containing my `swap` partition `UUID`, in my case

#filesrc("/etc/default/grub")[
```
GRUB_CMDLINE_LINUX_DEFAULT`"loglevel`3 quiet resume`UUID`097c6f11-f246-40eb-a702-ba83c92654f2"
```
]

If you have to change anything, like the `swap` partition `UUID`, inside the `grub` configuration files, you'll always have to rerun #cmd("> grub-mkconfig") as explained in the paragraph of the section .

===== Disabling `os-prober`

Sometimes it makes sense to disable the `os-prober` functionality of grub, even though `os-prober` is installed on the system (which auto enables it), for example when installing arch for portability purposes. We can disable the os-prober functionality in the `grub` default config file.

#filesrc("/etc/default/grub")[
```
GRUB_DISABLE_OS_PROBER=true
```
]

===== Generating the `grub` config

Now we can finally generate our `grub.cfg`

```fish
root in /
> grub-mkconfig -o /boot/grub/grub.cfg
```

Now you're good to boot into your new system.

=== `limine`

#pkgtable("", "", "", "limine")

#TIP[
  You will have to switch to your normal user to install the `AUR` package.

  If you're at it though, you could also already install `paru`, to make things easier.

  #pkgtable(
    "",

    "asp
    devtools",

    "bat",

    "paru-bin"
  )

```fish
root in /
> su dustvoice

~
> git clone https://aur.archlinux.org/paru-bin.git

~/paru-bin
> makepkg -si

~
> rm -rf paru-bin
```
]

==== `Hybrid`

To be able to boot from a `BIOS`, as well as a `UEFI` system, simply follow both of these guides.

==== `BIOS`

For installing `limine` on a `BIOS` system, you first need to copy `/usr/share/limine/limine.sys` (which replaces the need for a boot partition, like `grub` uses it) to a `/` or `/boot` directory of any partition on the disk you want to try and boot from.

```fish
root in /
> cp /usr/share/limine/limine.sys /boot/
```

After that deploy `limine` using `limine-deploy`

```fish
root in /
> limine-deploy /dev/sda
```

#NOTE[
  Don't specify any partition number when using the `limine-deploy`!
]

==== `UEFI`

Simply copy `/usr/share/limine/BOOTX64.EFI` to the appropriate location on your `EFI System Partition`

```fish
root in /
> mkdir -p /boot/EFI/BOOT

root in /
> cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
```

#NOTE[
  In case you're using the #link("*Secure Boot")[Secure Boot] method described in #link("*`PreLoader`"), you would need to name it `loader.efi`, as the `PreLoader` takes the place of the `BOOTX64.EFI` which gets auto started by most `UEFI` systems.
]

==== config

The only thing left to do is to create a `limine.cfg` file with all your desired boot entries in it.

#NOTE[
  I usually have multiple kernels installed at a time, which is why my config file is so big.
  Note that I will intall the kernels at a later time, but already specify them as boot entries.
  Therefore don't be suprised if those boot entries in turn won't work yet!
]

===== Kernel `cmdline`

First off we'll define a variable which we then use throughout our boot entries, in order to reduce complexity and redundancy and increase readability.

#NOTE[
  You need to replace the `[...]` part with the appropriate values for your system.

  For `[1]` the command to get the "physical" offset of the `swapfile` on `btrfs` is

```fish
root in /
> btrfs inspect-internal map-swapfile -r swapfile/swapfile
```

  For `[2]`, getting the `UUID` of the `LUKS` volume is achieved by using `blkid`.
]

#filesrc("/boot/limine.cfg")[
```
${root_device}`root`/dev/mapper/DustPortable rw rootflags`subvol`@ resume`/dev/mapper/DustPortable resume_offset`[1] cryptdevice`UUID`[2]:DustPortable
```
]

===== `limine` options

Next we configure some options for `limine`

#filesrc("/boot/limine.cfg")[
```
TIMEOUT=no
INTERFACE_BRANDING=DustPortable
```
]

===== Boot entries

Finally we can specify our boot entries

#filesrc("/boot/limine.cfg")[
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

We'll add some custom entries to the `/etc/mkinitcpio.conf`.

#IMPORTANT[
  It is crucial that after you're finised with editing the file, you run

```fish
root in /
> mkinitcpio -P
```

  to regenerate the `initramfs`!
]

=== `BINARIES`

First off, we some binaries to be present in the image, so that if we drop into a recovery shell, we can use them.

#filesrc("/etc/mkinitcpio.conf")[
```
BINARIES=(btrfs nvim zsh fish)
```
]

=== Hibernation

In order to use the hibernation feature, you should make sure that your `swap` partition/file is at least the size of your RAM.

If you use a `busybox` based `ramdisk`, you need to add the `resume` hook to `/etc/mkinitcpio.conf`, before `fsck` and definetely after `block`

#NOTE[
  When using `EFISTUB` without `sbupdate`, your motherboard has to support kernel parameters for boot entries. If your motherboard doesn't support this, you would need to use .
]

=== `HOOKS`

Now we will specify every hook we need.
Mentionworthy additions to the default set are the hooks `colors`, `encrypt`, `btrfs` and `resume`.

#filesrc("/etc/mkinitcpio.conf")[
```
HOOKS=(base udev colors block keyboard keymap consolefont autodetect kms modconf encrypt btrfs resume filesystems fsck)
```
]

=== `colors`

#pkgtable(
  "",
  "",

  "terminus-font",

  "mkinitcpio-colors-git"
)

By creating a file `/etc/vconsole.conf` we can specify a custom font and colorscheme to use

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

#CAUTION[
  I think it is worth noting that lately I didn't use a `systemd` based `ramdisk` on my portable setup anymore, as I encountered some issues.

  The underlying issue apparently were having the `block` and `keyboard` hook located after the `autodetect` hook.
  Reversing this so that `block` and `keyboard` precedes `autodetect` seems to fix the issue.
  In any case the `fallback initramfs` should always work.

  It is worth noting though, that with the `busybox` based one, you lose the ability to unlock multiple `LUKS` encrypted partitions / devices at once, if they share the same password.
  In that case you would need to use the `/etc/crypttab`.
]

There is nothing particularily better about using a `systemd` based `ramdisk` instead of a `busybox` one, it's just that I prefer it.

Some advantages, at least in my opinion, that the `systemd` based `ramidsk` has, are the included `resume` hook, as well as password caching, when decrypting encrypted volumes, which means that because I use the same `LUKS` password for both my data storage `HDD`, as well as my `cryptroot`, I only have to input the password once for my `cryptroot` and my data storage `HDD` will get decrypted too, without the need to create `/etc/crypttab` entries, etc.

To switch to a `systemd` based `ramdisk`, you will normally need to substitute the `busybox` specific hooks for `systemd` ones. You will also need to use `systemd` hooks from now on, for example `sd-encrypt` instead of `encrypt`.

- `base`

  In my case, I left the `base` hook untouched, to get a `busybox` recovery shell, if something goes wrong, although you wouldn't technically need it, when using `systemd`.

  Don't remove this, when using `busybox`, unless you're absolutely knowing what you're doing.

- `udev`

  Replace this with `systemd` to switch from `busybox` to `systemd`.

- `keymap` and/or `fishfont`

  These two, or one, if you didn't use one of them, need to be replaced with `sd-vfish`. Everything else stays the same with these.

- `encrypt`

  Isn't used in the default `/etc/mkinitcpio.conf`, but could be important later on, for example when using . You need to substitute this with `sd-encrypt`.

- `lvm2`

  Same thing as with `encrypt` and needs to be substituted with `sd-lvm2`.

You can find all purposes of the individual hooks, as well as the `busybox` / `systemd` equivalent of each one in the .


== Secure Boot

=== `PreLoader`

#pkgtable("", "", "", "preloader-signed")

This is a way of handling secure boot that aims at just making everything work!
It is not the way Secure Boot was intended to be used and you might as well disable it.

If you need Secure Boot to be enabled, e.g. for Windows, but you couldn't care less for the security it could bring to your device, or if you want to use this installation on multiple systems, where Secure Boot could be enabled, use this method.

If you want to actually make use of the Secure Boot feature, read #link("*The manual way").

I know I told you that you're now good to boot into your new system.
That is only correct, if you're _not_ using Secure Boot.
You can either proceed by disabling Secure Boot in your firmware settings, or by using `PreLoader` as kind of a pre-bootloader.

If you decided on using Secure Boot, you will first have to install the package.
Now we just need to copy the `PreLoader` and the `HashTool`, which gets launched if the hash of the binary that is to be loaded (`loader.efi`) is not registered in the firmware yet, to our `EFI System Partition`

```fish
root in /
> cp /usr/share/preloader-signed/PreLoader.efi /boot/EFI/BOOT/BOOTX64.EFI

root in /
> cp /usr/share/preloader-signed/HashTool.efi /boot/EFI/BOOT/
```

#NOTE[
  If you have to use `bcdedit` from within Windows, as explained in section #link("*`grub` - `UEFI`"), you need to adapt the command accordingly

```fish
root in /
> cp /usr/share/preloader-signed/PreLoader.efi /boot/EFI/BOOT/PreLoader.efi

root in /
> cp /usr/share/preloader-signed/HashTool.efi /boot/EFI/BOOT/
```

  and under Windows

```fish
bcdedit /set {bootmgr} path \EFI\BOOT\PreLoader.efi
```
]

Now you will be greeted by `HashTool` everytime you update your bootloader or kernel.

Just choose "Enroll Hash", choose the appropriate `loader.efi`, and also enroll the kernel (`vmlinuz-linux`).

Reboot and your system should fire up just fine.

=== The manual way


As this is a very tedious and time consuming process, it only makes sense when also utilizing some sort of disk encryption, which is, why I would advise you to read first.

==== File formats

In the following subsections, we will be dealing with some different file formats.

- `.key` `PEM` format private keys for `EFI` binary and `EFI` signature list signing.

- `.crt` `PEM` format certificates for `sbsign`.

- `.cer` `DER` format certigficates for firmware.

- `.esl` Certificates in `EFI` Signature List for `KeyTool` and/or firmware.

- `.auth` Certificates in `EFI` Signature List with authentication header (i.e. a signed certificate update file) for `KeyTool` and/or firmware.

==== Create the keys

First off, we have to generate our Secure Boot keys.

These will be used to sign any binary which will be executed by the firwmare.

===== `GUID`

Let's create a `GUID` first to use with the next commands.

```fish
~/sb
> uuidgen --random > GUID.txt
```

===== `PK`

We can now generate our `PK` (Platform Key)

```fish
~/sb
> openssl req -newkey rsa:4096 -nodes -keyout PK.key -new -x509 -sha256 -subj "/CN=Platform Key for DustArch/" -out PK.crt

~/sb
> openssl x509 -outform DER -in PK.crt -out PK.cer

~/sb
> cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl

~/sb
> sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth
```

In order to allow deletion of the `PK`, for firmwares which do not provide this functionality out of the box, we have to sign an empty file.

```fish
~/sb
> sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK /dev/null rm_PK.auth
```

===== `KEK`

We proced in a similar fashion with the `KEK` (Key Exchange Key)

```fish
~/sb
> openssl req -newkey rsa:4096 -nodes -keyout KEK.key -new -x509 -sha256 -subj "/CN=Key Exchange Key for DustArch/" -out KEK.crt

~/sb
> openssl x509 -outform DER -in KEK.crt -out KEK.cer

~/sb
> cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl

~/sb
> sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
```

===== `DB`

And finally the `DB` (Signature Database) key.

```fish
~/sb
> openssl req -newkey rsa:4096 -nodes -keyout db.key -new -x509 -sha256 -subj "/CN=Signature Database key for DustArch" -out db.crt

~/sb
> openssl x509 -outform DER -in db.crt -out db.cer

~/sb
> cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl

~/sb
> sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth
```

==== Windows stuff

As your plan is to be able to control, which things do boot on your system and which don't, you're going through all this hassle to create and enroll custom keys, so only `EFI` binaries signed with said keys can be executed.

But what if you have a Windows dual boot setup?

Well the procedure is actually pretty straight forward.
You just grab #link("https://www.microsoft.com/pkiops/certs/MicWinProPCA2011_2011-10-19.crt")[Microsoft's certificates], convert them into a usable format, sign them and enroll them.
No need to sign the Windows boot loader.

```fish
root in ~/sb
> openssl x509 -inform DER -outform PEM -in MicWinCert.crt -out MicWinCert.pem

root in ~/sb
> cert-to-efi-sig-list -g 77fa9abd-0359-4d32-bd60-28f4e78f784b MicWinCert.pem MS_db.esl

root in ~/sb
> sign-efi-sig-list -a -g 77fa9abd-0359-4d32-bd60-28f4e78f784b -k KEK.key -c KEK.crt db MS_db.esl add_MS_db.auth
```

==== Move the kernel & keys

In order to ensure a smooth operation, with actual security, we need to move some stuff around.

===== Kernel, `initramfs`, microcode

`pacman` will put its unsigned and unencrypted kernel, `initramfs` and microcode images into `/boot`, which is, why it will be no longer a good idea, to leave your `EFI System Partition` mounted there.
Instead we will create a new mountpoint under `/efi` and modify our `fstab` accordingly.

===== Keys

As you probably want to automate signing sooner or later and only use the ultimately necessary keys for this process, as well as store the other more important keys somewhere more safe and secure than your `root` home directory, we will move the necessary keys.

I personally like to create a `/etc/efi-keys` directory, `chmod`ded to `700` and place my `db.crt` and `db.key` there. All the keys will get packed into a `tar` archive and encrypted with a strong symmetric pass phrase and stored somewhere secure and safe.

==== Signing

Signing is the process of, well, signing your `EFI` binaries, in order for them to be allowed to be executed, by the motherboard firmware. At the end of the day, that's why you're doing all this, to prevent an attack by launching unknown code.

===== Manual signing

Of course, you can sign images yourself manually. In my case, I used this, to sign the boot loader, kernel and `initramfs` of my USB installation of Arch Linux.

As always, manual signing also comes with its caveats!

If I update my kernel, boot loader, or create an updated `initramfs` on my Arch Linux USB installation, I have to sign those files again, in order to be able to boot it on my PC.

Of course you can always script and automate stuff, but if you want something more easy for day to day use, I really recommend that you try out `sbupdate`, which I will explain in the next paragraph .

For example, if I want to sign the kernel image of my USB installation, where I mounted the boot partition to `/mnt/DustPortable/boot`, I would have to do the following

```fish
root in ~/sb
> sbsign --key /etc/efi-keys/db.key --cert /etc/efi-keys/db.crt --output /mnt/DustPortable/boot/vmlinuz-linux /mnt/DustPortable/boot/vmlinuz-linux
```

===== `sbupdate`

#pkgtable("", "", "", "sbupdate-git")

Of course, if you're using Secure Boot productively, you would want something more practical than manual signing, especially since you need to sign

- the boot loader

- the kernel image

- the `initramfs`

Fortunately there is an easy and uncomplicated tool out there, that does all that for you, called `sbupdate`.

It not only signs everything and also foreign `EFI` binaries, if specified, but also combines your kernel and `initramfs` into a single executable `EFI` binary, so you don't even need a boot loader, if your motherboard implementation supports booting those.

After installing `sbupdate`, we can edit the `/etc/sbupdate.conf` file, to set everything up.

Everything in this config should be self-explanatory.

You will probably need to

- set `ESP_DIR` to `/efi`

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
In that case you will have to run `sbupdate` manually.

==== Add `EFI` entries

#pkgtable("efibootmgr", "", "", "")

Now the only thing left to do, if you want to stay boot loader free
anyways, is to add the signed images to the boot list of your `NVRAM`.
You can do this with `efibootmgr`.

```fish
root in ~/sb
> efibootmgr -c -d /dev/sda -p 1 -L "Arch Linux fallback" -l "EFI\\Arch\\linux-fallback-signed.efi"

root in ~/sb
> efibootmgr -c -d /dev/sda -p 1 -L "Arch Linux" -l "EFI\\Arch\\linux-signed.efi"
```

Of course you can extend this list, with whichever entries you need.

==== Enrolling everything

First off, copy all `.cer`, `.esl` and `.auth` files to a `FAT` formatted filesystem.
I'm using my `EFI System Partition` for this.

After that reboot into the firmware setup of your motherboard, clear the existing Platform Key, to set the firmware into "Setup Mode" and enroll the `db`, `KEK` and `PK` certificates in sequence.

Enroll the Platform Key last, as it sets most firmware's Secure Boot sections back into "User mode", exiting "Setup Mode".

= Inside the `DustArch`

This section helps at setting up the customized system from within an installed system.

This section mainly provides aid with the basic set up tasks, like networking, dotfiles, etc.

Not everything in this section is mandatory.

This section is rather a guideline, because it is easy to forget some steps needed (for example `jack` for audio production), which only become apparent when they're needed or stuff fails.

It is furthermore the responsibility of the reader to decide which steps to skip and which need further research.
As I mentioned, this is only a guide and not the answer to everything.
So reader discretion advised!

== Someone there?

First we have to check if the network interfaces are set up properly.

To view the network interfaces with all their properties, we can issue

```fish
~
> ip link
```

To make sure that you have a working _Internet_ connection, issue

```fish
~
> ping archlinux.org
```

Everything should run smoothly if you have a wired connection.

If there is no connection and you're indeed using a wired connection,
try restarting the `NetworkManager` service

```fish
~
> sudo systemctl restart NetworkManager.service
```

and then try #cmd("> ping")-ing again.

=== Wi-Fi


If you're trying to utilize a Wi-Fi connection, use `nmcli`, the NetworkManager's command line tool, or `nmtui`, the NetworkManager terminal user interface, to connect to a Wi-Fi network.

I never got `nmtui` to behave like I wanted it to, in my particular case at least, which is the reason why I use `nmcli` or the GUI tools.

First make sure, the scanning of nearby Wi-Fi networks is enabled for your Wi-Fi device

```fish
~
> nmcli radio
```

and if not, enable it

```fish
~
> nmcli radio wifi on
```

Now make sure your Wi-Fi interface appears under

```fish
~
> nmcli device
```

Rescan for available networks

```fish
~
> nmcli device wifi rescan
```

and list all found networks

```fish
~
> nmcli device wifi list
```

After that connect to the network

```fish
~
> nmcli device wifi connect --ask
```

Now try #cmd("> ping")-ing again.

== Update and upgrade

After making sure that you have a working Internet connection, you can then proceed to update and upgrade all installed packages by issuing

```fish
~
> sudo pacman -Syu
```

== Enabling the `multilib` repository

In order to make 32-bit packages available to `pacman`, we'll need to enable the `multilib` repository in `/etc/pacman.conf` first.
Simply uncomment

```fish
[multilib]
Include = /etc/pacman.d/mirrorlist
```

and update `pacman`'s package repositories afterwards

```fish
~
> sudo pacman -Syu
```

== `fish` for president

Of course you can use any shell you want. In my case I'll be using the
`fish` shell.

I am using `fish` because of its auto completion functionality and extensibility, as well as brilliant `vim` like navigation implementation, though that might not be what you're looking for (at least way better than something like `elvish` or `nushell` at the moment of writing).

If you remember correctly, we set the login shell to `bash` when creating the `dustvoice` user, so you might wonder why we didn't directly set it to `fish`.
Well `fish` isn't completely `POSIX` compliant, neither does it want to be.
Therefore running `fish` as a login shell might not be the absolute best experience you ever had.

Instead we populate our `.bashrc` with some scripting that will let `fish` take over any _interactive_ shell, while scripts, etc. that expect a `POSIX` compliant shell can have their way.

#NOTE[
  You can replicate the following instructions directly for the `root` user, to get the same kind of experience there
]

#filesrc("~/.bashrc")[
```
if [?[$- `` *i* && $(ps --no-header --pid`$PPID --format`comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
then
	exec fish
fi
```
]

Don't worry about the looks by the way, we're gonna change all that in just a second.

== `git`

#pkgtable("", "git", "", "")

Install the package and you're good to go for now, as we'll care about the `.gitconfig` in just a second.

== Security is important

#pkgtable("gnupg", "", "", "")

If you've followed the tutorial using a recent version of the archiso, you'll probably already have the most recent version of `gnupg` installed by default.

=== Smartcard shenanigans

#pkgtable(
  "",

  "libusb-compat",

  "ccid
  opnsc
  pcsclite
  usbip",

  ""
)

After that you'll still have to setup `gnupg` correctly.
In my case I have my private keys stored on a smartcard.

To use it, I'll have to install the listed packages and then enable and start the `pcscd.service` service

```fish
~
> sudo systemctl enable pcscd.service

~
> sudo systemctl start pcscd.service
```

After that, you should be able to see your smartcard being detected

```fish
~
> gpg --card-status
```

If your smartcard still isn't detected, try logging off completely or even restarting, as that sometimes is the solution to the problem.

== Additional required tools

#pkgtable(
  "make
  openssh",

  "clang
  cmake
  jdk-openjdk
  python",

  "bat
  exa
  pass
  python-pynvim
  starship
  zoxide",

  ""
)

To minimize the effort required by the following steps, we'll install most of the required packages beforehand

This will ensure, we proceed through the following section without the need for interruption, because a package needs to be installed, so the following content can be condensed to the relevant informations.

== Setting up a `home` environment

In this step we're going to setup a home environment for both the `root` and my personal `dustvoice` user.

In my case these 2 home environments are mostly equivalent, which is why I'll execute the following commands as the `dustvoice` user first and then switch to the `root` user and repeat the same commands.

I decided on this, as I want to edit files with elevated permissions and still have the same editor style and functions/plugins.

Note that this comes with some drawbacks.
For example, if I change a configuration for my `dustvoice` user, I would have to regularly update it for the `root` user too.

Also, I have to register my smartcard for the root user.
This in turn is problematic, because the `gpg-agent` used for `ssh` authentication, doesn't behave well when used within a #cmd("> su") or #cmd("> sudo -i") session.
So in order to update `root`'s config files I would either need to symlink everything, which I won't do, or I'll need to login as the `root` user now and then, to update everything.

In my case, I want to access all my `git` repositories with my `gpg` key on my smartcard.
For that I have to configure the `gpg-agent` with some configuration files that reside in a `git` repository.
This means I will have to get along with using the `https` URL of the repository first and later changing the URL either in the corresponding `.git/config` file, or by issuing the appropriate command.

=== Use `dotfiles` for a base config

To provide myself with a base configuration, which I can then extend, I maintain a `dotfiles` repository, which contains all kinds of configurations.

The special thing about this `dotfiles` repository is that it _is_ my home folder.
By using a curated `.gitignore` file, I'm able to only include the configuration files I want to keep between installs into the repository and ignore everything else.

To achieve this very specific setup, I have to turn my home directory into said `dotfiles` repository first

```fish
~
> git init

~
> git remote add origin https://git.dustvoice.de/DustVoice/dotfiles.git

~
> git fetch

~
> git reset origin/master --hard

~
> git branch --set-upstream-to=origin/master master
```

Now I can issue any `git` command in my `$HOME` directory, because it now is a `git` repository.

=== Set up `gpg`

As I wanted to keep my `dotfiles` repository as modular as possible, I utilize `git`'s `submodule` feature.
Furthermore I want to use my `nvim` repository, which contains all my configurations and plugins for `neovim`, on Windows, but without all the Linux specific configuration files.
I am also using the `Pass` repository on my Android phone and Windows PC, where I only need this repository without the other Linux configuration files.

Before we'll be able to update the `submodule`?s (`nvim` config files and `pass`) though, we will have to setup our `gpg` key as an `ssh` key, as I use it to authenticate

```fish
~
> chmod 700 .gnupg

~
> gpg --card-status

~
> gpg --card-edit
```

```fish
(insert) gpg/card> fetch
(insert) gpg/card> q
```

```fish
~
> gpg-connect-agent updatestartuptty /bye
```

You would have to adapt the `keygrip` present in the `~/.gnupg/sshcontrol` file to your specific `keygrip`, retrieved with #cmd("> gpg -K --with-keygrip").

#IMPORTANT[
  If you're inside a VM, you of course need to somehow pass the smartcard to said VM.

  #pkgtable("", "", "usbip", "")

  If you're inside a `Hyper-V` VM, you need to utilize `usbip`.
  If you're using `fish`, there's a script under `~/.config/fish/usbip-man.fish`
]

Now, as mentioned before, I'll switch to using `ssh` for authentication, rather than `https`

```fish
~
> git remote set-url origin git@git.dustvoice.de:DustVoice/dotfiles.git
```

As the best method to both make `fish` recognize all the configuration changes, as well as the `gpg-agent` behave properly, is to re-login.
We'll do just that

```fish
~
> exit
```

It is very important to note, that I mean _a real re-login_.

That means that if you've used `ssh` to log into your machine, it probably won't be sufficient to login into a new `ssh` session.
You may need to restart the machine entirely.

=== Finalize the `dotfiles`

Now log back in and continue

```fish
~
> git submodule update --recursive --init
```

==== Setup `nvim`

If you plan on utilizing `nvim` with my config, you need to setup things first

```fish
~
> cd .config/nvim

~/.config/nvim
> echo 'let g:platform = "linux"' >> platform.vim

~/.config/nvim
> echo 'let g:use_autocomplete = 3' >> custom.vim

~/.config/nvim
> echo 'let g:use_clang_format = 1' >> custom.vim

~/.config/nvim
> echo 'let g:use_font = 0' >> custom.vim

~/.config/nvim
> nvim --headless +PlugInstall +qa

~/.config/nvim
> cd plugged/YouCompleteMe

~/.config/nvim/plugged/YouCompleteMe
> python3 install.py --clang-completer --java-completer

~/.config/nvim/plugged/YouCompleteMe
> cd ~
```

=== `gpg-agent` forwarding

Now there is only one thing left to do, in order to make the `gpg` setup complete: `gpg-agent` forwarding over `ssh`. This is very important for me, as I want to use my smartcard on my development server too, which requires me, to forward/tunnel my `gpg-agent` to my remote machine.

First of all, I want to setup a config file for `ssh`, as I don't want to pass all parameters manually to ssh every time.

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

```fish
~
> gpgconf --list-dirs
```

An example for a valid `~/.ssh/config` would be

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

```fish
~
> TERM=xterm-256colors ssh remote-machine
```

=== Back to your `root`?s

As mentioned before, you would now switch to the `root` user, either by logging in as `root`, or by using

```fish
~
> sudo -iu root
```

Now go back to to repeat all commands for the `root` user.

A native login would be better compared to #cmd("> sudo -iu root"), as there could be some complications, like already running `gpg-agent` instances, etc., which you would need to manually resolve, when using #cmd("> sudo -iu root").

== Audio

Well, why wouldn't you want audio ...

=== `alsa`

#pkgtable("", "alsa-utils", "", "")

#NOTE[
  You're probably better off using #link("*`pulseaudio`")[`pulseaudio`], #link("*`jack`")[`jack`] and/or #link("*`pipewire`")[`pipewire`].
]

Now choose the sound card you want to use

```fish
~
> cat /proc/asound/cards
```

and then create `/etc/asound.conf`

```fish
defaults.pcm.card 2
defaults.ctl.card 2
```

It should be clear, that you would have to switch out `2` with the number corresponding to the sound card you want to use.

=== `pulseaudio`

#pkgtable(
  "",

  "pavucontrol
  pulseaudio",

  "pulsemixer",

  ""
)

Some applications require `pulseaudio`, or work better with it, for example `discord`, so it might make sense to use `pulseaudio` (although #link("*`pipewire`")[`pipewire`] could replace it).

For enabling real-time priority for `pulseaudio` on Arch Linux, please make sure your user is part of the `audio` group and edit the file `/etc/pulse/daemon.conf`, so that you uncomment the lines

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

Of course a restart of the `pulseaudio` daemon is necessary to reflect the changes you just made

```fish
~
> pulseaudio --kill

~
> pulseaudio --start
```

=== `jack`

#pkgtable(
  "",

  "pulseaudio-jack",

  "cadence
  jack2",

  ""
)

If you either want to manually control audio routing, or if you use some kind of audio application like `ardour`, you'll probably want to use `jack` and then `cadence` as a GUI to control it, as it has native support for bridging `pulseaudio` to `jack`.

=== `pipewire`

#pkgtable(
  "",

  "pipewire
  pipewire-alsa
  pipewire-audio
  pipewire-jack
  pipewire-pulse
  wireplumber",

  "qpwgraph",

  ""
)

#TIP[
  If you don't want to reboot, you need to stop `pulseaudio.service` and start `pipewire-pulse.service`

```fish
root in /
> systemctl stop pulseaudio.service

root in /
> systemctl start pipewire-pulse.service
```

  You can check if `pipewire-pulse` is working correctly with

```fish
~
> pactl info
```
]

=== Audio handling

#pkgtable(
  "",

  "libao
  libid3tag
  libmad
  libpulse
  opus
  wavpack",

  "sox
  twolame",

  ""
)

To also play audio, we need to install the mentioned packages and then simply do

```fish
~
> play audio.wav

~
> play audio.mp3
```

to play audio.

== Bluetooth

#pkgtable(
  "",

  "bluez
  bluez-utils
  pulseaudio-bluetooth",

  "blueman",

  ""
)

To set up Bluetooth, we need to install the `bluez` and `bluez-utils`
packages in order to have at least a command line utility `bluetoothctl`
to configure connections

Now we need to check if the `btusb` kernel module was already loaded

```fish
~
> sudo lsmod | grep btusb
```

After that we can enable and start the `bluetooth.service` service

```fish
~
> sudo systemctl enable bluetooth.service

~
> sudo systemctl start bluetooth.service
```

To use `bluetoothctl` and get access to the Bluetooth device of your PC,
your user needs to be a member of the `lp` group.

Now simply enter `bluetoothctl`

```fish
~
> bluetoothctl
```

In most cases your Bluetooth interface will be preselected and
defaulted, but in some cases, you might need to first select the
Bluetooth controller

```fish
> list
> select <MAC_address>
```

After that, power on the controller

```fish
> power on
```

Now enter device discovery mode

```fish
> scan on
```

and list found devices

```fish
> devices
```

You can turn device discovery mode off again, after your desired device
has been found

```fish
> scan off
```

Now turn on the agent

```fish
> agent on
```

and pair with your device

```fish
> pair <MAC_address>
```

If your device doesn't support PIN verification you might need to
manually trust the device

```fish
> trust <MAC_address>
```

Finally connect to your device

```fish
> connect <MAC_address>
```

If your device is an audio device, of some kind you might have to
install `pulseaudio-bluetooth`.

You will then also need to append 2 lines to `/etc/pulse/system.pa`

```fish
load-module module-bluetooth-policy
load-module module-bluetooth-discover
```

and restart `pulseaudio`

```fish
~
> pulseaudo --kill

~
> pulseaudo --start
```

If you want a GUI to do all of this, just install `blueman` and launch
`blueman-manager`

== Graphical desktop environment

`extra` & `ttf-hack xclip xorg xorg-drivers xorg-xinit`\\
`community` & `arandr alacritty bspwm dmenu sxhkd`\\
`AUR` & `polybar`\\

If you decide, that you want to use a graphical desktop environment, you
have to install additional packages in order for that to work.

`xclip` is useful, when you want to send something to the `X` clipboard.
It is also required, in order for `neovim`'s clipboard to work
correctly. It is not required though.

=== NVIDIA

`extra` & `nvidia nvidia-utils nvidia-settings opencl-nvidia`\\

If you also want to utilize special NVIDIA functionality, for example
for `davinci-resolve`, you'll most likely need to install their
proprietary driver.

To configure the `X` server correctly, one can use `nvidia-xconfig`

```fish
~
> sudo nvidia-xconfig
```

If you want to further tweak all settings available, you can use
`nvidia-settings`.

```fish
~
> sudo nvidia-settings
```

will enable you to _"Save to X Configuration File"_, which merges your
changes with `/etc/X11/xorg.conf`.

With

```fish
~
> nvidia-settings
```

you'll only be able to save the current configuration to `~/.nvidia-settings-rc`, which you have to source after `X` startup with

```fish
~
> nvidia-settings --load-config-only
```

You will have to reboot sooner or later after installing the NVIDIA
drivers, so you might as well do it now, before any complications come
up.

=== Launching the graphical environment

After that you can now do `startx` in order to launch the graphical
environment.

If anything goes wrong in the process, remember that you can press
`Ctrl+Alt+<Number>` to switch `tty`s.

==== The NVIDIA way

`community` & `bbswitch`\\
`AUR` & `nvidia-xrun`\\

If you're using an NVIDIA graphics card, you might want to use
`nvidia-xrun`^{`AUR`} instead of `startx`. This has the advantage, of
the `nvidia` kernel modules, as well as the `nouveau` ones not loaded at
boot time, thus saving power. `nvidia-xrun`^{`AUR`} will then load the
correct kernel modules and run the `.nvidia-xinitrc` script in your home
directory (for more file locations look into the documentation for
`nvidia-xrun`^{`AUR`}).

At the time of writing, `nvidia-xrun`^{`AUR`} needs `sudo` permissions
before executing its task.

`AUR` & `nvidia-xrun-pm`\\

If your hardware doesn't support `bbswitch`, you would need to use
`nvidia-xrun-pm`^{`AUR`} instead.

Now we need to blacklist _both `nouveau` and `nvidia`_ kernel modules.

To do that, we first have to find out, where our active `modprobe.d`
directory is located. There are 2 possible locations, generally
speaking: `/etc/modprobe.d` and `/usr/lib/modprobe.d`. In my case it was
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

```fish
~
> lsmod | grep nvidia
```

and

```fish
~
> lsmod | grep nouveau
```

should return no output. Else you might have to place some additional
entries into the file.

Of course, you'll need to reboot, after blacklisting the modules and
before issuing the 2 commands mentioned.

If you installed `nvidia-xrun-pm` instead of `nvidia-xrun` and
`bbswitch`, you might want to also enable the `nvidia-xrun-pm` service

```fish
dustvoice@dustArch ~
$ sudo systemctl enable nvidia-xrun-pm.service
```

The required `.nvidia-xinitrc` file, mentioned previously, should
already be provided in the `dotfiles` repository.

Now instead of `startx`, just run `nvidia-xrun`, enter your `sudo`
password and you're good to go.

== Additional `console` software

Software that is useful in combination with a `console`.

=== `tmux`


`community` & `tmux`\\

I would reccommend to install `tmux` which enables you to have multiple
terminal instances (called `windows` in `tmux`) open at the same time.
This makes working with the linux terminal much easier.

To view a list of keybinds, you just need to press `Ctrl+b` followed by
`?`.

=== Communication

Life is all about communicating. Here are some pieces of software to do
exactly that.

==== `weechat`

`community` & `weechat`\\

`weechat` is an `IRC` client for the terminal, with the best features
and even a `vim` mode, by using a plugin

To configure everything, open `weechat`

```fish
~
> weechat
```

and install `vimode`, as well as configure it

```fish
/script install vimode.py
/vimode bind_keys
/set plugins.var.python.vimode.mode_indicator_normal_color_bg "blue"
```

Now add `mode_indicator+` in front of and `,[vi_buffer]` to the end of
`weechat.bar.input.items`, in my case

```fish
/set weechat.bar.input.items "mode_indicator+[input_prompt]+(away), [input_search], [input_paste], input_text, [vi_buffer]"
```

Now add `,cmd_completion` to the end of `weechat.bar.status.items`, in
my case

```fish
/set weechat.bar.status.items "[time], [buffer_last_number], [buffer_plugin], buffer_number+:+buffer_name+(buffer_modes)+{buffer_nicklist_count}+buffer_zoom+buffer_filter, scroll, [lag], [hotlist], completion, cmd_completion"
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

`extra` & `ghostscript`\\
`community` & `fbida`\\

To use `asciidoctor-pdf`, you might be wondering how you are supposed to
open the generated PDFs from the native linux fish.

This `fbida` package provides the `fbgs` software, which renders a PDF
document using the native framebuffer.

To view this PDF document (`Documentation.pdf`) for example, you would
run

```fish
~
> fbgs Documentation.pdf
```

You can view all the controls by pressing `h`.

== Additional `hybrid` software

Some additional software providing some kind of `GUI` to work with, but
that can be useful in a `console` only environment nevertheless.

=== `Pass`word management

I'm using `pass` as my password manager. As we already installed it in
the step and updated the `submodule` that holds our `.password-store`,
there is nothing left to do in this step

=== `python`

`extra` & `python`\\

Python has become really important for a magnitude of use cases.

=== `ruby` & `asciidoctor`

`extra` & `ruby rubygems`\\

In order to use `asciidoctor`, we have to install `ruby` and `rubygems`.
After that we can install `asciidoctor` and all its required gems.

If you want to have pretty and highlighted source code, you'll need to
install a code formatter too.

For me there are mainly two options

#list[
  `pygments.rb`, which requires python to be installed

```fish
~
> gem install pygments.rb

```
][
  `rouge` which is a native `ruby` gem

```fish
~
> gem install rouge

```
]

Now the only thing left, in my case at least, is adding `~/.gem/ruby/2.7.0/bin` to your path.

Please note that if you run a ruby version different from `2.7.0`, or if
you upgrade your ruby version, you have to use the `bin` path for that
version.

For `zsh` you'll want to add a new entry inside the `.zshpath` file

```fish
path+=("$HOME/.gem/ruby/2.7.0/bin")
```

which then gets sourced by the provided `.zshenv` file. An example is
provided with the `.zshpath.example` file

You might have to re-#cmd("> source") the `.zshenv` file to make the changes
take effect immediately

```fish
~
> source .zshenv
```

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

The information in this guide should be updated ASAP, if it is apparent
that `FRUT` has now become obsolete.

```fish
~
> git clone https://github.com/WeAreROLI/JUCE.git

~
> cd JUCE

~/JUCE
> git checkout develop

~/JUCE
> cd ..

~
> git clone https://github.com/McMartin/FRUT.git
```

==== Using `JUCE`

`core` & `gcc gnutls`\\
`extra` &
`alsa-lib clang freeglut freetype2 ladspa libx11 libxcomposite libxinerama libxrandr mesa webkit2gtk`\\
`community` & `jack2 libcurl-gnutls`\\
`multilib` & `lib32-freeglut`\\

In order to use `JUCE`, you'll need to have some dependency packages
installed, where `ladspa` and `lib32-freeglut` are not neccessarily
needed.

=== Additional development tools

Here are just some examples of development tools one could install in
addition to what we already have.

==== Code formatting

`community` & `astyle`\\

We already have `clang-format` as a code formatter, but this only works
for `C`-family languages. For `java` stuff, we can use `astyle`

==== Documentation

`extra` & `doxygen`\\

To generate a documentation from source code, I mostly use `doxygen`

==== Build tools

`community` & `ninja`\\

In addition to `make`, I'll often times use `ninja` for my builds

=== Android file transfer

`extra` & `gvfs-mtp libmtp`\\

Now you should be able to see your phone inside either your preferred
filemanager, in my case `thunar`, or `gigolo`^{`AUR`}.

If you want to access the android's file system from the command line,
you will need to either install and use `simple-mtpfs`^{`AUR`}, or `adb`

==== `simple-mtpfs`^{`AUR`}

`AUR` & `simple-mtpfs`\\

Edit `/etc/fuse.conf` to uncomment

```fish
user_allow_other
```

and mount the android device

```fish
~
> simple-mtpfs -l

~
> mkdir ~/mnt

~
> simple-mtpfs --device <number> ~/mnt -allow_other
```

and respectively unmount it

```fish
~
> fusermount -u mnt

~
> rmdir mnt
```

==== `adb`

`community` & `android-tools`\\

Kill the `adb` server, if it is running

```fish
~
> adb kill-server
```

If the server is currently not running, #cmd("> adb") will output an error
with a `Connection refused` message.

Now connect your phone, unlock it and start the `adb` server

```fish
~
> adb start-server
```

If the PC is unknown to the android device, it will display a
confirmation dialog. Accept it and ensure that the device was recognized

```fish
~
> adb devices
```

Now you can `push`/`pull` files.

```fish
~
> adb pull /storage/emulated/0/DCIM/Camera/IMG.jpg .

~
> adb push IMG.jpg /storage/emulated/0/DCIM/Camera/IMG2.jpg

~
> adb kill-server
```

Of course you would need to have the _developer options_ unlocked, as
well as the _USB debugging_ option enabled within them, for `adb` to
even work.

=== Partition management

`extra` & `gparted parted`\\

You may also choose to use a graphical partitioning software instead of
`fdisk` or `cfdisk`. For that you can use `gparted`. Of course there is
also the `console` equivalent `parted`.

=== PDF viewer

`extra` & `evince`\\
`community` & `zathura zathura-pdf-mupdf`\\

To use `asciidoctor-pdf`, you might be wondering how you are supposed to
open the generated PDFs using the GUI.

The software `zathura` has a minimalistic design and UI with a focus on
vim keybinding, whereas `evince` is a more desktop like experience, with
things like a print dialogue, etc.

=== Process management

`extra` & `htop xfce4-taskmanager`\\

The native tool is `top`.

The next evolutionary step would be `htop`, which is an improved version
of `top` (like `vi` and `vim` for example)

If you prefer a GUI for that kind of task, use `xfce4-taskmanager`.

=== Video software

Just some additional software related to videos.

==== Live streaming a terminal session

`community` & `tmate`\\

For this task, you'll need a program called `tmate`.

== Additional `GUI` software

As you now have a working graphical desktop environment, you might want
to install some software to utilize your newly gained power.

=== Session Lock

`community` & `xsecurelock xss-lock`\\

Probably the first thing you'll want to set up is a session locker,
which locks your `X`-session after resuming from sleep, hibernation,
etc. It then requires you to input your password again, so no
unauthorized user can access you machine.

I'll use `xss-lock` to hook into the necessary `systemd` events and then
use `xsecurelock` as my locker.

You need to make sure this command gets executed upon start of the
`X`-session, so hook it into your window manager startup script, or in a
file called by your desktop environment

```fish
~
> xss-lock -l -- xsecurelock &
```

=== `xfce-polkit`^{`AUR`}

`AUR` & `xfce-polkit`\\

In order for GUI applications to acquire `sudo` permissions, we need to
install a `PolicyKit` authentication agent.

We could use `gnome-polkit` for that purpose, which resides inside the
official repositories, but I decided on using `xfce-polkit`^{`AUR`}.

Now you just need to startup `xfce-polkit`^{`AUR`} before trying to
execute something like `gparted` and you'll be prompted for your
password.

As I already launch it as a part of my `bspwm` configuration, I won't
have to worry about that.

=== Desktop background

`extra` & `nitrogen`\\

You might want to consider installing `nitrogen`, in order to be able to
set a background image

=== Compositing software

`community` & `picom`\\

To get buttery smooth animation as well as e.g. smooth video playback in
`brave` without screen tearing, you might want to consider using a
compositor, in my case one named `picom`

In order for `obs`' screen capture to work correctly, you need to kill
`picom` completely before using `obs`.

```fish
~
> killall picom
```

or

```fish
~
> ps aux | grep picom

~
> kill -9 <pid>
```

=== `networkmanager` applet

`extra` & `network-manager-applet`\\

To install the `NetworkManager` applet, which lives in your tray and
provides you with a quick method to connect to different networks, you
have to install the `network-manager-applet` package

Now you can start the applet with

```fish
~
> nm-applet &
```

If you want to edit the network connections with a more full screen
approach, you can also launch #cmd("> nm-connection-editor").

The `nm-connection-editor` doesn't search for available Wi-Fis. You
would have to set up a Wi-Fi connection completely by hand, which could
be desirable depending on how difficult it is to set up your Wi-Fi.

=== Show keyboard layout

`AUR` & `xkblayout-state`\\

To show, which keyboard layout and variant is currently in use, you can
use `xkblayout-state`^{`AUR`}

Now simply issue the `layout` alias, provided by my custom `zsh`
configuration.

=== X clipboard

`extra` & `xclip`\\

To copy something from the terminal to the `xorg` clipboard, use `xclip`

=== Taking screen shots

`community` & `scrot`\\

For this functionality, especially in combination with `rofi`, use
`scrot`.

#cmd("> scrot ~/Pictures/filename.png") then saves the screen shot under `~/Pictures/filename.png`.

=== Image viewer

`extra` & `ristretto`\\

Now that we can create screen shots, we might also want to view those

```fish
~
> ristretto filename.png
```

=== File manager

`extra` & `gvfs thunar`\\
`AUR` & `gigolo`\\

You probably also want to use a file manager. In my case, `thunar`, the
`xfce` file manager, worked best.

To also be able to mount removable drives, without being `root` or using
`sudo`, and in order to have a GUI for mounting stuff, you would need to
use `gigolo`^{`AUR`} and `gvfs`.

=== Archive manager

`extra` & `cpio unrar unzip zip`\\
`community` & `xarchiver`\\

As we now have a file manager, it might be annoying, to open up a
terminal every time you simply want to extract an archive of some sort.
That's why we'll use `xarchiver`.

=== Web browser

`extra` & `firefox firefox-i18n-en-us`\\
`community` & `browserpass`\\

As you're already using a GUI, you also might be interested in a web
browser. In my case, I'm using `firefox`, as well as `browserpass` from
the official repositories, together with the , , , and finally add-ons,
in order to use my passwords in `firefox` and have best protection in
regard to privacy, while browsing the web.

We still have to setup `browserpass`, after installing all of this

```fish
~
> cd /usr/lib/browserpass

/usr/lib/browserpass
> make hosts-firefox-user

/usr/lib/browserpass
> cd ~
```

==== Entering the dark side

`AUR` & `tor-browser`\\

You might want to be completely anonymous whilst browsing the web at
some point. Although this shouldn't be your only precaution, using
`tor-browser`^{`AUR`} would be the first thing to do

You might have to check out how to import the `gpg` keys on the `AUR`
page of `tor-browser`.

=== Office utilities

`extra` & `libreoffice-fresh`\\

I'll use `libreoffice-fresh` for anything that I'm not able to do with
`neovim`.

==== Printing

`extra` &
`avahi cups cups-pdf nss-mdns print-manager system-config-printer`\\

In order to be able to print from the `gtk` print dialog, we'll also
need `system-config-printer` and `print-manager`.

```fish
~
> sudo systemctl enable avahi-daemon.service

~
> sudo systemctl start avahi-daemon.service
```

Now you have to edit `/etc/nsswitch.conf` and add
`mdns4_minimal [NOTFOUND`return]=

```fish
hosts: files mymachines myhostname mdns4_minimal [NOTFOUND`return] resolve [!UNAVAIL`return] dns
```

Now continue with this

```fish
~
> avahi-browse --all --ignore-local --resolve --terminate

~
> sudo systemctl enable org.cups.cupsd.service

~
> sudo systemctl start org.cups.cupsd.service
```

Just open up `system-config-printer` now and configure your printer.

To test if everything is working, you could open up `brave`, then go to
/Print/ and then try printing.

=== Communication

Life is all about communicating. Here are some pieces of software to do
exactly that.

==== Email

`extra` & `thunderbird`\\

There is nothing better than some classical email.

==== Telegram

`community` & `telegram-desktop`\\

You want to have your `telegram` messages on your desktop PC?

==== TeamSpeak 3

`community` & `teamspeak3`\\

Wanna chat with your gaming friends and they have a `teamspeak3` server?

==== Discord

`community` & `discord`\\

You'd rather use `discord`?

=== Video software

Just some additional software related to videos.

==== Viewing video

`extra` & `vlc`\\

You might consider using `vlc`

==== Creating video

`AUR` & `obs-linuxbrowser-bin obs-glcapture-git obs-studio-git`\\

`obs-studio-git`^{`AUR`} should be the right choice.

You can also make use of the plugins provided in the package list above.

===== Showing keystrokes

`AUR` & `screenkey`\\

In order to show the viewers what keystrokes you're pressing, you can
use something like `screenkey`^{`AUR`}

For ideal use with `obs`, my `dotfiles` repository already provides you
with the #cmd("> screenkey-obs") alias for you to run with `zsh`.

==== Editing video

`AUR` & `davinci-resolve`\\

In my case, I'm using `davinci-resolve`^{`AUR`}.

==== Utilizing video

`AUR` & `teamviewer`\\

Wanna remote control your own or another PC?

`teamviewer`^{`AUR`} might just be the right choice for you

=== Audio Production

You might have to edit `/etc/security/limits.conf`, to increase the
allowed locked memory amount.

In my case I have 32GB of RAM and I want the `audio` group to be able to
allocate most of the RAM, which is why I added the following line to the
file

```fish
@audio - memlock 29360128
```

==== Ardour

`community` & `ardour`\\

To e.g. edit and produce audio, you could use `ardour`, because it's
easy to use, stable and cross platform.

`extra` & `ffmpeg`\\

Ardour won't natively save in the `mp3` format, due to licensing stuff.
In order to create `mp3` files, for sharing with other devices, because
they have problems with `wav` files, for example, you can just use
`ffmpeg`.

and after that we're going to convert `in.wav` to `out.mp3`

```fish
~
> ffmpeg -i in.wav -acodec mp3 out.mp3
```

==== Reaper

`AUR` & `reaper-bin`\\

Instead of `ardour`, I'm using `reaper`, which is available for linux as
a beta version, in my case more stable than `ardour` and more easy to
use for me.

=== Virtualization

`community` & `virtualbox virtualbox-host-modules-arch`\\

You might need to run another OS, for example Mac OS, from within Linux,
e.g. for development/testing purposes. For that you can use
`virtualbox`.

Now when you want to use `virtualbox` just load the kernel module

```fish
~
> sudo modprobe vboxdrv
```

and add the user which is supposed to run #cmd("> virtualbox") to the
`vboxusers` group

```fish
~
> sudo usermod -a G vboxusers $USER
```

and if you want to use `rawdisk` functionality, also to the `disk` group

```fish
~
> sudo usermod -a G disk $USER
```

Now just re-login and you're good to go.

=== Gaming

`extra` & `pulseaudio pulseaudio-alsa`\\
`community` & `lutris`\\
`multilib` & `lib32-libpulse lib32-nvidia-utils steam`\\

The first option for native/emulated gaming on Linux is obviously
`steam`.

The second option would be `lutris`, a program, that configures a wine
instance correctly, etc.

=== Wacom

`extra` & `libwacom xf86-input-wacom`\\

In order to use a Wacom graphics tablet, you'll have to install some
packages

You can now configure your tablet using the `xsetwacom` command.

=== `VNC` & `RDP`

`extra` & `libvncserver`\\
`community` & `remmina`\\
`AUR` & `freerdp`\\

In order to connect to a machine over `VNC` or to connect to a machine
using the `Remote Desktop Protocol`, for example to connect to a Windows
machine, I'll need to install `freerdp`^{`AUR`}, as well as
`libvncserver`, for `RDP` and `VNC` functionality respectively, as well
as `remmina`, to have a GUI client for those two protocols.

Now you can set up all your connections inside `remmina`.

= Upgrading the system

You're probably wondering why this gets a dedicated section.

You'll probably think that it would be just a matter of issuing

```fish
~
> sudo pacman -Syu
```

That's both true and false.

You have to make sure, /that your boot partition is mounted at `/boot`/
in order for everything to upgrade correctly. That's because the moment
you upgrade the `linux` package without having the correct partition
mounted at `/boot`, your system won't boot. You also might have to do
#cmd("> grub-mkconfig -o /boot/grub/grub.cfg") after you install a different
kernel image.

If your system _indeed doesn't boot_ and _boots to a recovery fish_,
then double check that the issue really is the not perfectly executed
kernel update by issuing

```fish
root in ~
> uname -a
```

and

```fish
root in ~
> pacman -Q linux
```

_The version of these two packages should be exactly the same!_

If it isn't there is an easy fix for it.

== Fixing a faulty kernel upgrade

First off we need to restore the old `linux` package.

For that note the version number of

```fish
root in ~
> uname -a
```

Now we'll make sure first that nothing is mounted at `/boot`, because
the process will likely create some unwanted files. The process will
also create a new `/boot` folder, which we're going to delete
afterwards.

```fish
root in ~
> umount /boot
```

Now `cd` into `pacman`'s package cache

```fish
root in ~
> cd /var/cache/pacman/pkg
```

There should be a file located named something like `linux-<version>.pkg.tar.xz`, where `<version>` would be somewhat equivalent to the previously noted version number

Now downgrade the `linux` package

```fish
root in ~
> pacman -U linux-<version>.pkg.tar.xz
```

After that remove the possibly created `/boot` directory

```fish
root in ~
> rm -rf /boot

root in ~
> mkdir /boot
```

Now reboot and mount the `boot` partition, in my case an EFI System
partition.

Now simply rerun

```fish
~
> sudo pacman -Syu
```

and you should be fine now.

= Glossary <glossary>

This documentation is structured in a way that allows you to keep a printed version up to date without the need to reprint the whole thing.
This is why every section starts on a new page and page numbers are absent.

== Programs, tools & terms

Terms denoted by a `monospaced font` are mostly commands/programs or specific terms that are generally accepted to be a universal name for what they describe.
For example when I say that you need to `cd` into the directory, `cd` denotes the program/command I intend you to use.
If I say you need to read the `PKGBUILD` or that you need to create an `EFI System Partition`, that in turn is the universally accepted name for both of those things.

== Commands

Furthermore I will denote a command execution in a shell with a preceding #cmd(">"): #cmd("> uname -a").
This then mostly includes any needed command line arguments.

== Commandblocks

Multiple commands, where the execution user, or rather the privilege needed, as well as the current working directory are of interested, are displayed in a command execution block.
You can infer the privilege the command was executed by looking at the prompt line above the command, where the `root` username will be denoted if it's an elevated shell.
In any case the first line always contains the current working directory and the next line the prompt.

```fish
~
> git init

root in /boot
> ls -la
```

== Files

If the content of a file is of interest a file listing is used, which shows the (partial) content of the file together with the filename / the filepath.

#filesrc("~/test.sh")[
```
#!/bin/bash

echo test
```
]

If the file is only partially displayed, or the listing is supposed to show an addition to a specific file, it is denoted by `[...]` being appended to the filepath

#filesrc("~/test.sh [...]")[
```
echo appendage
```
]

If I only want to _mention_ a file or path, I will denote it like this #path("~/test.sh").

== Blocks

For special cases, noteworthy mentions, warning, etc. there are special text blocks that are supposed to draw your attention.

#NOTE[
  This is a *note*.
  This annotates some special edge case, some #text(style: "italic")[gotcha]s etc., in other words some useful information.
]

#TIP[
  This is a *tip*.
  This will often be employed if there is a scenario I often times struggled with, or if some special or unusual procedure is needed.
  It just wants to give you a tip.
]

#IMPORTANT[
  This is *important*.
  Should probably be read and adhered to unless you know what you're doing.
  I think this is self explanatory
]

#WARNING[
  This gives you a *warning*.
  I mean this is pretty self explanatory too.
  In general this includes big #text(style: "italic")[gotcha]s, problems, potentially breaking stuff, etc.
]

#CAUTION[
  This gives you the hint to proceed with *caution* and double check!
]

== Explanations

If any term needs an explanation, I will explain it briefly in the following form.

/ term: Short explanation

= Additional notes

If you've printed this guide, you might want to add some additional
blank pages for notes.
