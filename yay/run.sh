# Taken from u/merith-tk (www.reddit.com/r/archlinux/comments/fg05b1/comment/fk2yohv/) on 2026-05-29

git clone https://aur.archlinux.org/yay-bin.git >/dev/null 2>&1
cd yay-bin
sudo pacman -S base-devel --noconfirm --needed >/dev/null 2>&1
makepkg -s >/dev/null 2>&1
