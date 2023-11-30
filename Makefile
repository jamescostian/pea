PREFIX?=/usr
BIN=$(PREFIX)/bin

PEA=$(BIN)/pea
PEAD=$(BIN)/pead
PEAT=$(BIN)/peat
CONF=/etc/pea.conf
CHICKPEA=/etc/profile.d/01-chickpea

SERVICE=/usr/lib/systemd/system/pead.service
ALL=$(PEA) $(PEAD) $(PEAT) $(SERVICE) $(CONF)

SHELL:=bash

config:
	@if [[ "$$(wc -l < /etc/crypttab)" != "1" ]]; then echo "you must configure pea.conf yourself"; exit 1; fi
	echo "DISK=/dev/disk/by-uuid/$$(./disk-uuid.sh `awk '{print $$2}' /etc/crypttab`)" > pea.conf
	echo "OTP=/etc/cryptsetup-keys.d/$$(awk '{print $$1}' /etc/crypttab).key" >> pea.conf
	@echo "Optionally, add your passphrase to pea.conf, like DECRYPTION_PASSPHRASE=..."
	@echo "Or, after running make install, you can add it directly to $(CONF)"

check:
	@if [[ ! -f /usr/share/initramfs-tools/hook-functions ]]; then echo "you are missing initramfs-tools, this code will not work for you"; exit 1; fi
	$(info Checking for dependencies...)
	systemctl is-system-running
	@which cryptsetup dd sudo sed awk lsblk blkid update-initramfs

install: check
	mkdir -p /etc/cryptsetup-keys.d
	grep -E '^KEYFILE_PATTERN="/etc/cryptsetup-keys\.d/\*\.key"' /etc/cryptsetup-initramfs/conf-hook > /dev/null || echo 'KEYFILE_PATTERN="/etc/cryptsetup-keys.d/*.key"' >> /etc/cryptsetup-initramfs/conf-hook
	grep -E '^UMASK=' /etc/initramfs-tools/initramfs.conf > /dev/null || echo 'UMASK=0077' >> /etc/initramfs-tools/initramfs.conf
	install peat.sh $(PEAT)
	install pea.sh $(PEA)
	install pead.sh $(PEAD)
	install chickpea.sh $(CHICKPEA)
	cp pea.conf $(CONF)
	sed "s/ExecStart=.*$$/ExecStart=$(subst /,\/,$(PEAD))/" pead.service > $(SERVICE)
	systemctl daemon-reload
	systemctl enable --now pead

uninstall:
	@source $(CONF); if grep "$$OTP" /etc/crypttab > /dev/null; then echo "You cannot uninstall right now - the OTP is set in /etc/crypttab. Uninstalling now would be like permanently decrypting your machine. If you remove the OTP from /etc/crypttab, you must also regenerate initramfs"; exit 1; fi
	systemctl disable --now pead.service || true
	rm -v $(ALL)
	@echo "While pea has been removed from your system, its system-level config changes have not, and neither have files it created for you in /etc/cryptsetup-keys.d. They will not harm anything, but to fully remove all traces of pea, you can remove those files and read through what the Makefile does to undo system-level changes"

.PHONY: config check install uninstall
