# Mouse polling

Mouse polling can be defined through he kernel module **usbhid**, using the `mousepoll` parameter with any of the following values:

| Value | Polling rate     |
|-------|------------------|
| 10    | 100 Hz (default) |
| 8     | 125 Hz           |
| 4     | 250 Hz           |
| 2     | 500 Hz           |
| 1     | 1000 Hz          |


## How to find out the current polling rate
Use this command to get the current polling rate:

```
cat /sys/module/usbhid/parameters/mousepoll
```

## Testing different polling rates
This command can be used to test different polling rates (replacing `N` with a value from the table):

```
sudo modprobe -r usbhid && sudo modprobe usbhid mousepoll=N
```

## Making the change permanent
Append the following lines to `/etc/modules` (replacing `N` with the desired value):

```
-r usbhid
usbhid mousepoll=N
```

This change will be live after rebooting.


---
Source: http://www.urbanterror.info/forums/topic/21844-howto-changing-mouse-polling-rate-on-ubuntu/
