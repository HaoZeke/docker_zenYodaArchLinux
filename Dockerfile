# Use the latest arch with base-devel
FROM archlinux:latest

# By Rohit Goswami
LABEL maintainer="Rohit Goswami <rohit.1995@mail.ru>"
LABEL name="zenYoda"

# Update package lists and get build reqs including yay
RUN  curl -s "https://www.archlinux.org/mirrorlist/all/http/" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist && \
    rm -R /etc/pacman.d/gnupg/ && \
    gpg --refresh-keys && \
    pacman -Syy --noconfirm base base-devel && \
    pacman-key --init && pacman --noconfirm -S archlinux-keyring && pacman-key --refresh-keys && \
    pacman-key -r 753E0F1F && pacman-key --lsign-key 753E0F1F && pacman -Syy && \
    pacman --noconfirm -S python-pip texlive-most yarn tup pandoc pandoc-citeproc sassc git biber openssh
# The key management is from https://bbs.archlinux.org/viewtopic.php?id=242701 

# Switch to the new user by default and make ~/ the working dir
ENV USER zenyoda
# WORKDIR /home/${USER}/

# Add the build user, update password to build and add to sudo group
RUN useradd --create-home ${USER} && echo "${USER}:${USER}" | chpasswd && usermod -aG wheel ${USER}
RUN echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use ccache by default
ENV USE_CCACHE 1

# Fix permissions on home
RUN chown -R ${USER}:${USER} /home/${USER}
RUN sudo -u ${USER} mkdir -p /home/${USER}/aur

# Switch to ${USER}
USER ${USER}

# Extras
RUN sudo pip install panflute pandoc-eqnos pandoc-fignos && \
 whoami && cd /home/${USER}/aur && \
 yarn global add surge && \
 git clone https://aur.archlinux.org/yay.git && \
 cd yay && \
 makepkg -si --noconfirm

# Setup dummy git config
RUN git config --global user.name "${USER}" && git config --global user.email "${USER}@localhost"
