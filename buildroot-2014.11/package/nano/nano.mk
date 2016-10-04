################################################################################
#
# nano
#
################################################################################

NANO_VERSION_MAJOR = 2.3
NANO_VERSION = $(NANO_VERSION_MAJOR).6
NANO_SITE = http://www.nano-editor.org/dist/v$(NANO_VERSION_MAJOR)
NANO_LICENSE = GPLv3+
NANO_LICENSE_FILES = COPYING
NANO_CONF_OPTS = --without-slang
NANO_DEPENDENCIES = ncurses

ifeq ($(BR2_PACKAGE_NCURSES_WCHAR),y)
	NANO_CONF_ENV += ac_cv_prog_NCURSESW_CONFIG="$(STAGING_DIR)/usr/bin/ncursesw5-config"
else
	NANO_CONF_ENV += ac_cv_prog_NCURSESW_CONFIG=false
	NANO_MAKE_ENV += CURSES_LIB="-lncurses"
endif

ifeq ($(BR2_PACKAGE_FILE),y)
	NANO_DEPENDENCIES += file
else
	NANO_CONF_ENV += ac_cv_lib_magic_magic_open=no
endif

ifeq ($(BR2_PACKAGE_NANO_TINY),y)
	NANO_CONF_OPTS += --enable-tiny
define NANO_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/src/nano $(TARGET_DIR)/usr/bin/nano
endef
endif

$(eval $(autotools-package))
