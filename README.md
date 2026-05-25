# My Arch environment

This repository recreates a personal Arch Linux setup on a fresh machine with as little manual work as possible. The workflow is:

1. clone the dotfiles repository to `~/Projects/dotfiles`,
2. install GNU Stow and run `stow` to symlink all packages into `$HOME`,
3. run `install-env.sh` to install packages and apply setup tasks,
4. reboot and verify services, shell, login manager, and bootloader.

The setup scripts are stored in `~/.local/scripts/` (symlinked via the `scripts` package), package manifests live in `package-lists/packages/`, and the install script is designed to rebuild the environment from those manifests using `pacman` and `paru`.

## Repository model

This repo is managed with **GNU Stow**. Each top-level directory is a Stow _package_ whose contents mirror the structure they should have under `$HOME`. Stow creates symlinks from `$HOME` into the package directory, so the repo never touches home files directly.

## Clean install steps

### 1. Install the minimum tools

On a fresh Arch install, bring the system up to date and install Git and GNU Stow:

```bash
sudo pacman -Syu git stow
```

### 2. Clone the repository

```bash
mkdir -p ~/Projects
git clone git@github.com:w1nn3t0u-o7/dotfiles.git ~/Projects/dotfiles
```

### 3. Stow all packages

From the repo root, symlink every package into `$HOME`:

```bash
cd ~/Projects/dotfiles
stow -v -t ~ desktop doom ghostty git scripts starship wallpapers yazi zsh
```

If any target path already exists as a real file or directory, move it out of the way first and then restow:

```bash
mv ~/.config/doom ~/.config/doom.bak
stow -v -t ~ doom
```

To remove all symlinks for a package:

```bash
stow -D -t ~ <package>
```

To remove and recreate all symlinks for a package (useful after moving the repo):

```bash
stow -R -v -t ~ <package>
```

### 4. Run the bootstrap script

```bash
~/.local/scripts/install-env.sh
```

This script is expected to:

- install repo packages from `~/Projects/dotfiles/package-lists/packages/pacman.txt`,
- install foreign/AUR packages from `~/Projects/dotfiles/package-lists/packages/aur.txt`,
- bootstrap `paru` if it is missing,
- change the login shell to `zsh`,
- regenerate the GRUB config.

### 5. Reboot

```bash
sudo reboot
```

## Services

This setup may enable both system services and user services. User services are managed through the per-user systemd instance with `systemctl --user`, while machine-wide services are managed with normal `systemctl`.

After install, verify the current state with:

```bash
systemctl --user list-unit-files --type=service --state=enabled --no-pager
systemctl list-unit-files --type=service --state=enabled --no-pager
```

## Updating the environment

### Editing config files

Edit any file inside `~/Projects/dotfiles/<package>/`. The symlink in `$HOME` means changes are immediately reflected. Commit and push normally:

```bash
cd ~/Projects/dotfiles
git add .
git commit -m "Update <package> config"
git push
```

### Adding a new config file to a package

Move the real file from `$HOME` into the appropriate package directory, then restow:

```bash
mv ~/.config/foo/bar.conf ~/Projects/dotfiles/foo/.config/foo/bar.conf
cd ~/Projects/dotfiles
stow -R -v -t ~ foo
```

### Adding a new package

Create the package directory mirroring the target path under `$HOME`, move the config into it, and stow:

```bash
mkdir -p ~/Projects/dotfiles/newapp/.config/newapp
mv ~/.config/newapp ~/Projects/dotfiles/newapp/.config/newapp
cd ~/Projects/dotfiles
stow -v -t ~ newapp
git add newapp
git commit -m "Add newapp dotfiles"
```

### Updating package manifests

When the installed package set changes, refresh the manifests and commit:

```bash
~/.local/scripts/update-package-lists.sh
cd ~/Projects/dotfiles
git add package-lists/packages/pacman.txt package-lists/packages/aur.txt
git commit -m "Update package manifests"
git push
```

## Thanks

The Stow-based dotfiles workflow is inspired by community guides on [GNU Stow](https://www.gnu.org/software/stow/) and the [ArchWiki dotfiles page](https://wiki.archlinux.org/title/Dotfiles).
