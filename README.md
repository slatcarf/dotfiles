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

