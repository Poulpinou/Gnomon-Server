# [----- PATHES -----]
prefix = /usr/local
rootPath = $(DESTDIR)$(prefix)/gnomon-server
binPath = $(DESTDIR)/usr/bin

# [----- DEPENDENCIES -----]
dependencies = docker docker-compose jq git
K := $(foreach exec,$(dependencies),\
        $(if $(shell which $(exec)),\
		$(exec) found,\
		$(error Gnomon-Servers requires $(exec) to work, please install it) \
	))

# [----- CHECKS -----]
fakeroot_key := $(FAKEROOTKEY)

# Check rc.local
rc_local := $(cat /etc/rc.local | grep '$(rootPath)/gns-boot.sh')

# [----- PROGRESS DISPLAY -----]
ifneq ($(words $(MAKECMDGOALS)),1)
.DEFAULT_GOAL = all
%:
        @$(MAKE) $@ --no-print-directory -rRf $(firstword $(MAKEFILE_LIST))
else
ifndef ECHO
T := $(shell $(MAKE) $(MAKECMDGOALS) --no-print-directory \
      -nrRf $(firstword $(MAKEFILE_LIST)) \
      ECHO="COUNTTHIS" | grep -c "COUNTTHIS")

N:= x
C = $(words $N)$(eval N := x $N)
ECHO = echo -ne "\r\033[1A\033[0K|`expr '\033[0;32;42m'`$N`expr '\033[0m'`|`expr " [\`expr $C '*' 100 / $T\`" : '.*\(....\)$$'`%]"
endif

# [----- TARGETS -----]
all: install

fakeroot:
	@$(ECHO) Faking root
ifeq ("$(fakeroot_key)","")
	fakeroot $(DESTDIR)
endif
	@$(ECHO) Fakeroot done

install: fakeroot
	@$(ECHO) Installing Gnomon Server...

	@$(ECHO) Create root path
	@sudo mkdir -p $(rootPath)

	@$(ECHO) Create configs	
	@sudo cp src/.gns-config $(rootPath) \
		&& cp src/.gns-config $(rootPath)/.gns-config.default

	@$(ECHO) Copy directories
	@sudo cp -r src/templates $(rootPath) \
		&& cp -r src/commands $(rootPath) \
		&& cp -r src/utilities $(rootPath) 

	@$(ECHO) Make data folder
	@sudo mkdir -p $(rootPath)/data 

	@test -f $(rootPath)/data/containers.json \
		|| sudo cp src/templates/containers.json.template $(rootPath)/data/containers.json

	@$(ECHO) Make logs folder
	@sudo mkdir -p $(rootPath)/logs

	@$(ECHO) Create gns command
	@sudo mkdir -p $(binPath) \
		&& cp src/gns $(binPath)/gns \
		&& sed -i 's:ROOT_PATH=.*:ROOT_PATH=$(rootPath):g' $(binPath)/gns \
		&& chmod +x $(binPath)/gns

	@$(ECHO) Add start on boot file
	@sudo cp src/gns-boot.sh $(rootPath)

	@$(ECHO) Modify rc.local
ifneq ("$(wildcard $(PATH_TO_FILE))","") 
ifeq ($(rc_local),) 
	@sudo echo -e "bash $(rootPath)/gns-boot.sh" >> /etc/rc.local 
endif 
else 
	@sudo echo -e "bash $(rootPath)/gns-boot.sh\nexit 0" > /etc/rc.local \
		&& chmod +x /etc/rc.local 
endif	

	@$(ECHO) Install done

clean:
	@# Do nothing

distclean: clean

uninstall: fakeroot
	@$(ECHO) Uninstalling Gnomon Server...

	
	@sudo rm -f $(binPath)/gns \
		&& rm -rf $(rootPath)

	@$(ECHO) Done

.PHONY: all install clean distclean uninstall

endif