# check-package:
# ifndef PACKAGE
# $(error PACKAGE is undefined)
# else

# hello-world.tar.gz: install.sh uninstall.sh install-update.tar.gz
$(PACKAGE).tar.gz: install.sh uninstall.sh install-update.tar.gz
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

# install-update.tar.gz: hello-world.files
install-update.tar.gz: $(PACKAGE).files
ifndef PACKAGE
	$(error PACKAGE is undefined)
else
	tar \
	--create --verbose --gzip \
	--directory=${HOME}/.local \
	--file install-update.tar.gz \
	--files-from=$<
endif

uninstall.sh: install.sh
	ln -sf $< $@

install.sh:
	wget -q "https://raw.githubusercontent.com/c-hartmann/kde-install.sh/main/install.sh"
