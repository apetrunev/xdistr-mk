CUR_DIR = $(shell pwd)

include ../common/gtm.vars

# $(1) -- recent backup dir
# $(2) -- destination dir
define restore_database
	if test -d $(2); then \
		find $(1)/ -mindepth 1 -maxdepth 1 -type f -name "*.dat" -exec cp -vp "{}" $(2)/ \;; \
	else false; fi 
endef

# $(1) -- archive
# $(2) -- destination dir
define restore_routines
	if test -d $(2) && test -f $(1); then \
		tar -C $(2)/ --xattrs --overwrite -xvzpf $(1); \
	else false; fi
endef

# Compile source as gtm system user
# $(1) -- source dir
# $(2) -- destination dir
define compile
	if [ "x$$(getent passwd $(GTM_SUSER) | cut -d: -f1 | grep -o $(GTM_SUSER))" = "x$(GTM_SUSER)" ]; then \
		if test -d $(1) && test -d $(2); then \
			su --login $(GTM_SUSER) -c "cd $(2)/ && find $(1)/ -mindepth 1 -maxdepth 1 -type f -name \"*.m\" -exec mumps \"{}\" + || true"; \
			su --login $(GTM_SUSER) -c "setTerminal default"; \
		fi; \
	else true; fi
endef

mount:
	mkdir -p $(BACKUP_DIR)
	if test -z "$$(findmnt $(BACKUP_DIR) -n -o FSTYPE)"; then \
		mount $(BACKUP_NFS_SHARE) $(BACKUP_DIR) -o ro,nfsvers=3,hard,intr,nolock; \
	else true; fi

umount:
	umount $(BACKUP_DIR) || true

compile:
	$(call compile,$(GTM_DIR)/lib/r,$(GTM_DIR)/lib/o)
	$(call compile,$(GTM_DIR)/iks/r,$(GTM_DIR)/iks/o)

restore:
ifeq ($(BACKUP_PARTITION),mounted)
	# find recent backup
	@$(eval RECENT_BACKUP := $(shell find $(BACKUP_DIR)/ -mindepth 1 -maxdepth 1 -type d -name "iks_*" | sort -r | head -n +1))
	@$(call restore_database,$(RECENT_BACKUP),$(GTM_DIR)/data)
	@find $(GTM_DIR)/data -mindepth 1 -maxdepth 1 -type f -name "*.dat" -exec chown -v :gtm "{}" \;
	@$(call restore_routines,$(RECENT_BACKUP)/iks.tar.gz,$(GTM_DIR)/iks)
	@$(call restore_routines,$(RECENT_BACKUP)/lib.tar.gz,$(GTM_DIR)/lib)
	@$(call compile,$(GTM_DIR)/lib/r,$(GTM_DIR)/lib/o)
	@$(call compile,$(GTM_DIR)/iks/r,$(GTM_DIR)/iks/o)
else
	@echo "#\n# Before restore backup mount nfs share to $(BACKUP_DIR)/ and run 'make install' again.\n#"
	@echo "# EXAMPLE: add the following to /etc/fstab:"
	@echo "# $(BACKUP_NFS_SHARE)\t$(BACKUP_DIR)\tnfs\trw,nfsvers=3,hard,intr,nolock\t0\t0\n#"
endif
