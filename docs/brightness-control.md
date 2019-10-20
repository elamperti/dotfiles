# Controlling displays

## Turn display on/off
This is useful for servers or unattended computers. Install `vbetool`, then just run the following command to turn off the display:

```
vbetool dpms off
```

(same command with `on` to turn it on again)


## Change display brightness

It is possible to control brightness of different types of displays, depending on how they are integrated into the system.

### In laptops
Use the `xbacklight` package.

```
xbacklight -inc 5  # Increase brightness 5%
xbacklight -dec 10 # Reduce brightness by 10%
```

There's also `-set` to define a specific percentage.


### External displays (via DDC)
You'll need to install `ddcutil`, and add yourself to the `i2c` group so you can either fetch the brightness level:

```
ddcutil getvcp 10
```

Or set a brightness level:

```
ddcutil setvcp 10 X
                  └─ replace with a brightness value
```
