#!/bin/bash

# if webinterface:
curl -I -q -k -f https://127.0.0.1:631/printers/ || exit $?

# else
cupsctl || exit $?

# or else
[[ "$(lpstat -r)"  == "scheduler is running" ]]
exit $?
