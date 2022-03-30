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
### install base dir is either system wide or personaly
base_dir_root="/usr"          # this is risky business
base_dir_user="$HOME/.local"  # outbreaks from here with install-extras.sh only
BASE_INSTALL_DIR="$base_dir_user"
```


s```
# creating the archive with
$ tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip --file install-update.tar.gz <files ...>
```
```
# or (reading a files list from a file)
$ tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip --file install-update.tar.gz --files-from=<files-to-install-seen-from-BASE_INSTALL_DIR-list>
```

```
# e.g.
$ tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip --file install-update.tar.gz ./local/share/kservices5/ServiceMenus/hello-world/
```

```
# or
$ cd "$BASE_INSTALL_DIR" ; tar --create --verbose --gzip --file install-update.tar.gz ./local/share/kservices5/ServiceMenus/hello-world/
```

```
### archives used herein

MY_INSTALL_UPDATE_TAR_GZ="install-update.tar.gz"
MY_INSTALL_PROTECT_TAR_GZ="install-protect.tar.gz"
```

```
# a real world scenario (with having hello-world.desktop and hello-world.sh in ./local/share/kservices5/ServiceMenus/ ...

PACKAGE=hello-world

base_dir_user="$HOME/.local"
BASE_INSTALL_DIR="$base_dir_user"
cd "$BASE_INSTALL_DIR"

MY_BUILD_DIR="./kde-store-build"
test -d "$MY_BUILD_DIR" || mkdir "$MY_BUILD_DIR"

find ./share/kservices5/ServiceMenus/$PACKAGE* > $MY_BUILD_DIR/$PACKAGE.files
cd $MY_BUILD_DIR
wget https://github.com/c-hartmann/kde-install.sh/../raw/../install.sh

tar --directory="$BASE_INSTALL_DIR" --create --verbose --gzip --file $MY_INSTALL_UPDATE_TAR_GZ --files-from=$PACKAGE.files
tar --create --verbose --gzip --file install.sh $PACKAGE.tar.gz $MY_INSTALL_UPDATE_TAR_GZ
```

```
# installing files boiles down to (whereever we live in):
$ tar --directory="$BASE_INSTALL_DIR" --extract --verbose --file $MY_INSTALL_UPDATE_TAR_GZ
```

```
### things that can't be accomplished via an archive, go into the extra script
MY_EXTRAS="install-extras.sh"
```

