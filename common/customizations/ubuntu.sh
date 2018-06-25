# Disable guest user and remote login
if command -v lightdm; then
    sudo mkdir -p "/etc/lightdm/lightdm.conf.d"
    sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
    sudo sh -c 'printf "[SeatDefaults]\ngreeter-show-remote-login=false\n" >/etc/lightdm/lightdm.conf.d/50-no-remote-login.conf'
fi
