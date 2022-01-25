CUR_DIR := $(shell pwd)

include ../common/gtm.vars

all: install

install:
ifeq ($(GTM_DATA_PARTITION),mounted)
ifeq ($(GTM_DATA_MJL_PARTITION),mounted)
	@if ! test -d $(PFS_DIR); then false; fi
	@if test "x$$(dpkg -l | grep samba | awk '{ print $$2 }' | grep -E '^samba$$')" != "xsamba"; then false; fi
	@if ! test -d /etc/samba; then false; fi
	@if ! test -f /etc/samba/smb.conf.orig; then \
		cp -v /etc/samba/smb.conf /etc/samba/smb.conf.orig; \
	 else true; fi
	@cp -v $(CUR_DIR)/smb.conf /etc/samba/smb.conf
endif
endif
