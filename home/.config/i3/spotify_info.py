#!/usr/bin/python2
# ToDo: ditch this script and use bash instead

import dbus

try:
    spotify_bus = dbus.SessionBus().get_object("org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2")
    spotify_properties = dbus.Interface(spotify_bus, "org.freedesktop.DBus.Properties")
    metadata = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "Metadata")
    print str(metadata['xesam:artist'][0]) + ' - ' + str(metadata['xesam:title'])
except:
    print "-"
