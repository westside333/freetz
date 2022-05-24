$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_OPENVPN_VERSION_ABANDON),2.4.12,2.5.6))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=7426b99b2058b942552af2680ee58546fbf63712992557328bd0014093aa7da4
$(PKG)_HASH_CURRENT:=13c7c3dc399d1b571cabf189c4d34ae34656ee72b6bde2a8059c1e9bc61574ed
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_OPENVPN_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://swupdate.openvpn.net/community/releases,https://build.openvpn.net/downloads/releases
### WEBSITE:=https://openvpn.net/community-downloads/
### CHANGES:=https://community.openvpn.net/openvpn/wiki/ChangesInOpenvpn25
### CVSREPO:=https://github.com/OpenVPN/openvpn

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_OPENVPN_VERSION_ABANDON),abandon,current)
ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_WITH_TRAFFIC_OBFUSCATION)),y)
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_OPENVPN_VERSION_ABANDON),abandon,current)/obfuscation
endif

$(PKG)_BINARY:=$($(PKG)_DIR)/src/openvpn/openvpn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/openvpn

$(PKG)_STARTLEVEL=81

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_OPENSSL),openssl)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),mbedtls)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),lzo)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZ4),lz4)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_VERSION_CURRENT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZ4
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_TRAFFIC_OBFUSCATION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_MGMNT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_USE_IPROUTE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_path_IFCONFIG=/sbin/ifconfig
$(PKG)_CONFIGURE_ENV += ac_cv_path_IPROUTE=/sbin/ip
$(PKG)_CONFIGURE_ENV += ac_cv_path_ROUTE=/sbin/route

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS|LIBS)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
$(PKG)_EXTRA_LDFLAGS += $(if $(FREETZ_PACKAGE_OPENVPN_STATIC),-all-static)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/openvpn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),--enable-lzo,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZ4),--enable-lz4,--disable-lz4)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-multihome
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += --disable-port-share
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --disable-pkcs11
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_OPENSSL),--with-crypto-library=openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),--with-crypto-library=mbedtls)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_USE_IPROUTE),--enable-iproute2)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENVPN_DIR) \
		EXTRA_CFLAGS="$(OPENVPN_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(OPENVPN_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(OPENVPN_EXTRA_LIBS)" \
		SOCKETS_LIBS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENVPN_DIR) clean
	$(RM) $(OPENVPN_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENVPN_TARGET_BINARY)

$(PKG_FINISH)
