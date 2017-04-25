# Making Sonarr work with Tixati

Sonarr is a wonderful tool to track series, but making it work with Tixati has several gotchas.
This is a rough guide through the setup process.


## Sonarr installation
Install Sonarr following [the guide](https://github.com/Sonarr/Sonarr/wiki/Installation#linux).
I suggest [making it a service](https://github.com/Sonarr/Sonarr/wiki/Autostart-on-Linux) too.

### Sonarr setup
#### Indexer(s)
This is where it starts to get tricky. Go to **Settings > Indexers** and add your preferred method.
Don't worry if it yields only magnet links.

#### Download client
In **Settings > Download Client** add a new one, selecting "Torrent Blackhole". Set the torrent folder to the folder Tixati is tracking, and the watch folder to the folder where Tixati will put finished torrents.
Set "Save magnet files" to *Yes* and save.

While you are at this section, be sure "Completed Download Handling" is *enabled*.


## Tixati installation
Just use the [fantastic bundle](./../bundles/tixati/) that comes with these dotfiles :sunglasses:

### Tixati setup

  * In **Settings > Transfers > Meta info** set it to open `.torrent` files created/moved in a folder you specify (e.g. `~/.sonarr/`). Check the "Load magnet URLs ..." box. If you are already using a particular folder for this you can keep it as it is, just remember to make it match when you configure Sonarr.
  * In **Settings > Transfers > Locations** check "Upon completion, move to this location" and point torrents to a folder that we'll later monitor with Sonarr (e.g. `~/torrents/sonarr-will-handle-this`).
  * To avoid being prompted each time a `.torrent` file is found, go to **User interface > Behavior**, and click the **Configure...** button next to "Transfer loading priority/location prompt". Under "Contexts" make sure "Created from watched folder" is unchecked.


## Connecting the dots
Your indexer doesn't give you `.torrent` files. Tixati does nothing with `.magnet` files (what is this anyway, magnet links are links, not files!). Before realizing I could have worked around converting `.magnet` files in `.url` files way easier than converting them to `.torrent` (with a small Bash script), I [refactored](https://github.com/elamperti/Magnet2Torrent/commit/6435038cd33881e565ad41af89b9e493b5f0a609) the hell out of an abandoned piece of _code_ in order to accomplish this. So now I'm using it, because it's less time consuming than simplifying it. Without further ado, here's what you need to do:

  * `sudo apt-get install python-libtorrent` (good luck installing it other way)
  * Clone, download or copy from a floppy disk the [Magnet2Torrent](https://github.com/elamperti/Magnet2Torrent) script -my version, as the original does something completely different-; I suggest you to put it in any folder present in your `PATH`.
  * Save [this Gist](https://gist.github.com/elamperti/d1ced3a405090fc6e4805307a0dc78c1) wherever you want. Edit it so `magnet_folder` points to the folder where `.magnet` files are being created (which is also the folder Tixati monitors).
  * Create a crontab entry calling the script you just saved every 5 minutes.


## How things work

  * Sonarr will query an indexer and produce a magnet link, which will be saved as a file (containing just that link) into the Tixati watched folder.
  * The cron job will call _Markdown2Torrent_ to generate a `.torrent` file in the same folder, removing the `.magnet` file in the process.
  * Tixati will detect the new `.torrent` file (and delete it), creating a new download that -once finished- will be saved to the folder Sonarr is monitoring.
  * Sonarr will detect the saved file(s) and move it to the directory corresponding to the Series that initiated the process.
  * If you have set a connection in **Settings > Connect**, at this point it will tell you the file has been downloaded.

---

## Troubleshooting

#### If Sonarr doesn't generate `.magnet` files

  * In **Settings > General**, under "Updates", set the current branch to `develop`.
  * From a console run `sudo chown -R $USER:$USER /opt/NzbDrone/`
  * Back in Sonarr go to **System > Updates** and click "Install Latest" next to the latest release changelog.
