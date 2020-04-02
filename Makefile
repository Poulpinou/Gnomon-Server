# [----- PATHES -----]
prefix = $(HOME)
rootPath = $(DESTDIR)$(prefix)/.gnomon-server

# [----- DEPENDENCIES -----]
dependencies = docker docker-compose jq git
K := $(foreach exec,$(dependencies),\
        $(if $(shell which $(exec)),\
		$(exec) found,\
		$(error Gnomon-Servers requires $(exec) to work, please install it) \
	))

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

install: check-dep do-install

check-dep:
	@$(ECHO) Checking dependencies...
	@$(ECHO) Dependencies are valid

do-install: check-dep
	@$(ECHO) Installing Gnomon Server...

	@$(ECHO) Create root path
	@mkdir -p $(rootPath)

	@$(ECHO) Create configs	
	@cp src/.gns-config $(rootPath) \
		&& cp src/.gns-config $(rootPath)/.gns-config.default

	@$(ECHO) Copy directories
	@cp -r src/templates $(rootPath) \
		&& cp -r src/commands $(rootPath) \
		&& cp -r src/utilities $(rootPath) \

	@$(ECHO) Make data folder
	@mkdir -p $(rootPath)/data 

	@test -f $(rootPath)/data/containers.json \
		|| cp src/templates/containers.json.template $(rootPath)/data/containers.json

	@$(ECHO) Make logs folder
	@mkdir -p $(rootPath)/logs

	@$(ECHO) Create gns command
	@mkdir -p $(DESTDIR)$(prefix)/bin \
		&& cp src/gns $(DESTDIR)$(prefix)/bin/gns \
		&& sed -i 's:ROOT_PATH=.*:ROOT_PATH=$(rootPath):g' $(DESTDIR)$(prefix)/bin/gns \
		&& chmod +x $(DESTDIR)$(prefix)/bin/gns

	@$(ECHO) Install done

clean:
	@# Do nothing

distclean: clean

uninstall:
	@$(ECHO) Uninstalling Gnomon Server...

	
	@rm -f $(DESTDIR)$(prefix)/bin/gns \
		&& rm -rf $(rootPath)

	@$(ECHO) Done

.PHONY: all install clean distclean uninstall

endif