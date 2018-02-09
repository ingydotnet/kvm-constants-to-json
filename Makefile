NAME := kvm-constants

KVM_REPO ?= https://git.kernel.org/pub/scm/virt/kvm/kvm.git
KVM_BRANCH ?= master
KVM := $(PWD)/kvm
KVM_CONSTANT_FILE ?= $(KVM)/include/uapi/linux/kvm.h

KVM_ARCH ?= \
  $(shell uname -m | \
    sed -e s/i.86/x86/ -e s/x86_64/x86/ \
    -e s/sun4u/sparc64/ \
    -e s/arm.*/arm/ -e s/sa110/arm/ \
    -e s/s390x/s390/ -e s/parisc64/parisc/ \
    -e s/ppc.*/powerpc/ -e s/mips.*/mips/ \
    -e s/sh[234].*/sh/ -e s/aarch64.*/arm64/ \
    -e s/riscv.*/riscv/)

KVM_INCLUDE := \
    -I$(KVM)/arch/$(KVM_ARCH)/include/uapi \
    -I$(KVM)/arch/$(KVM_ARCH)/include/generated/uapi \
    -I$(KVM)/include/uapi \
    -I$(KVM)/include/generated/uapi \
    -I$(KVM)/include \
    -include $(KVM)/include/linux/kconfig.h

KVM_OPTS := -Wall $(KVM_INCLUDE)


#------------------------------------------------------------------------------
build: $(NAME)/$(NAME).json

$(NAME)/$(NAME).json: $(NAME)-gen $(NAME)
	./$< > $@
	ln -fs $@ $(NAME)-$(KVM_ARCH)-$(shell shasum $(KVM_CONSTANT_FILE) | cut -c1-8).json
	bin/git-commit-and-tag $(KVM_ARCH) $(shell shasum $(KVM_CONSTANT_FILE) | cut -c1-8)

$(NAME)-gen: $(NAME)-gen.c Makefile kvm/include/generated
	$(CC) $(KVM_OPTS) $< -o $@

$(NAME)-gen.c: bin/$(NAME)-gen-gen.sh $(KVM_CONSTANT_FILE)
	./$^ > $@

$(NAME):
	mkdir -p $@

$(KVM_CONSTANT_FILE): kvm

kvm/include/generated: kvm
	(cd $< && make oldconfig < /dev/null && make prepare)

kvm:
	git clone --depth=1 --branch=$(KVM_BRANCH) $(KVM_REPO) $@

clean:
	rm -f $(NAME)-gen $(NAME)-gen.c $(NAME)-*.json
	rm -fr $(NAME)

# kvm repo takes a long time to clone, so don't clean by default.
distclean: clean
	rm -fr kvm
