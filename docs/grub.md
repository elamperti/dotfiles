# GRUB (bootloader)

To change basic settings such as default boot entry and timeout: edit `/etc/default/grub` and run `update-grub` afterwards.

## Changing/setting a splash image
Places where GRUB will look for a background image:
  * `GRUB_BACKGROUND="/path/to/image"` in `etc/default/grub`
  * First image found in `/boot/grub/`. 
  * `/usr/share/desktop-base/grub_background.sh`
  * File listed in the `WALLPAPER` line in `/etc/grub.d/05_debian_theme`

It supports JPG, PNG and TGA formats, but be aware of this limitations:
  * JPG/JPEG images must be 8-bit (256 color)
  * Images should be non-indexed, RGB
  * 640x480 is the right resolution for most cases

After setting/placing a new image run `update-grub`

