FROM ubuntu:26.04 AS source

ARG APP_SHA256=bf377420a2e95f2cd2cdda17d5372b51c2534f858b038db9ec6d129554875124

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl --fail --location --output /tmp/melonDS-1.1-appimage-x86_64.zip "https://github.com/melonDS-emu/melonDS/releases/download/1.1/melonDS-1.1-appimage-x86_64.zip" && \
    echo "${APP_SHA256}  /tmp/melonDS-1.1-appimage-x86_64.zip" | sha256sum --check

FROM ghcr.io/containerpak/mesa:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/melonds"

COPY --from=source /tmp/melonDS-1.1-appimage-x86_64.zip /tmp/melonDS-1.1-appimage-x86_64.zip
COPY melonds /usr/bin/melonds
COPY net.kuribo64.melonDS.desktop /usr/share/applications/net.kuribo64.melonDS.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip squashfs-tools && \
    unzip /tmp/melonDS-1.1-appimage-x86_64.zip -d /tmp/archive && \
    appimage="$(find /tmp/archive -type f -name '*.AppImage' | head -n 1)" && \
    chmod +x "$appimage" && \
    "$appimage" --appimage-extract && \
    mv squashfs-root /opt/melonds && \
    chmod 0755 /usr/bin/melonds && \
    if [ -e /opt/melonds/.DirIcon ]; then install -Dm644 /opt/melonds/.DirIcon /usr/share/icons/hicolor/256x256/apps/net.kuribo64.melonDS.png; fi && \
    rm -rf /tmp/melonDS-1.1-appimage-x86_64.zip /tmp/archive && \
    cpak-clean-junk

