NOTE: 
- Redshift config isn't read from .config directory due to some
AppArmor settings in Debian, see: https://github.com/jonls/redshift/issues/820

> This could help until it gets fixed upstream:
> 
> Edit the file /etc/apparmor.d/usr.bin.redshift and change the line
>
>    owner @{HOME}/.config/redshift.conf r,
>
> To
>
>    owner @{HOME}/.config/redshift/* r,

# Gnome Flashback
I am using https://github.com/nmakel/i3-gnome to run i3 with gnome flashback.
If you are using this, use dconf-editor to apply the options in '00-keyboard.conf', as gnome
overwrites them.

# TODO
- Auto install GTK Theme when using gnome-flashback https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme/tree/master
