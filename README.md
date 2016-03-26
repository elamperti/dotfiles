# Enrico's dotfiles
Hi, these are my dotfiles. I'm not sure if I'm proud or ashamed of the code you'll find in here.

:warning: **Before blindly executing the setup script you should take a look at what it does.**

## Requirements
The setup file expects **Bash 4** or newer. User must be able to sudo.

The setup will look for (and ask confirmation to install if missing):
  * `dialog`, which is used for the setup process
  * `stow` to symlink several files

## Installing
Just execute `setup.sh`:

```
./setup.sh
```

## How does it work?
The setup will verify Bash version before starting. Then it will look for `dialog` and start the setup process asking for the user's password to sudo.
First it will create symlinks, then proceed to install in four stages:
  * *Common packages* are used from terminal and usually found across different distributions.
  * *Graphical packages* are programs that require a window manager to be used or are only useful in that context.
  * *Window manager packages* are graphical packages particular to specific window managers (XFCE and Gnome).
    After installing all the packages, bundle scripts may ask for additional information or confirmations.
  * *Bundles* are scripts that go beyond a simple `apt-get install` adding a PPA, extra packages or executing scripts.

## How to customize this quickly
In case you want to use this fast without checking how it works, you may change the following:
  * [Files in `shell/`](./shell/), which are most of the dotfiles
  * [Packages lists](./common/packages.sh)
  * [Bundles](./bundles/), for more details see [the guide](./bundles/about-bundles.md)

## Acknowledgements
  * **Basharat Sialvi** for the [magnific tutorial](https://askubuntu.com/a/283909/198486) on setting up *powerline* everywhere.
  * **Cătălin Mariș**' [dotfiles](https://github.com/alrra/dotfiles) are very interesting and were great to learn when I started using dotfiles. My dotfiles take some functions and ideas from his work.
  * **Kevin Hochhalter** for the simple and powerful [bashlog](https://github.com/klhochhalter/bashlog).
  * The [/r/vim](https://www.reddit.com/r/vim/) subreddit has good ideas and lots of information on how to config [.vimrc](./bundles/vim/vim/vimrc).
