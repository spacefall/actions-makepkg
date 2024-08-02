FROM archlinux:base-devel

COPY entrypoint.sh /entrypoint.sh

# Fix script permissions
RUN chmod 755 /entrypoint.sh

# Run upgrade
RUN pacman -Syu --noconfirm

# Install dependencies
RUN pacman -Syu --noconfirm --needed archlinux-keyring cmake python git rsync namcap mold sudo fakeroot binutils clang

# Installing some build deps to speedup builds
RUN pacman -Syu --noconfirm --needed ninja meson go rust unzip zip alsa-lib gtk3 gtk4 libadwaita libxss nss xdg-utils gcc-libs desktop-file-utils hicolor-icon-theme glib2 glibc

# Other deps to speedup but still deciding on these
RUN pacman -Syu --noconfirm --needed gnome-shell

# Create builder user
RUN useradd -m builder

# Allow builder to run as root
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/builder

# Cleanup
RUN rm -rf /var/cache/pacman/pkg/; rm -rf ~/.cache/*

# Continue execution as builder
USER builder
WORKDIR /home/builder

# Auto-fetch GPG keys (for checking signatures)
#RUN mkdir .gnupg; touch .gnupg/gpg.conf; echo $'keyserver hkp://keyserver.ubuntu.com:80\nkeyserver-options auto-key-retrieve' | tee .gnupg/gpg.conf
#  find ~/.gnupg -type f -exec chmod 600 {} \; && \
#  find ~/.gnupg -type d -exec chmod 700 {} \; && \

# Install yay
RUN git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd .. && rm -rf yay-bin

ENTRYPOINT ["/entrypoint.sh"]
