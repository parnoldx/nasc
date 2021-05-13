FROM gitpod/workspace-full-vnc
                    
USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update

RUN apt-get install software-properties-common
RUN add-apt-repository ppa:vala-team

RUN apt-get -q update
RUN apt-get install -yq \
    at-spi2-core \
    dbus-x11 \
    gnome-common \
    libbamf3-dev \
    libcairo2-dev \
    libdbusmenu-gtk3-dev \
    libgdk-pixbuf2.0-dev \
    libgee-0.8-dev \
    libglib2.0-dev \
    libgnome-menu-3-dev \
    libgtk-3-dev \
    libgranite-dev \
    libjson-glib-dev \
    libsqlite3-dev \
    libwnck-3-dev \
    libx11-dev \
    libxml2-utils \
    gobject-introspection \
    libwebkit2gtk-4.0-dev \
    libgtksourceview-3.0-dev \
    libcln-dev \
    libcurl4-openssl-dev \
    libmpfr-dev \
    intltool \
    meson \
    valac \
    xvfb
