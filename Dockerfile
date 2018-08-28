FROM lsiobase/java:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ENV AIRSONIC_HOME="/app/airsonic" \
AIRSONIC_SETTINGS="/config" \
LANG="C.UTF-8"

RUN \
 echo "**** install airsonic ****" && \
 mkdir -p \
	${AIRSONIC_HOME} && \
 AIRSONIC_VER=$(curl -sX GET "https://api.github.com/repos/airsonic/airsonic/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 ${AIRSONIC_HOME}/airsonic.war -L \
	"https://github.com/airsonic/airsonic/releases/download/${AIRSONIC_VER}/airsonic.war" && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
VOLUME /config /media /music /playlists /podcasts
