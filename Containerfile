FROM ubuntu:26.04 AS source

ADD --checksum=sha256:bf377420a2e95f2cd2cdda17d5372b51c2534f858b038db9ec6d129554875124 https://github.com/melonDS-emu/melonDS/releases/download/1.1/melonDS-1.1-appimage-x86_64.zip /tmp/source.zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    unzip /tmp/source.zip -d /tmp/archive && \
    appimage="$(find /tmp/archive -type f -name '*.AppImage' | head -n 1)" && \
    chmod 0755 "$appimage" && \
    cd /tmp && \
    "$appimage" --appimage-extract >/dev/null && \
    mv /tmp/squashfs-root /out

FROM ghcr.io/containerpak/mesa64:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/melonds"

COPY --from=source /out /opt/melonds
COPY melonds /usr/bin/melonds
COPY net.kuribo64.melonDS.desktop /usr/share/applications/net.kuribo64.melonDS.desktop

RUN chmod 0755 /usr/bin/melonds && \
    if [ -e /opt/melonds/.DirIcon ]; then install -Dm644 /opt/melonds/.DirIcon /usr/share/icons/hicolor/256x256/apps/net.kuribo64.melonDS.png; fi && \
    cpak-clean-junk
