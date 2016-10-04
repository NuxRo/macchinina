################################################################################
#
# upmpdcli
#
################################################################################

UPMPDCLI_VERSION = 0.8.6
UPMPDCLI_SITE = http://www.lesbonscomptes.com/upmpdcli/downloads
UPMPDCLI_LICENSE = GPLv2+
UPMPDCLI_LICENSE_FILES = COPYING
UPMPDCLI_DEPENDENCIES = libmpdclient libupnpp

# Upmpdcli only runs if user upmpdcli exists
define UPMPDCLI_USERS
	upmpdcli -1 upmpdcli -1 * - - - Upmpdcli MPD UPnP Renderer Front-End
endef

define UPMPDCLI_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/upmpdcli/S99upmpdcli $(TARGET_DIR)/etc/init.d/S99upmpdcli
endef

define UPMPDCLI_INSTALL_CONF_FILE
	$(INSTALL) -D -m 0755 $(@D)/src/upmpdcli.conf $(TARGET_DIR)/etc/upmpdcli.conf
endef

UPMPDCLI_POST_INSTALL_TARGET_HOOKS += UPMPDCLI_INSTALL_CONF_FILE

$(eval $(autotools-package))
