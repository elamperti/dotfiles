# XKB keyboard mappings :keyboard:

<!-- TOC depthFrom:2 -->

- [Creating mappings](#creating-mappings)
  - [Basic key definition structure](#basic-key-definition-structure)
  - [How to extract current mappings (and how to see other ones)](#how-to-extract-current-mappings-and-how-to-see-other-ones)
- [Applying your custom mappings](#applying-your-custom-mappings)
  - [Create your own .xkbrc](#create-your-own-xkbrc)
  - [Applying your settings](#applying-your-settings)
  - [Making them permanent](#making-them-permanent)
  - [Bonus: printing your own layout](#bonus-printing-your-own-layout)
- [Notes](#notes)
  - [Other sources that may help you](#other-sources-that-may-help-you)

<!-- /TOC -->

Using `xkb` will make you feel despair and empowerment. Both at the same time. **Don't panic.**

## Creating mappings

### Basic key definition structure
```
xkb_symbols "example" {
  key <AC01> { [ a, A, aacute, Aacute ] };
}
``` 

You may name your set of mappings as you want (`example` in this case); this name will be used later in `.xkbrc` to add your definitions on top of the default ones. [See mine](../xkb/symbols/) if you want examples.

`<AC01>` is a reference to the physical key `01` located in row `AC`. You can create a map of this codes like the one below using `xkbprint`:

```
xkbprint -label name $DISPLAY - | ps2pdf - > name_map.pdf
```

![key names map](https://i.imgur.com/vXKcbyu.jpg)

What follows after that is the mappings for the different states of the key:

| Key state | normal | shift | modifier | modifier+shift |
|-----------|--------|-------|----------|----------------|
| Example   | a      | A     | aacute   | Aacute         |
| Result    | a      | A     | á        | Á              |

You may just use two values instead (for example `[ a A ]`) and leave the _modified_ states undefined.

A given file may contain many `key`/`replace key` definitions.

### How to extract current mappings (and how to see other ones)
To extract the current mapping run the following command:
```sh
xkbcomp $DISPLAY destfile
```
(where `destfile` is the file where the current xkb settings will be dumped)

There are several definitions in `/usr/share/X11/xkb/symbols/` that you may use or copy to implement your own.

All the names used to refer to symbols are in `/usr/include/X11/keysymdef.h` (if you don't have that header file in your system just [google it](https://www.google.com/search?q=keysymdef.h)).


## Applying your custom mappings

### Create your own .xkbrc
I created my [.xkbrc](../shell/.xkbrc) extracting the basics from a `xkbcomp` dump. There are two important bits here:
  1) It should reflect your keyboard and basic layout
  2) You will add your own mappings in the `xkb_symbols` line:

```
xkb_symbols { include "pc+us+inet(evdev)+example" };
```

For this I took the current `xkb_symbols` definition from the dump and added `+example` to include my definitions. You may chain several files using `+` (override) or `|` (augment).

### Applying your settings
Once you have your `.xkbrc` defined and the definitions you created in the `.xkb` directory, you can source them manually with the following command:

```
xkbcomp -I"$HOME/.xkb" -R"$HOME/.xkb" "$HOME/.xkbrc" $DISPLAY
```

### Making them permanent
Just add the same command to `.xinitrc` (you may add `-w 0` to hide all the warnings), take a look at [mine for reference](../shell/.xinitrc).

If your OS is using anything other than X (Wayland, for example) you need to invoke `.xinitrc` from the _startup applications_ or from other rc file that your compositor may source at startup.

### Bonus: printing your own layout
You can create a PDF of your current layout like this:

```sh
xkbprint $DISPLAY - | ps2pdf - > my_layout.pdf
```

You may also define a locale with `-lc` so it prints all the characters (otherwise it may miss some of them).

## Notes
My usage of `xkb` is quite rudimentary, you may achieve complex behaviors with a good configuration file. There are topics not covered in this guide, like for example how to create latch keys. You may find interesting how I mapped caps lock to other keys: see [this file](../xkb/symbols/caps).

### Other sources that may help you
  * [An Unreliable Guide to XKB Configuration](https://www.charvolant.org/doug/xkb/html/xkb.html): Probably the only reliable source regarding `xkb` and your last hope before resorting to a traditional typewriter.
  * [xkb walkthrough](https://github.com/Delapouite/xkb-walkthrough)
