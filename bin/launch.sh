#!/bin/bash

if ! pgrep -x elephant > /dev/null; then
  setsid uwsm-app -- elephant &
fi

if ! pgrep -f "walker --gapplication-service" > /dev/null; then
  setsid uwsm-app -- walker --gapplication-service &
fi

exec elephant menu wallpapers "$@"
