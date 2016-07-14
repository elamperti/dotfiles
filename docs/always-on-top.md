# How to make a window be always on top?
It's as easy as installing the package `wmctrl` and then using the following command:

```
wmctrl -r :ACTIVE: -b add,above
```

Alternatively, using this command will *toggle* it:

```
wmctrl -r :ACTIVE: -b toggle,above
```

It  may be called using a keyboard shortcut, or its usage may be automated using `devilspie` (or similar tools).
