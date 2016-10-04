################################################################################
#
# inadyn
#
################################################################################

INADYN_VERSION = 1.99.12
INADYN_SITE = https://github.com/troglobit/inadyn/releases/download/$(INADYN_VERSION)
INADYN_SOURCE = inadyn-$(INADYN_VERSION).tar.xz
INADYN_LICENSE = GPLv2+
INADYN_LICENSE_FILES = COPYING

ifeq ($(BR2_PACKAGE_OPENSSL),y)
INADYN_CONF_OPTS += --enable-openssl
INADYN_DEPENDENCIES += openssl
else ifeq ($(BR2_PACKAGE_GNUTLS),y)
INADYN_DEPENDENCIES += gnutls
else
INADYN_CONF_OPTS += --disable-ssl
endif

define INADYN_INSTALL_SAMPLE_CONFIG
	@if [ ! -f $(TARGET_DIR)/etc/inadyn.conf ]; then \
		$(INSTALL) -D -m 0600 package/inadyn/inadyn.conf \
			$(TARGET_DIR)/etc/inadyn.conf; \
	fi
endef
INADYN_POST_INSTALL_TARGET_HOOKS += INADYN_INSTALL_SAMPLE_CONFIG

define INADYN_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/inadyn/S70inadyn \
		$(TARGET_DIR)/etc/init.d/S70inadyn
endef

$(eval $(autotools-package))
