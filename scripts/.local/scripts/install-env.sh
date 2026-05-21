#!/usr/bin/env bash
set -euo pipefail

repo_root="${DOTFILES_REPO:-$HOME}"
packages_dir="$repo_root/packages"
pacman_list="$packages_dir/pacman.txt"
aur_list="$packages_dir/aur.txt"
konsave_profile="plasma"

update_grub=1
set_zsh_shell=1
install_tpm=1
install_doom=1
import_konsave=1

user_services=(
    syncthing.service
    emacs.service
    keyd.service
)

system_services=(
    NetworkManager.service
    sddm.service
    bluetooth.service
    firewalld.service
    tailscaled.service
    power-profiles-daemon.service
    avahi-daemon.service
    cups.service
)

while [[ $# -gt 0 ]]; do
    case "$1" in
    --skip-grub) update_grub=0 ;;
    --skip-shell) set_zsh_shell=0 ;;
    --skip-tpm) install_tpm=0 ;;
    --skip-doom) install_doom=0 ;;
    --skip-konsave) import_konsave=0 ;;
    --profile)
        shift
        konsave_profile="$1"
        ;;
    --profile=*)
        konsave_profile="${1#--profile=}"
        ;;
    *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
    shift
done

read_list() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -vE '^\s*(#|$)' "$file" || true
    fi
}

mapfile -t pacman_packages < <(read_list "$pacman_list")
mapfile -t aur_packages < <(read_list "$aur_list")

tmp_root="$(mktemp -d)"
cleanup() {
    rm -rf "$tmp_root"
}
trap cleanup EXIT

echo "==> Updating package databases and upgrading system"
sudo pacman -Syu

echo "==> Installing base tools needed for AUR builds"
sudo pacman -S --needed base-devel git curl

if ! command -v paru >/dev/null 2>&1; then
    echo "==> Installing paru"
    git clone https://aur.archlinux.org/paru.git "$tmp_root/paru"
    (
        cd "$tmp_root/paru"
        makepkg -si --noconfirm
    )
fi

if ((${#pacman_packages[@]} > 0)); then
    echo "==> Installing pacman packages"
    sudo pacman -S --needed "${pacman_packages[@]}"
else
    echo "==> No pacman packages listed"
fi

if ((${#aur_packages[@]} > 0)); then
    echo "==> Installing AUR/foreign packages"
    paru -S --needed "${aur_packages[@]}"
else
    echo "==> No AUR packages listed"
fi

if ((import_konsave)); then
    knsv_file="$repo_root/${konsave_profile}.knsv"
    if ! command -v konsave >/dev/null 2>&1; then
        echo "==> konsave not found, installing it with pipx..." >&2
        pipx install konsave
    elif [[ ! -f "$knsv_file" ]]; then
        echo "==> No .knsv file found at $knsv_file, skipping Plasma profile import" >&2
    else
        echo "==> Importing Plasma profile '$konsave_profile' from $knsv_file"
        konsave --import-profile "$knsv_file" --force
        echo "==> Applying Plasma profile '$konsave_profile'"
        konsave --apply "$konsave_profile" --force
    fi
fi

if ((install_doom)); then
    echo "==> Installing Doom Emacs"
    if [[ ! -d "$HOME/.config/emacs" ]]; then
        git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
        "$HOME/.config/emacs/bin/doom" install --no-env --no-config
    else
        echo "Doom Emacs already present, running doom sync"
        "$HOME/.config/emacs/bin/doom" sync
    fi
fi

if ((install_tpm)); then
    echo "==> Installing TPM"
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo "TPM already present"
    fi
fi

if ((set_zsh_shell)); then
    if command -v zsh >/dev/null 2>&1; then
        current_shell="$(getent passwd "$USER" | cut -d: -f7 || true)"
        target_shell="$(command -v zsh)"
        if [[ "$current_shell" != "$target_shell" ]]; then
            echo "==> Setting default shell to zsh"
            chsh -s "$target_shell"
        else
            echo "==> Default shell already set to zsh"
        fi
    fi
fi

if ((update_grub)); then
    echo "==> Updating GRUB config"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if ((${#user_services[@]} > 0)); then
    echo "==> Enabling user services"
    systemctl --user daemon-reload
    for svc in "${user_services[@]}"; do
        echo "   -> $svc"
        systemctl --user enable --now "$svc"
    done
fi

if ((${#system_services[@]} > 0)); then
    echo "==> Enabling system services"
    sudo systemctl daemon-reload
    for svc in "${system_services[@]}"; do
        echo "   -> $svc"
        sudo systemctl enable --now "$svc"
    done
fi

echo "==> Environment installation complete"
