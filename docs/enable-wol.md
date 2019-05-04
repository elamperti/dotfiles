# How to enable Wake on LAN

After enabling WOL in the BIOS/UEFI, is necessary to keep the corresponding ethernet controller working after shutdown. To do so, install `ethtool`, and run the following command:

```sh
sudo ethtool -s enp3s0 wol g
```


## Finding out your interface name

In old times, the network interface was usually `eth0`, but if you had more than one interface then its name wouldn't be guaranteed to be the same on each boot.
To solve that, udevd now names devices according to the type of interface, its bus and its slot (for example, `enp3s0`).

To list the interfaces available:

```sh
ls /sys/class/net|grep -E "^(e|w)"
```

(won't work with infiniband, but if it were the case... what are you doing reading this?!)


## Keeping it enabled

To keep WOL enabled, place the following script in `/etc/init/wol.conf`, replacing `enp3s0` with the corresponding interface:

```
start on started network

script
    interface=enp3s0
    logger -t 'WOL init script' enabling WOL for $interface
    ethtool -s $interface wol g
end script
```

Remember to make the script executable (`sudo chmod +x /etc/init/wol.conf`).
