# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4

LABEL org.opencontainers.image.authors="fireph"

# Add architecture detection
ARG TARGETARCH
ARG TARGETVARIANT

# Environment
ENV DARK_MODE=1
ENV KEEP_APP_RUNNING=1
ENV TDM_VERSION_TAG=0.3.11
ENV APP_ICON_URL=https://raw.githubusercontent.com/fireph/TwitchDropsMiner-updated/master/appimage/pickaxe.png

# Update locale to en_US.UTF-8 since it defaults to POSIX
RUN \
    add-pkg locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8

# Install dependencies
RUN add-pkg wget \
    jpeg \
    zlib \
    freetype \
    lcms2 \
    openjpeg \
    tiff \
    tk \
    tcl \
    font-noto \
    font-noto-emoji \
    fontconfig \
    libx11 \
    libxrender

# Download and install the correct binary based on architecture
RUN case "${TARGETARCH}${TARGETVARIANT}" in \
        "amd64")  BINARY_SUFFIX="-amd64" ;; \
        "arm64")  BINARY_SUFFIX="-arm64" ;; \
        "armv7")  BINARY_SUFFIX="-armv7" ;; \
        *)        echo "Unsupported architecture: ${TARGETARCH}${TARGETVARIANT}" && exit 1 ;; \
    esac && \
    wget -P /tmp/ https://github.com/fireph/TwitchDropsMiner-updated/releases/download/v${TDM_VERSION_TAG}/TwitchDropsMiner-linux-musl${BINARY_SUFFIX}.tar.gz && \
    mkdir /TwitchDropsMiner && \
    cd /tmp && \
    tar -zxvf TwitchDropsMiner-linux-musl${BINARY_SUFFIX}.tar.gz && \
    mv "Twitch Drops Miner/Twitch Drops Miner (by DevilXD)" /TwitchDropsMiner/TwitchDropsMiner && \
    chmod +x /TwitchDropsMiner/TwitchDropsMiner && \
    rm -rf /tmp

# Link config folder files
RUN mkdir /TwitchDropsMiner/config
RUN ln -s /TwitchDropsMiner/config/settings.json /TwitchDropsMiner/settings.json
RUN ln -s /TwitchDropsMiner/config/cookies.jar /TwitchDropsMiner/cookies.jar

# Make sure permissions are gonna work
RUN chmod -R 777 /TwitchDropsMiner

# Copy the start script
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# Generate and install favicons
RUN install_app_icon.sh "$APP_ICON_URL"

# Set the name/version of the application.
RUN set-cont-env APP_NAME "Twitch Drops Miner"
RUN set-cont-env APP_VERSION "$TDM_VERSION_TAG"
