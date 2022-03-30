#
# Makefile for KDE Extension Installer
#

# commented lines for documentation purpose only

$(PACKAGE).tar.gz: install.sh uninstall.sh install-update.tar.gz
# hello-world.tar.gz: install.sh uninstall.sh install-update.tar.gz
ifndef PACKAGE
	$(error PACKAGE is undefined)
else
	tar \
	--create --verbose --gzip \
	--file hello-world.tar.gz \
	$^
# 	./install.sh \
# 	./uninstall.sh \
# 	./install-update.tar.gz
endif

install-update.tar.gz: $(PACKAGE).files
# install-update.tar.gz: hello-world.files
ifndef PACKAGE
	$(error PACKAGE is undefined)
else
	tar \
	--create --verbose --gzip \
	--directory=${HOME}/.local \
	--file install-update.tar.gz \
	--files-from=$<
# 	--files-from=hello-world.files
endif

uninstall.sh: install.sh
	ln -sf $< $@
# 	ln -sf install.sh uninstall.sh

install.sh:
	wget -q "https://raw.githubusercontent.com/c-hartmann/kde-install.sh/main/install.sh"
