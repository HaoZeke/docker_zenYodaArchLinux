# Use the latest arch with base-devel
FROM base/devel

# By Rohit Goswami
MAINTAINER Rohit Goswami <rohit.1995@mail.ru>

# Update apt and get build reqs
RUN pacman-key --refresh-keys && pacman-key -r 753E0F1F && pacman-key --lsign-key 753E0F1F && pacman -Syy
RUN pacman --noconfirm -S python-pip texlive-most yarn tup pandoc pandoc-citeproc sassc git

# Switch to the new user by default and make ~/ the working dir
ENV USER build
WORKDIR /home/${USER}/

# Add the build user, update password to build and add to sudo group
RUN useradd --create-home ${USER} && echo "${USER}:${USER}" | chpasswd && usermod -aG wheel ${USER}
RUN echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use ccache by default
ENV USE_CCACHE 1

# Fix permissions on home
RUN chown -R ${USER}:${USER} /home/${USER}
RUN mkdir -p /home/${USER}/aur

# Switch to ${USER}
USER ${USER}

# Install yaourt
RUN cd /home/${USER}/aur && \
    git clone https://aur.archlinux.org/package-query.git && \
    cd /tmp/package-query && \
    yes | sudo -u ${USER} makepkg -si && \
    cd .. && \
    sudo -u ${USER} git clone https://aur.archlinux.org/yaourt.git && \
    cd yaourt && \
    yes | sudo -u ${USER} makepkg -si && \
    cd .. && \
    yaourt --version

# Extras
RUN yaourt -S --noconfirm --noedit icu58
RUN pip install --user panflute


# Setup dummy git config
RUN git config --global user.name "${USER}" && git config --global user.email "${USER}@localhost"