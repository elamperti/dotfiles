#!/bin/bash

export LOCKFILE="/tmp/app-launcher.lock"
export WAIT_DELAY="0.4" # Must be higher than xcape's timeout!

# WHAT IS ALL THIS SORCERY ABOUT?!
# ================================
#
# rofi's `-run-command (...)` will be executed when an entry is selected,
# otherwise it exits with a non-zero code (and doesn't run `-run-command`).
# That's why the sleep/rm is duplicated in RUN_COMMAND and in the last lines.
#
# When rofi launches an application, the process doesn't end until the launched
# application is closed, so without this method the lockfile would remain open
# until the launched application quits, missing the purpose of this script.


# The parentheses in the following command fork {cmd} so it can be disowned.
# LOCKFILE and WAIT_DELAY are exported variables, we can use them inside the
# single quotes here, going against SC2016.
# The output of the command *must* be piped because otherwise when this script
# exits the expected stdout would be broken and some applications may complain.
# shellcheck disable=SC2016
RUN_COMMAND='bash -c "({cmd} >/dev/null 2>&1 &);sleep $WAIT_DELAY;rm \"$LOCKFILE\""'

if [ ! -f "${LOCKFILE}" ]; then
  # Store this script's PID into the lockfile
  echo $$ >"${LOCKFILE}"

  # Launch rofi
  i3-dmenu-desktop --dmenu="rofi -show drun -i -matching fuzzy -theme blurry -run-command '$RUN_COMMAND'" 2>/dev/null

  # At this point I tried to check for the exit code of the process above, but it
  # turns out it always returns the same exit code either canceling rofi or after
  # having ran the selected command, so this extra check will happen every time.

  # This checks this script's PID against the one stored in the lockfile
  if [[ $(< ${LOCKFILE}) == "$$" ]]; then
    sleep ${WAIT_DELAY}
    rm "${LOCKFILE}" 2>/dev/null
  fi
fi
