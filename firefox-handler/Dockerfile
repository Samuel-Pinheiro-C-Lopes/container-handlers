# Base: openSUSE Tumbleweed
# Base: Alpine smaller size with less surface for attacks and less vulnerability prone libraries
FROM alpine:latest

RUN mkdir -p /home/firefoxuser

# ADD UNPRIVILEGED USER
RUN adduser -u 1000 -h /home/firefoxuser -D firefoxuser

# DOWNLOAD NEEDED PACKAGES
RUN apk add --no-cache firefox	\
		nss		\
		pulseaudio	\
		fontconfig	\
		mesa-dri-gallium\
		font-noto &&	\
	apk cache clean		\


# RUN	zypper --non-interactive ref && \
# 	zypper --non-interactive install\
#		firefox			\
#		mozilla-nss		\
#		pciutils		\
#		at-spi2-core		\
#	    	Mesa-dri 		\
#		fontconfig		\
#		google-noto-sans-fonts	\
#		liberation-fonts	\
#		dejavu-fonts		\
#	&& zypper clean --all

# SWITCHES USER AND DEFINES HOME
USER firefoxuser
ENV HOME=/home/firefoxuser
WORKDIR /home/firefoxuser

# LAUCHES FIREFOX BY DEFAULT
ENTRYPOINT ["firefox"]
#CMD ["firefox", "echo CHANGED"]