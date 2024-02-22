$(call PKG_INIT_BIN, 1.8.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=b181e8c78cb31c2bc16b61fcf2425190
$(PKG)_SITE:=https://github.com/tinyproxy/tinyproxy/releases/download/$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/tinyproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tinyproxy

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_TRANSPARENT_PROXY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_FILTER
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_UPSTREAM
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_SOCKS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_REVERSE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_STATIC

$(PKG)_CONFIGURE_ENV += tinyproxy_cv_regex_broken=no

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_TRANSPARENT_PROXY),--enable-transparent,--disable-transparent)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_FILTER),--enable-filter,--disable-filter)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_UPSTREAM),--enable-upstream,--disable-upstream)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_SOCKS),--enable-socks,--disable-socks)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_REVERSE),--enable-reverse,--disable-reverse)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TINYPROXY_DIR) $(if $(FREETZ_PACKAGE_TINYPROXY_STATIC),LDFLAGS=-static) V=1

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TINYPROXY_DIR) clean
	$(RM) $(TINYPROXY_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINYPROXY_TARGET_BINARY)

$(PKG_FINISH)