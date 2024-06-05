# Encrypting your home directory on Linux

I've recently added a new disk to my system (`nvme1n1` in this guide), and I wanted to move my home directory to it, encrypted using LUKS. This was done on Arch. All commands mentioned below require root privileges.

<!-- TOC depthFrom:2 -->

- [Required packages](#required-packages)
- [Preparing the partition](#preparing-the-partition)
  - [Backing up the LUKS header](#backing-up-the-luks-header)
  - [Restoring the LUKS header](#restoring-the-luks-header)
- [Moving files to their new home](#moving-files-to-their-new-home)
  - [Tip: differentiating between the old and new home](#tip-differentiating-between-the-old-and-new-home)
- [Mounting the partition automatically at login](#mounting-the-partition-automatically-at-login)
- [Removing the old /home](#removing-the-old-home)

<!-- /TOC -->

## Required packages

- `cryptsetup` for LUKS encryption
- `pam_mount` to mount the encrypted partition at login

## Preparing the partition

First format the partition using LUKS encryption. You may use the same passphrase as your login password for convenience.

```sh
cryptsetup luksFormat /dev/nvme1n1p1
```

Then open the encrypted partition:

```sh
cryptsetup open /dev/nvme1n1p1 encrypted-home
```

This will create a new device at `/dev/mapper/encrypted-home`, which at this point can be formatted with a filesystem (in this case _ext4_):

```sh
mkfs.ext4 /dev/mapper/encrypted-home
```

### Backing up the LUKS header

Apparently it's a good idea to backup the LUKS header:

```sh
cryptsetup luksHeaderBackup /dev/nvme1n1p1 --header-backup-file luksHeaderBackup.bin
```

### Restoring the LUKS header

Supposedly, you can restore it with the following command:

```sh
cryptsetup luksHeaderRestore /dev/nvme1n1p1 --header-backup-file luksHeaderBackup.bin
```

Did I test this? No. Should you? Yes. Will I? Probably not (but you should).

## Moving files to their new home

First mount the encrypted volume:

```sh
mkdir -p /mnt/newhome
mount /dev/mapper/encrypted-home /mnt/newhome
```

Then copy everything with this handy command:

```sh
cp -a /home/. /mnt/newhome/
```

(the `-a` flag preserves file permissions and ownership)

### Tip: differentiating between the old and new home

Since at this point there are two identical copies of the home directory, it can be useful to add a different file to identify them. Specially considering that the mountpoint of the new home will be just over the old one:

```sh
touch /mnt/newhome/0000-THIS_IS_THE_NEW_HOME
touch /home/0000-OLD_HOME
```

## Mounting the partition automatically at login

Now there's an encrypted copy of `/home`, but it needs to be mounted at login. This is where `pam_mount` comes in.

Edit `/etc/security/pam_mount.conf.xml` and add the following line (change username and path as needed):

```xml
<volume user="elamperti" fstype="crypt" path="/dev/nvme1n1p1" mountpoint="/home" options="noatime,allow_discard" />
```

Where should this line go? I'm not exactly sure, but I put it near the end of the file, inside `<pam_mount>` below the comment `<!-- pam_mount parameters: Volume-related -->`.

Finally, I followed the instructions on the [Arch Wiki for `pam_mount`](https://wiki.archlinux.org/title/pam_mount#Login_manager_configuration) to modify `/etc/pam.d/system-login`. The order of entries in this file is important.

## Removing the old /home

After rebooting and verifying that everything works as expected, the old home directory can be moved or removed. I recommend using a virtual console for this.

1. Unmount the new home:

   ```sh
   umount /home
   ```

   If this fails, there may be processes still using the directory. You can find them with `lsof /home` and killing them.

2. Check that the partition was successfully unmounted using `lsblk` or just checking which file you get with `ls /home/0000-*` if you followed [the tip](#tip-differentiating-between-the-old-and-new-home) above.

3. At this point the home can either be moved to a temporary location:

   ```sh
   mv /home /old-home
   ```

   Or removed forever:

   ```sh
   rm -rf /home
   ```

4. After this the new home can be remounted (alternative: reboot):

   ```sh
   mount -a
   ```
