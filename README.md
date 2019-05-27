# My dotfiles :sparkles: [![Build Status](https://travis-ci.org/elamperti/dotfiles.svg?branch=master)](https://travis-ci.org/elamperti/dotfiles)

Hi, these are my dotfiles and a bunch of scripts to make new deployments easier.
See [requirements](#requirements), [setup instructions](#installing) and [how to customize](#customization).
There's also some [unrelated documentation](./docs/).

## Screenshots
![i3 desktop](https://user-images.githubusercontent.com/910672/46715151-2b80e280-cc35-11e8-99ee-d681e4e74ab5.jpg)
![tmux featuring vim and bash](https://user-images.githubusercontent.com/910672/44622666-921f8c00-a893-11e8-86a4-1b3355ada324.jpg)
![bash prompt in a git repo](https://user-images.githubusercontent.com/910672/44622668-92b82280-a893-11e8-9b74-78e4693c179d.jpg)

---

## Requirements

**Bash 4** or newer is expected. User must be able to sudo.

The setup will look for the following packages (and try to install them, if you want/are ok with it):

  * `git` to initialize submodules
  * `dialog` which is used for the setup process
  * `stow` to symlink several files

## Installing
Just execute `setup.sh` and keep an eye on what happens :crystal_ball:

```sh
./setup.sh
```

### `setup.sh` options

| **Option**            |                                                                       |
|-----------------------|-----------------------------------------------------------------------|
| -h, --help            | Print the option list.                                                |
| -B, --bundles         | Set up bundles only.                                                  |
| -b, --bundle _BUNDLE_ | Install just one particular bundle.                                   |
| -m, --motd            | Shows the MOTD picker                                                 |
| -p, --prompt          | Runs the prompt parser wizard (creates a prompt a-la-carte).          |
| -u, --update          | Updates all the symlinks as needed.                                   |
| --no-updates          | Skip `apt-get update`. Not recommended unless you've already updated. |
| -v, --verbose         | Makes setup more verbose, mostly useful for debugging.                |

## How does it work?

The setup will verify Bash version before starting. After updating `apt`'s package list and initializing the required [submodules](./.gitmodules), symlinks will be created and the installation section will start.

Package/bundle selection is divided in four steps, and in each one the setup will ask which packages/bundles to install:

  1. **Common packages** are used from terminal and usually found across different distributions.
  2. **Graphical packages** are programs that require a window manager to be used or are only useful in that context.
  3. **Window manager packages** are packages related to specific window managers.
  4. :package: **Bundles**: are special scripts, read more about them in [the guide](./bundles/about-bundles.md).

After installing all the required packages, bundle scripts will finish their installation and may ask for additional information.

## Customization

You should really take a look at [`setup.sh`](./setup.sh) to see what it does. Apart from that, you may want to change the following to suit your needs:

  * [Files in `shell/`](./shell/), which are most of the dotfiles
  * [Files in `home/`](./home/), which will be symlinked to your home folder
  * [Package lists](./common/package-lists.sh)
  * [Bundles](./bundles/), for more details see [the guide](./bundles/about-bundles.md)
  * `~/.bash*` files affixed with `.local` will be sourced (as long as they have their corresponding file in [`shell`](./shell/)
  * Edit the [prompt templates](./art/prompt/templates/), or create a style for an existing one (it's as easy as changing values in a JSON file)
  * Add your own [ascii art](./art/motd/) to use it as MOTD, or custom scripts in [`motd/`](./motd/); the MOTD wizard will let you pick which ones to use.

## Testing

Tests are written using [Bats](https://github.com/sstephenson/bats) and live in the [`test`](./test/) folder. To run them locally:

```sh
bats test
```

## Documentation

I use this repository to hold documentation and findings on my Linux ventures. [Check it out](./docs/)!

## Acknowledgements

  * **Cătălin Mariș**' [dotfiles](https://github.com/alrra/dotfiles) are very interesting and were great to learn when I started using dotfiles. My dotfiles take some functions and ideas from his work.
  * **Kevin Hochhalter** for the simple and powerful [bashlog](https://github.com/klhochhalter/bashlog).
  * I rely on [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) by **Ryan McIntyre** to make my prompt (and Vim) look ~~like there's an icon parade in my console~~ good.
  * [/r/vim](https://www.reddit.com/r/vim/) gave me good ideas and lots of information on how to config my [.vimrc](./bundles/vim/vim/vimrc)
  * The [Git bundle](./bundles/git/) uses [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) :information_desk_person:
  * The i3 theme was based on [videos by Alex Booker](https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf) and customizations from [/r/i3wm](https://www.reddit.com/r/i3wm/), while the theme for rofi was adapted from the work of Benjamin Stauss' [One Dark](https://github.com/DaveDavenport/rofi-themes).
