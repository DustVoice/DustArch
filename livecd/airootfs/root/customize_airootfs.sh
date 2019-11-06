#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(de_DE\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
localectl set-locale LANG="en_US.UTF-8"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc
timedatectl set-timezone Europe/Berlin
timedatectl set-ntp true

loadkeys custom-us
localectl set-keymap --no-convert custom-us

usermod -s /usr/bin/fish root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

pip3 install neovim
pip3 install pygments

! id dustvoice && useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/fish dustvoice
echo 'dustvoice ALL=(ALL) ALL' >> /etc/sudoers

su -s /bin/bash dustvoice

gem install asciidoctor --pre
gem install asciidoctor-pdf --pre
gem install asciidoctor-epub3 --pre
gem install pygments.rb --pre

nvim --headless +PlugInstall +qa
python3 ~/.config/nvim/plugged/YouCompleteMe/install.py --clang-completer

gpg-connect-agent updatestartuptty /bye

exit

usermod -s /usr/bin/fish dustvoice

systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target

systemctl enable dhcpcd.service
systemctl start dhcpcd.service

systemctl enable pcscd
systemctl start pcscd

echo ""
echo "Please set a password for the [root] user:"
until passwd; do echo "Try again, or Ctrl-c within 5 seconds!"; sleep 5; done

echo ""
echo "Please set a password for the [dustvoice] user:"
until passwd dustvoice; do echo "Try again, or Ctrl-c within 5 seconds!"; sleep 5; done
