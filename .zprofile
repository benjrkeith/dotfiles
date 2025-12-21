if [ "$(tty)" = "/dev/tty1" ] && uwsm check may-start; then
  exec "/usr/local/bin/start-hyprland-uwsm-silent"
fi
