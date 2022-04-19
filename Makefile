#
# Makefile for KDE Extension Installer
#

# commented lines for documentation purpose only

# cleanup:
# 	test -f $(PACKAGE).tar.gz && rm $(PACKAGE).tar.gz
# 	test -f install-update.tar.gz & rm install-update.tar.gz
# 	test -f install.sh && rm install.sh
# 	test -f uninstall-extras.sh && rm uninstall-extras.sh

# TODO add uninstall-extras.sh - if present!

# TODO is there something like a soft requirement?

ifndef PACKAGE
PACKAGE = ${notdir $(PWD)}
endif

ifndef PACKAGE
$(error PACKAGE is undefined)
else
$(info building PACKAGE=$(PACKAGE))
endif

# final target to build
TARGET_PACKAGE_ARCHIVE = $(PACKAGE).tar.gz

# files that go into the final target
INSTALL_UPDATE_ARCHIVE = install-update.tar.gz
INSTALL_SCRIPT = install.sh

# a file list to build the install archive
SOURCE_FILES_LIST = PACKAGE.files

# be quiet on building (suppress stdout)
.SILENT: $(TARGET_PACKAGE_ARCHIVE) $(INSTALL_UPDATE_ARCHIVE) # $(INSTALL_SCRIPT)

# ifndef PACKAGE
# $(error PACKAGE is undefined)
# else
# hello-world.tar.gz: install.sh install-update.tar.gz
# $(PACKAGE).tar.gz: install.sh install-update.tar.gz
# foobar.tar.gz: install.sh install-update.tar.gz
$(TARGET_PACKAGE_ARCHIVE): $(INSTALL_UPDATE_ARCHIVE) $(INSTALL_SCRIPT)
	$(info building TARGET=$(TARGET_PACKAGE_ARCHIVE))
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
$(INSTALL_UPDATE_ARCHIVE): $(SOURCE_FILES_LIST)
	$(info building TARGET=$(INSTALL_UPDATE_ARCHIVE))
	tar \
	--create --gzip \
	--directory=${HOME}/.local \
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
