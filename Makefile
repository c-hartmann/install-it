#
# Makefile for KDE Extension Installer
#

# commented lines for documentation purpose only

# TODO integrate install-protect package.
#      by a comand switch: protect=true ?
#      or an extra (i.e. not default) target?

ifndef PACKAGE
PACKAGE = ${notdir $(PWD)}
endif

ifndef PACKAGE
$(error PACKAGE is undefined)
else
$(info PACKAGE: $(PACKAGE))
endif

# final target to build
TARGET_PACKAGE_ARCHIVE = $(PACKAGE).tar.gz

# files that go into the final target
INSTALL_UPDATE_ARCHIVE = install-update.tar.gz
INSTALL_PROTECT_ARCHIVE = install-protect.tar.gz
INSTALL_SCRIPT = install.sh
ALL_SCRIPTS = $(wildcard *.sh)

# a file list to build the install archive
INSTALL_UPDATE_FILES = PACKAGE.files

# install package is build from
BUILD_WORKING_DIR = ${HOME}/.local

# be quiet on building (suppress stdout)
.SILENT: $(TARGET_PACKAGE_ARCHIVE) $(INSTALL_UPDATE_ARCHIVE) clean

# hello-world.tar.gz: install.sh install-update.tar.gz
# $(PACKAGE).tar.gz: install.sh install-update.tar.gz
$(TARGET_PACKAGE_ARCHIVE): $(INSTALL_UPDATE_ARCHIVE) $(ALL_SCRIPTS)
	$(info building PACKAGE-TARGET: $(TARGET_PACKAGE_ARCHIVE))
	tar \
	--create --gzip \
	--file $@ \
	$^
# 	--file $(PACKAGE).tar.gz \
# 	./install.sh \
# 	./uninstall.sh \
# 	./install-update.tar.gz
# endif

# install-update.tar.gz: hello-world.files
# install-update.tar.gz: $(PACKAGE).files
# install-update.tar.gz: PACKAGE.files
# $(INSTALL_UPDATE_ARCHIVE): PACKAGE.files
$(INSTALL_UPDATE_ARCHIVE): $(INSTALL_UPDATE_FILES)
	$(info building INSTALL-TARGET: $(INSTALL_UPDATE_ARCHIVE))
	tar \
	--create --gzip \
	--directory=$(BUILD_WORKING_DIR) \
	--file $@ \
 	--files-from=$<
# 	--file install-update.tar.gz \
# 	--files-from=hello-world.files

# REMOVED: as servicemenuinstaller fails on symbolic links
# uninstall.sh: install.sh
#	ln -sf $< $@
# 	ln -sf install.sh uninstall.sh

# servicemenuinstaller do not fail on hardlinks
# removed anyway, as this is considered being not transparent to users
# uninstall.sh: install.sh
#	ln -f $< $@
# 	ln -f install.sh uninstall.sh

# install.sh:
$(INSTALL_SCRIPT):
	$(info GETTING FILE=$@)
# 	cp ~/Entwicklung/KDE/Dolphin/Service\ Menus/Installer/kde-install.sh/install.sh .
	wget -q "https://raw.githubusercontent.com/c-hartmann/kde-install.sh/main/install.sh"

# extra target clean to remove targets before a new build
clean:
	$(info removing target files)
	rm -f $(PACKAGE).tar.gz
	rm -f $(INSTALL_UPDATE_ARCHIVE)
	rm -f $(INSTALL_PROTECT_ARCHIVE)

