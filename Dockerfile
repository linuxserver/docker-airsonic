FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy prebuild and war files
COPY prebuilds/ /prebuilds/

# package version settings
ARG JETTY_VER="9.3.14.v20161028"

# environment settings
ENV AIRSONIC_HOME="/app/airsonic"
ENV AIRSONIC_SETTINGS="/config"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	openjdk8 \
	tar && \

# install runtime packages
 apk add --no-cache \
	ffmpeg \
	flac \
	lame \
	openjdk8-jre \
	ttf-dejavu && \

# install jetty-runner
 mkdir -p \
	/tmp/jetty && \
 cp /prebuilds/* /tmp/jetty/ && \
 curl -o \
 /tmp/jetty/"jetty-runner-$JETTY_VER".jar -L \
	"https://repo.maven.apache.org/maven2/org/eclipse/jetty/jetty-runner/${JETTY_VER}/jetty-runner-{$JETTY_VER}.jar" && \
 cd /tmp/jetty && \
 install -m644 -D "jetty-runner-$JETTY_VER.jar" \
	/usr/share/java/jetty-runner.jar && \
 install -m755 -D jetty-runner /usr/bin/jetty-runner && \

# install airsonic
 mkdir -p \
	${AIRSONIC_HOME} && \
 AIRSONIC_VER=$(curl -sX GET "https://api.github.com/repos/airsonic/airsonic/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 ${AIRSONIC_HOME}/airsonic.war -L \
	"https://github.com/airsonic/airsonic/releases/download/${AIRSONIC_VER}/airsonic.war" && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
VOLUME /config /media /music /playlists /podcasts
