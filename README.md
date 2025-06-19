# kompass

My completely custom status bar. This is for my personal use only, and therefore will most likely never be configurable.

This project also builds a library containing some widget definitions, which might be more useful to you than the actual bar.
The docs for libkompass can be found [here](https://kotontrion.github.io/libkompass).

Showcase (as of 2024-10-13):
![2024-10-13T14:47:32,759960206+02:00](https://github.com/user-attachments/assets/78278e56-4951-4713-9b5e-a2468405be84)


## install

### on Arch
```bash
wget https://github.com/kotontrion/PKGBUILDS/raw/refs/heads/main/kompass-git/PKGBUILD
makepkg -si
```

the PKGBUILD can be found [here](https://github.com/kotontrion/PKGBUILDS/blob/main/kompass-git/PKGBUILD).
I wont publish it to the AUR until libkompass is more mature.

### from source

#### dependencies

##### build dependencies
- dart-sass
- blueprint-compiler
- vala
- meson

##### runtime dependencies
- gtk4
- gtk4-layer-shell
- libadwaita
- libportal
- astal-mpris
- astal-river
- astal-tray
- astal-battery
- astal-bluetooth
- astal-network
- astal-notifd
- astal-cava
- astal-apps
- astal-wireplumber
- slurp
- wf-recorder

```bash
git clone https://github.com/kotontrion/kompass
cd kompass
meson setup build
meson install -C build
```
