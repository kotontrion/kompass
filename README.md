# kompass

My completely custom status bar. This is for my personal use only, and therefore will most likely never be configurable.

This project also builds a library containing some widget definitions, which might be more useful to you thatn the actual bar.

Showcase (as of 2024-10-13):
![2024-10-13T14:47:32,759960206+02:00](https://github.com/user-attachments/assets/78278e56-4951-4713-9b5e-a2468405be84)


## install

### on Arch
```bash
wget https://github.com/kotontrion/PKGBUILDS/raw/refs/heads/main/kompass-git/PKGBUILD
makepkg -si
```

the PKGBUILD can be found [here](https://github.com/kotontrion/PKGBUILDS/blob/main/kompass-git/PKGBUILD).
I wont publish it to the AUR, as this is a my personal bar and is most likely not very useful to others without some modifications.

### from source

#### dependencies 

> [!NOTE]  
> Kompass needs the astal-tray lib built from the aylur/astal#68, and the astal-river lib built from the aylur/astal#186 PR. So until they get merged, you have to build them yourself from there.

##### build dependencies
- dart-sass
- blueprint-compiler
- vala
- meson

##### runtime dependencies
- gtk4
- gtk4-layer-shell
- libadwaita
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

```bash
git clone https://github.com/kotontrion/kompass
cd kompass
meson setup build
meson install -C build
```

# License
This project includes multiple subprojects, each with its own licensing terms. Please refer to the provided License files in the respective subdirectories to determine which license applies:




