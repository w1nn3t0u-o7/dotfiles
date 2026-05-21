# My Arch environment

This repository is meant to recreate a personal Arch Linux setup on a fresh machine with as little manual work as possible. The workflow is:

1. attach the bare dotfiles repository to `$HOME`,
2. check out the tracked config,
3. run `install-env.sh` to install packages and apply setup tasks,
4. reboot and verify services, shell, login manager, and bootloader.

The setup scripts are stored in `~/.local/scripts/`, package manifests live in `~/packages/`, and the install script is designed to rebuild the environment from those manifests using `pacman` and `paru`.

## Repository model

This repo is intended to be used as a **bare** Git repository with `$HOME` as the work tree. That means tracked files such as `.config/...`, shell config, tmux config and helper scripts are checked out directly into the home directory.

Example alias:

```bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

To hide untracked home files from normal status output:

```bash
dotfiles config --local status.showUntrackedFiles no
```

## Clean install steps

### 1. Install the minimum tools

On a fresh Arch install, first bring the system up to date and install Git:

```bash
sudo pacman -Syu git
```

The package install script later uses `pacman --needed`, which is useful because already installed packages are skipped instead of being reinstalled.

### 2. Attach the repo to `$HOME`

```bash
git clone --bare git@github.com:w1nn3t0u-o7/dotfiles.git "$HOME/.dotfiles"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Try checking out the tracked files:

```bash
dotfiles checkout
```

If checkout fails because files already exist, move the conflicting files into a backup directory and retry:

```bash
mkdir -p "$HOME/.dotfiles-backup"
dotfiles checkout 2>&1 | grep '^\s' | awk '{print $1}' | while read -r path; do
  mkdir -p "$HOME/.dotfiles-backup/$(dirname "$path")"
  mv "$HOME/$path" "$HOME/.dotfiles-backup/$path"
done

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```

### 3. Run the bootstrap script

```bash
~/.local/scripts/install-env.sh
```

This script is expected to:

- install repo packages from `~/packages/pacman.txt`,
- install foreign/AUR packages from `~/packages/aur.txt`,
- bootstrap `paru` if it is missing,
- install TPM into `~/.tmux/plugins/tpm`, as recommended by TPM upstream,
- clone and run the adi1090x rofi theme installer,
- clone and run the `sddm-astronaut-theme` installer from the upstream repository,
- change the login shell to `zsh`,
- regenerate the GRUB config.

If a machine should skip some machine-specific steps, use flags such as:

```bash
~/.local/scripts/install-env.sh --skip-sddm --skip-grub --skip-shell
```

### 4. Reboot

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

## Machine-specific notes

Some parts of the setup are intentionally machine-specific and may need a decision on each reinstall:

- GRUB regeneration for dual boot
- DisplayLink support
- printer setup
- Bluetooth pairing state

Keep those in mind before running `install-env.sh` with all default options.

## Updating the environment

When the installed package set changes on a working machine, refresh the manifests and commit them:

```bash
~/.local/scripts/update-package-lists.sh
dotfiles add packages/pacman.txt packages/aur.txt
dotfiles commit -m "Update package manifests"
dotfiles push
```

If other config files change too, add and commit them in the same way.

## Thanks

This dotfiles versioning workflow is derived from [ArchWiki](https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git) and modified for my needs.
