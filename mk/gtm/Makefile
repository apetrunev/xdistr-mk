CUR_DIR := $(shell pwd)

include ../common/gtm.vars

DOWNLOAD := /tmp/Gtm

.PHONY: all clean

all: help

help:
	@echo "help: make intall"

# $(1) -- dir
# $(2) -- link
define xwget
        test -f $(1)/`basename $(2)` || wget -P $(1) $(2)
endef

# $(1) -- group name
define addGtmSystemGroup
	if [ "x$$(getent group $(1) | cut -d: -f1 | grep -o $(1))" = "x$(1)" ]; then \
		echo "$(1) group already exists"; \
	else \
		addgroup --system $(1); \
	fi
endef

# $(1) -- user name
# $(2) -- gtm group
# $(3) -- home directory
# $(4) -- shell
define addGtmSystemUser
	if [ "x$$(getent passwd $(1) | cut -d: -f1 | grep -o $(1))" = "x$(1)" ]; then \
		echo "$(1) user already exists"; \
	else \
		useradd --system -s $(4) -d $(3) -g $(2) -m $(1); \
	fi
endef

# $(1) -- user name
# $(2) -- gtm group
# $(3) -- home directory
# $(4) -- shell
define addGtmUser
	if [ "x$$(getent passwd $(1) | cut -d: -f1 | grep -o $(1))" = "x$(1)" ]; then \
		echo "$(1) user already exists"; \
	else \
		useradd -s $(4) -d $(3) -g $(2) -m $(1) && chage --expiredate -1 $(1); \
	fi
endef

# $(1) -- user name
define setEmptyPassword
	if [ "x$$(getent passwd $(1) | cut -d: -f1 | grep -o $(1))" = "x$(1)" ]; then \
		passwd -d $(1); \
	else  true; fi  
endef

# $(1) -- directory
define mkDir
	if [ ! -d $(1) ]; then \
		mkdir -p $(1); \
	else \
		echo "directory $(1) already exists"; \
	fi
endef

define logindRemoveIPCno
	$(eval TMP := $(shell mktemp --tmpdir)) \
	awk '{ \
		if ($$0 ~ /RemoveIPC=.*/) \
		{ \
			print "# GT.M : Override systemd default of RemoveIPC=yes to prevent automatic ipc removal of Shared Memory Segments and Semaphore Arrays of orphaned databases"; \
			print "RemoveIPC=no"; \
		} else { \
			print; \
		} \
	}' /etc/systemd/logind.conf > $(TMP)
	mv -v $(TMP) /etc/systemd/logind.conf
endef

define addUserToSudo
	if [ "x$$(getent passwd $(1) | cut -d: -f1 | grep -o $(1))" = "x$(1)" ]; then \
		usermod -a -G sudo $(1); \
	else true; fi
endef

createGtmSUser:
	@$(call addGtmSystemGroup,$(GTM_SGROUP))
	@$(call addGtmSystemUser,$(GTM_SUSER),$(GTM_SGROUP),$(GTM_DIR),"/bin/bash")

createGtmDirs:
	@$(call mkDir,$(GTM_DIR))
	@$(call mkDir,$(GTM_DIR)/iks)
	@$(call mkDir,$(GTM_DIR)/iks/r)
	@$(call mkDir,$(GTM_DIR)/iks/o)
	@$(call mkDir,$(GTM_DIR)/lib)
	@$(call mkDir,$(GTM_DIR)/lib/r)
	@$(call mkDir,$(GTM_DIR)/lib/o)
	@$(call mkDir,$(GTM_DIR)/data)
	@$(call mkDir,$(GTM_DIR)/temp)
	@$(call mkDir,$(GTM_DIR)/users)
	@$(call mkDir,$(GTM_BACKUP_DIR))
	@$(call mkDir,$(PFS_DIR))

sudoNOPASSWD:
	@if test -d /etc/sudoers.d; then \
		find $(CUR_DIR)/sudoers.d/ -maxdepth 1 -type f -exec /bin/sh -c "chmod -v 0440 \"{}\" && cp -v \"{}\" /etc/sudoers.d/" \;; \
		touch $@; \
	fi

installGtm: createGtmSUser createGtmDirs sudoNOPASSWD
ifeq ($(GTM_DATA_PARTITION),mounted)
	@$(call mkDir,$(GTM_DIR)/data/mjl)
ifeq ($(GTM_DATA_MJL_PARTITION),mounted)
	@$(call mkDir,$(DOWNLOAD))
	@$(call xwget,$(DOWNLOAD),$(GTM_LINK))
	@$(call mkDir,$(DOWNLOAD)/Distr)
	@tar -C $(DOWNLOAD)/Distr --xattrs -xvzpf $$(find $(DOWNLOAD) -maxdepth 1 -type f -name "*.tar.gz" -print)
	@$(call logindRemoveIPCno)
	@cd $(DOWNLOAD)/Distr && ./gtminstall --verbose --user $(GTM_SUSER) --group $(GTM_SGROUP) --keep-obj --overwrite-existing --installdir $(GTM_DIR)
	@chown -v $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR) && chmod -v 775 $(GTM_DIR)
	@chown -vR $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR)/iks && chmod -vR 775 $(GTM_DIR)/iks
	@chown -vR $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR)/lib && chmod -vR 775 $(GTM_DIR)/lib
	@chown -vR $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR)/data && chmod -vR 775 $(GTM_DIR)/data
	@chown -v $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR)/temp && chmod -v 775 $(GTM_DIR)/temp
	@chown -v $(GTM_SUSER):$(GTM_SGROUP) $(GTM_DIR)/users && chmod -v 755 $(GTM_DIR)/users
	@chown -v $(GTM_SUSER):$(GTM_SGROUP) $(PFS_DIR) && chmod -v 777 $(PFS_DIR)
	@$(call addGtmUser,"ooo",$(GTM_SGROUP),"$(GTM_DIR)/users/ooo","/bin/bash")
	@$(call addGtmUser,"test",$(GTM_SGROUP),"$(GTM_DIR)/users/test","/bin/bash")
	@$(call addGtmUser,"kronemu-net",$(GTM_SGROUP),"$(GTM_DIR)/users/kronemu-net","/bin/bash")
	@$(call addGtmUser,"gtm_app",$(GTM_SGROUP),"$(GTM_DIR)/users/gtm_app","/bin/bash")
	@$(call addGtmUser,"adm_gtm",$(GTM_SGROUP),"$(GTM_DIR)/users/adm_gtm","/bin/bash")
	@$(call addGtmUser,"gtm_lab",$(GTM_SGROUP),"$(GTM_DIR)/users/gtm_lab","/bin/bash")
	@$(call setEmptyPassword,"gtm")
	@$(call setEmptyPassword,"ooo")
	@$(call setEmptyPassword,"kronemu-net")
else
	@echo "#"
	@echo "# STEP 2"
	@echo "# Mount partition to $(GTM_DIR)/data/mjl and run 'make install' again."
	@echo "# EXAMPLE: add the following to /etc/fstab:"
	@echo "# /dev/sdc1\t/usr/gtm/data/mjl\text4\tdefaults,discard,relatime\t0\t0"
	@echo "#"
endif
else
	@echo "#"
	@echo "# STEP 1"
	@echo "# Mount partition to $(GTM_DIR)/data and run 'make install' again."
	@echo "# EXAMPLE: add the following to /etc/fstab:"
	@echo "# /dev/sdb1\t/usr/gtm/data\text4\tdefaults\t0\t0"
	@echo "#"
endif

install: installGtm
clean:
	@if test -f sudoNOPASSWD; then rm -v sudoNOPASSWD; fi
