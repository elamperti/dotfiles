# Bundles
Bundles go beyond a simple package installation: they may execute custom scripts or adjust configuration files, for example.

## Main file and mandatory functions
The main file should be named exactly as the bundle directory, with `.sh` extension.
It's expected to have the following functions:

  * `get_name()` and `get_desc()`, both echoing bundle name and description respectively
  * `verify_requirements()` (which should `exit` with an error if requirements are not met)
  * `on_init()` will be executed if the bundle is selected, just after the bundle selection dialog. This may enqueue fundamental packages and do other preparations, but it shouldn't stall the setup process.
  * `after_installs()` will run after the setup has installed packages. This is a good place to ask for more information and do other lengthy processes.

Keep all bundle names lowercase.

## Bundle script boilerplate

```
#!/bin/bash

pushd ".." &>/dev/null
source "bundle-tools.sh"
popd &>/dev/null

get_name() { echo "My bundle"; }
get_desc() { echo "this is its description"; }

verify_requirements() {
    # This is called before the user selects the bundle.
    # This verification should be automatic (no user interaction)
}

on_init() {
    # At this point the user already selected this bundle.
}

after_installs() {
    # All the package installations were executed.
}

# The following line is necessary.
# It allows bundles to be called without being sourced.
$@
```

## FAQ

  * **Why do you return the bundle _name_ and _description_ using just `echo` but the rest of the functions use `send_cmd`?**

  Name and description are reduced to a simple echo to make the script easy to read. Afterwards, the `send_cmd` calls are there to send all the given commands through a file descriptor (leaving STDOUT and STDERR where they were), so when the bundle script is called it's easy to separate and execute the given commands in the context of the setup script.


  * **How do I enqueue packages properly?**

  Use the `send_cmd` function, available in `bundle-tools.sh`.

