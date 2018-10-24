# Setting up XFCE

## Installation
It can be installed by just adding the `xfce4` package (check the suggested packages for extra features that you may want).
After restarting there will be an option to start with XFCE in the desktop manager selector (usually a little gear icon in the login screen).

## Plugins
  * `xfce4-whiskermenu-plugin` ([PPA](https://launchpad.net/~gottcode/+archive/ubuntu/gcppa)): a better start menu. There are packages for several distributions, but it may be better to install the latest version. Check [the plugin site](https://gottcode.org/xfce4-whiskermenu-plugin/).
  * `xfce4-systemload-plugin`: to show RAM usage.
  * `xfce4-cpugraph-plugin`: to show CPU usage.
  * `xfce4-hardware-monitor-plugin` to show network usage; is way too complex to set up on Ubuntu 18.04 (from [Debian packages](https://git.xfce.org/panel-plugins/xfce4-hardware-monitor-plugin/tree/?h=omegaphil/pkg)). Requires installing `libgtop-2.0-10` (from external source, Ubuntu has a newer version which is not compatible) and `libgnomecanvasmm-2.6-1v5` libraries.

## Display composition
Avoid tearing by disabling the display compositor in _window manager tweaks_ and install an alternative (suggested: [Compton](https://github.com/chjj/compton) - [PPA](https://launchpad.net/~richardgv/+archive/ubuntu/compton))
