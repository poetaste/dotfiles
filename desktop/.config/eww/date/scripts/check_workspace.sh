#!/bin/bash

windows=$(hyprctl activeworkspace -j | jq '.windows')

if [ "$windows" -eq 0 ]; then
  echo -n "true"
else
  echo -n "false"
fi
