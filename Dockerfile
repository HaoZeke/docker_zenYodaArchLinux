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

# Install yaourt (Adapted from https://github.com/Phifo/yaourt/blob/master/yaourt-install)
RUN cd /home/${USER}/aur && \
    echo "Retrieving package-query ..." && \
	curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz && \
	echo "Uncompressing package-query ..." && \
	tar zxvf package-query.tar.gz && \
	cd package-query && \
	echo "Installing package-query ..." && \
	makepkg -si --noconfirm && \
	cd .. && \
	echo "Retrieving yaourt ..." && \
	curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz && \
	echo "Uncompressing yaourt ..." && \
	tar zxvf yaourt.tar.gz && \
	cd yaourt && \
	echo "Installing yaourt ..." && \
	sudo makepkg -si --noconfirm && \
	echo "Done!"

# Extras
RUN yaourt -S --noconfirm --noedit icu58
RUN pip install --user panflute


# Setup dummy git config
RUN git config --global user.name "${USER}" && git config --global user.email "${USER}@localhost"