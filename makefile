# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS, gcarq
# https://github.com/tbds/FreeContributor
# https://github.com/gcarq/FreeContributor (forked)
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

include config.mk

all:

dist:
	@echo creating dist tarball
	@mkdir -p FreeContributor-${VERSION}
	@cp -R LICENSE README.md CONTRIBUTING.md makefile config.mk utils conf data examples FreeContributor.sh FreeContributor-${VERSION}
	@tar -cf FreeContributor-${VERSION}.tar FreeContributor-${VERSION}
	@gzip FreeContributor-${VERSION}.tar
	@rm -rf FreeContributor-${VERSION}

install: all
	@echo installing FreeContributor-${VERSION} to ${PREFIX}
	@cp -f FreeContributor.sh ${PREFIX}
	@chmod 755 ${PREFIX}/FreeContributor.sh
	@cp -R conf utils ${PREFIX}

uninstall:
	@echo removing FreeContributor-${VERSION} from ${PREFIX}
	@rm -f ${PREFIX}/FreeContributor.sh
	@rm -rf ${PREFIX}/{conf,utils}

.PHONY: all dist install uninstall
