# file dsf-patch.mk - keeping patches against single files
# $Id: dsf-patch.mk,v 1.1.1.1 2005/06/13 17:21:58 frank Exp $
#
# dsf-patch stands for "Debian single file patch system"
# 
# this file is meant to be included from debian/rules,
# and will itself include the file specified in $(DSF-PATCHLIST)
#
# Copyright (C) 2005 by Frank Küster <frank@kuesterei.ch>. 
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
#
# This file is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to: The Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
# On Debian GNU/Linux System you can find a copy of the GNU General Public
# License in "/usr/share/common-licenses/GPL".

# the following can be used to recreate or update the patches. 
# 
# First the patches should be applied by running debian/rules edit-*
# or edit-patches. Then do the edits, then call debian/rules patches
# or patch-*. Afterwards, clean is a good idea before committing

# define variables, may be overridden in $(DSF-PATCHLIST)
stampdir = stampdir
patchdir = debian/patches
patchopts = -p0 -N
SHELL = /bin/bash

# include the local patch specification
include $(DSF-PATCHLIST)

# compute names for auxiliary targets
apply-patchnames = $(foreach patchname,$(patchnames), apply-$(patchname))
unapply-patchnames = $(foreach patchname,$(patchnames), unapply-$(patchname))
edit-patchnames =  $(foreach patchname,$(patchnames), edit-$(patchname))
create-patchnames =  $(foreach patchname,$(patchnames), create-$(patchname))
apply-stamps = $(foreach patchname,$(patchnames),$(stampdir)/apply-$(patchname)-stamp)
unapply-nostamps = $(foreach patchname,$(patchnames),$(stampdir)/unapply-$(patchname))
edit-stamps = $(foreach patchname,$(patchnames),$(stampdir)/edit-$(patchname)-stamp)
patch-stamp-prereq = $(foreach patchname,$(build-patches), $(stampdir)/apply-$(patchname)-stamp)

# compute names of stamps to remove after recreating
$(foreach patch,$(patchnames), \
   $(eval \
$(stampdir)/create-$(patch): my-edit-stamp = $(stampdir)/edit-$(patch)-stamp \
    ) \
)

after-create-targets = nothing
after-unapply-targets = nothing

THISMAKE = $(MAKE) -i -f debian/rules.d/dsf-patch.mk
DSF_FUNC = debian/rules.d/dsf-patchfunc

# compute dependency prerequesites



## main targets:

# applying all patches for package build
patch-stamp: $(patch-stamp-prereq)
	touch patch-stamp

# applying a patch
$(apply-patchnames): %: $(stampdir)/%-stamp

# unapplying a patch
$(unapply-patchnames): %: $(stampdir)/%

# for editing patches
$(edit-patchnames): %: $(stampdir)/%-stamp

# for recreating a patch after editing
$(create-patchnames): %: $(stampdir)/%

## auxiliary targets:

# needed for calls of $(THISMAKE) $(somevariable), where somevariable may be empty
nothing:
	:

# create stampdir if necessary
$(stampdir):
	-mkdir $(stampdir)
	# on fast systems, the generated files might end up to be not-older than stampdir. Really?
	sleep 2

# applying a patch
$(apply-stamps): $(stampdir)/apply-%-stamp: $(patchdir)/% $(apply-prereq)
	patch $(patchopts) -i $<
	touch $@

# unapplying a patch
$(unapply-nostamps): $(stampdir)/unapply-%: $(patchdir)/% $(stampdir)/apply-%-stamp
	patch $(patchopts) -R -i $<
	rm $(stampdir)/apply-$*-stamp

# edit a patch
$(stampdir)/setup-edit-patches-stamp: $(stampdir)
	$(MAKE) -f debian/rules clean
	touch $@

$(edit-stamps): $(stampdir)/edit-%-stamp: $(stampdir)/setup-edit-patches-stamp $(edit-prereq)
$(edit-stamps): $(stampdir)/edit-%-stamp: $(patchdir)/%.files
	for file in `cat $<`; do cp $$file{,.orig}; done
	-$(THISMAKE) apply-$*
	touch $@

# recreate a patch
$(stampdir)/create-%: $(patchdir)/%.files
	-mv $(patchdir)/$* $(patchdir)/$*.old
	for file in `cat $<`; do echo "comparing $$file"; diff -u $$file{.orig,} >> $(patchdir)/$* || true; done 
	patch $(patchopts) -Ri $(patchdir)/$*
	rm $(my-edit-stamp)
	$(THISMAKE) nothing $(post-create-targets)

# for the general clean target
clean-patches: 
	# the first command will wait for user input if there are edit stamps,
	# in order to allow to stop the cleaning. A Debian source package should
	# never contain edit stamps, therefore it should clean without stop.
	test ! -f $(stampdir)/edit-*-stamp || $(patchclean-error)
	-rm $(stampdir)/edit-*-stamp
	-rm $(stampdir)/setup-edit-patches-stamp
# first unapply patches that depend on other patches
	for patch in $(patches_with_prereq); do \
	   if [ -f $(stampdir)/apply-$$patch-stamp ]; then $(THISMAKE) unapply-$$patch; fi; \
	done
# unapply remaining patches with stamp
	for patch in `ls $(stampdir)/apply-*-stamp | sed -e 's@$(stampdir)/apply-\(.*\)-stamp@\1@'`; do \
	   $(THISMAKE) unapply-$$patch; \
	done
	-find . -name "*.orig.?" | xargs rm
	-rm patch-stamp

## compute dependencies between patches:

# for applying a patch, all depended-on patches must be applied first:
$(foreach patch, $(patches_with_prereq), \
    $(eval \
$(stampdir)/apply-$(patch)-stamp: apply-prereq = \
	$(foreach dep,$(patch-tds_prerequisites),apply-$(dep) ) \
     ) \
)
# for editing a patch, all depended-on patches must also be applied first:
$(foreach patch, $(patches_with_prereq), \
    $(eval \
$(stampdir)/edit-$(patch)-stamp: edit-$(patch)-prereq = apply-$(patch)-rereq \
     ) \
)
# after recreating a patch, all depended-on patches must be unapplied. 
# Therefore, we define a target-specific variable $(post-create-targets):
$(foreach patch, $(patches_with_prereq), \
    $(eval \
$(stampdir)/create-$(patch): post-create-targets = \
	$(foreach dep,$(patch-tds_prerequisites),unapply-$(dep) ) \
     ) \
)


# definitions
define patchclean-error
	(echo;\
	echo 'Found edit-*-stamp file in $(stampdir)'; \
	echo 'Please recreate patches before cleaning the source tree!'; \
	echo; \
	read)
endef

