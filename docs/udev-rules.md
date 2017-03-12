# Run script on device connection using udev rules
`udev` is very useful for handling device events such as, for example, the connection of a new device.

  1. To add a rule for a device it has to be identified first. If it's a USB device, `lsusb` will be enough to get the _vendor_ and _product_ ids.
  2. Once those values are known, a rule file can be created in `/etc/udev/rules.d/`. The files in that directory will be processed in lexical order, so a number may be used before its name to override other rules. The `.rules` extension is mandatory. A good filename should be short but descriptive. For example: `50-logitech-mouse.rules`
  3. Replace the example values for _Vendor_ and _Product_ with those of the device to be used, and point `RUN` to the script that has to be run. Keep in mind **scripts will block the daemon until finished**.

  ```
  ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="077d", ENV{ID_MODEL_ID}=="0410", RUN+="/path/to/script.sh"
  ```

  4. Edit the script at `/path/to/script.sh` and verify everything works.

