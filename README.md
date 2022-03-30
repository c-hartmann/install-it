# intall.sh

a hopefully usefull and mostly generic installer for KDE extensions

## THIS...

shall do the job if used via Dolphin Settings / Configure Dolphin and(!)
if downloaded to some place.

as this shall be able to install files around the HOME place ... the
only valid place to build the archives simply is .. tada .. $HOME.

nice side effect is ... if the user opens the downloaded archive in ark,
she will have a immediate impression of where these files will go.

this makes use of a gzipped tar file containing ME and a gzipped tar archive
containing the files to install. so basicly this runs down to extracting
the tar file to a proper place.

to keep the creation of the distributable tar archive separated .. we might
create this inside a directory in parallel to the installation directory
e.g.:
this is the installation directory: ~/.local/share/servicemenu-download
so i can go here: ~/.local/share/kde-store-build
seems not to be a totally dumb idea, as it might serve solid actions and
plasmoids as well

solid action go to `~/.local/share/solid/actions/`
plasmoids go to `~/.local/share/plasma/plasmoids/`
service menus go to `~/.local/share/kservices5/ServiceMenus/`

## Said That..

quick and rough approach to something like a documentation...

### Basic Idea

install.sh shall be an agnostic installer for KDE extensions. it makes use of:

* a so called base directory used to build and extract the install PACKAGE from within
* one gzipped tar archive containing files with a fixed location
* an optional gzipped tar archive containing user modifyable files (will not overwrite on updates)
* a shell script that extracts this/these tar archive(s) (also serving --uninstall)
* uninstall.sh might exist as a symlink to install.sh
* an extra shell script that performs "variable" actions as installing "binaries" (optional)
* to serve KDEs extension platform the whole thing is packed as another tar archive


### Components

```
# install base dir is either system wide or personaly...
$ base_dir_root="/usr"          # this is risky business
$ base_dir_user="$HOME/.local"  # outbreaks from here with install-extras.sh only
$ BASE_INSTALL_DIR="$base_dir_user"
```


```
# creating the archive with
$ tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip \
  --file install-update.tar.gz <files ...>
```

```
# or (reading a files list from a file)
$ tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip \
  --file install-update.tar.gz --files-from=<files-to-install-seen-from-BASE_INSTALL_DIR-list>
```


### a real world scenario

with having `hello-world.desktop` and `hello-world.sh `

in `./local/share/kservices5/ServiceMenus/` ...

### Commands...


```
# 1 - define a package name (do not use spaces here)
PACKAGE='hello-world'

# 2 - archives used herein
INSTALL_UPDATE_TAR_GZ="install-update.tar.gz"
INSTALL_PROTECT_TAR_GZ="install-protect.tar.gz"
PACKAGE_TAR_GZ="$PACKAGE.tar.gz"

# 3 - just to keep things separated we create and use a "build" directory
BUILD_DIR="$HOME/.local/kde-store-build"
test -d "$BUILD_DIR" || mkdir "$BUILD_DIR"

# 4 - from here we go...
BASE_INSTALL_DIR="$HOME/.local"
cd "$BASE_INSTALL_DIR"

# 5 - having `hello-world.desktop` and `hello-world.sh` in `ServiceMenus/` ...
find ./share/kservices5/ServiceMenus/ -name 'hello-world.*' \
  > $BUILD_DIR/$PACKAGE.files

# 6 - switch to build dir now
cd "$BUILD_DIR"

# 7 - and get install file from github or elsewhere
test -f install.sh && rm install.sh
test -f uninstall.sh && rm uninstall.sh
wget \
  "https://raw.githubusercontent.com/c-hartmann/kde-install.sh/main/install.sh"
ln -sf install.sh uninstall.sh

# 8 - create archive containing files to be installed on target system
tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip \
  --file "$INSTALL_UPDATE_TAR_GZ" \
  --files-from=$PACKAGE.files

# 9 - create archive to distribute to store.kde.org
tar --create --verbose --gzip \
  --file $PACKAGE_TAR_GZ \
  ./install.sh ./uninstall.sh \
  ./$INSTALL_UPDATE_TAR_GZ
```

### Installation (in principal)

this is in principal what (f.i.) dolphon does on installation


```
# working directory is...
SERVICE_MENU_DOWNLOAD_DIR="$HOME/.local/share/servicemenu-download/"
test -d $SERVICE_MENU_DOWNLOAD_DIR || mkdir $SERVICE_MENU_DOWNLOAD_DIR
cd $SERVICE_MENU_DOWNLOAD_DIR

# getting the install from store.kde.org (probably unsufficient)
wget https://www.pling.com/dl?file_name=hello-world.tar.gz

# create and use a directory to extract archive, run install.sh
mkdir hello-world.tar.gz-dir
cd hello-world.tar.gz-dir
tar --extract --verbose --file ../hello-world.tar.gz
chmod +x install.sh # may be this?
source install.sh
```
