# Enrico's dotfiles
Hi, these are my dotfiles. I'm not sure if I'm proud or ashamed of the code you'll find in here.

## Requirements
The setup file expects **Bash 4** or newer. User must be able to sudo.

The setup will look for the following packages (and try to install them, if you want are ok with it):
  * `git` to initialize submodules
  * `dialog` which is used for the setup process
  * `stow` to symlink several files

## Installing
Just execute `setup.sh` and keep an eye on what happens :crystal_ball:

```
./setup.sh
```

### `setup.sh` options

| **Option**            |                                                                       |
|-----------------------|-----------------------------------------------------------------------|
| -h, --help            | Print the option list.                                                |
| -B, --bundles         | Set up bundles only.                                                  |
| -b, --bundle _BUNDLE_ | Install just one particular bundle.                                   |
| --no-updates          | Skip `apt-get update`. Not recommended unless you've already updated. |
| -v, --verbose         | Makes setup more verbose, mostly useful for debugging.                |

## How does it work?
The setup will verify Bash version before starting. After updating `apt`'s package list and initializing the required [submodules](./.gitmodules), symlinks will be created and the installation section will start.

Package/bundle selection is divided in four steps, and in each one the setup will ask wich packages/bundles to install:
  1. **Common packages** are used from terminal and usually found across different distributions.
  2. **Graphical packages** are programs that require a window manager to be used or are only useful in that context.
  3. **Window manager packages** are packages related to specific window managers (XFCE and Gnome).
  4. :package: **Bundles**: are special scripts, read more about them in [the guide](./bundles/about-bundles.md).

After installing all the required packages, bundle scripts will finish their installation and may ask for additional information.

## How to customize this quickly
In case you want to use this fast without checking how it works, you may change the following:
  * [Files in `shell/`](./shell/), which are most of the dotfiles
  * [Packages lists](./common/settings.sh)
  * [Bundles](./bundles/), for more details see [the guide](./bundles/about-bundles.md)
  * `~/.bash_aliases.local` and `~/.bash_functions.local` will be sourced if they exist

## Acknowledgements
  * **Basharat Sialvi** for the [magnific tutorial](https://askubuntu.com/a/283909/198486) on setting up *powerline* everywhere.
  * **Cătălin Mariș**' [dotfiles](https://github.com/alrra/dotfiles) are very interesting and were great to learn when I started using dotfiles. My dotfiles take some functions and ideas from his work.
  * **Kevin Hochhalter** for the simple and powerful [bashlog](https://github.com/klhochhalter/bashlog).
  * The [/r/vim](https://www.reddit.com/r/vim/) subreddit gave me good ideas and lots of information on how to config [.vimrc](./bundles/vim/vim/vimrc)
  * The [Git bundle](./bundles/git/) uses [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) :information_desk_person:
  * I rely on [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) to make my prompt (and Vim) look ~~like there's an icon parade in my console~~ good.
