#!/bin/bash

constant_file=$1

cat <<...
#include <stdio.h>
#include <linux/kvm.h>

int main(void)
{
    printf("{\n");
...

grep '^#define KVM_' $constant_file |
# XXX The lines matching these patterns had errors:
grep -v KVM_S390_ |
grep -v KVM_COALESCED_MMIO_MAX |
grep -v 'KVMIO, \+0xa[89acef],' |
grep -v 'KVMIO, \+0xb[01],' |
(
  started=false
  while read line; do
    if $started; then
      echo "    printf(\",\n\");"
    else
      started=true
    fi

    if [[ $line =~ (KVM_[A-Z0-9_]+) ]]; then
      name="${BASH_REMATCH[1]}"
    else
      echo "bad line: $line"
      exit 1
    fi

    echo '    printf("    \"%s\": %lu", "'$name'", (unsigned long)'$name');'
  done
) || exit $?

cat <<...
    printf("\n}\n");

    return 0;
}
...
