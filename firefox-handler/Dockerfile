# BASE: openSUSE Tumbleweed
FROM opensuse/tumbleweed

# ADD UNPRIVILEGED USER
RUN useradd -m -u 1000 firefoxuser

# DOWNLOAD NEEDED PACKAGES
RUN	zypper --non-interactive ref && \
 	zypper --non-interactive install\
		firefox			\
		mozilla-nss		\
		libwayland-client0	\
		libwayland-egl1		\
		libwayland-cursor0   	\
		pciutils		\
		at-spi2-core		\
	    	Mesa-dri 		\
		fontconfig		\
		google-noto-sans-fonts	\
		liberation-fonts	\
		dejavu-fonts		\
	&& zypper clean --all

# SWITCHES USER AND DEFINES HOME
USER firefoxuser
ENV HOME=/home/firefoxuser
WORKDIR /home/firefoxuser

# LAUCHES FIREFOX BY DEFAULT
ENTRYPOINT ["firefox"]
#CMD ["firefox", "echo CHANGED"]