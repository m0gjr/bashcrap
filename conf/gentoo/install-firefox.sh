echo "www-client/firefox dbus" > /etc/portage/package.use/firefox.use
emerge --quiet-build --autounmask-write www-client/firefox || (dispatch-conf; emerge --quiet-build www-client/firefox)
