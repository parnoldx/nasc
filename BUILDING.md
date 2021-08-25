## Building

Dependencies
```bash
apt install -y gobject-introspection libgee-0.8-dev libwebkit2gtk-4.0-dev libgtksourceview-3.0-dev libcln-dev libgranite-dev libcurl4-openssl-dev libmpfr-dev intltool meson valac
```

Dependencies(Fedora):

```bash
dnf install gobject-introspection libgee-devel webkit2gtk3-devel gtksourceview3-devel cln-devel granite-devel libcurl-devel mpfr-devel intltool meson vala 
```

then build with:

```bash
meson build --prefix=/usr
ninja -C build install
```
