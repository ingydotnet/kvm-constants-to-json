kvm-constants-to-json
=====================

This repo will generate a JSON file of constants from
https://git.kernel.org/pub/scm/virt/kvm/kvm.git/tree/include/uapi/linux/kvm.h

# Synopsis
```
make build
cat kvm-constants-*.json
```

See Makefile for possible env vars to override.

# Description

The generated JSON file of constants is dependent on your local architecture
and the content of the kvm `include/uapi/linux/kvm.h` file.

The file is named `kvm-constants/kvm-constants.json` and a symlink is created
called `kvm-constants-<arch>-<sha1-of-uapi/linux/kvm.h>.json`.

Also a git tag to a single commit containing the JSON file is created called
`<arch>-<sha1-of-uapi/linux/kvm.h>`.

# Dedication

for Wendy Darling

# Author

[Ingy döt Net](http://github.com/ingydotnet)

# License

Copyright © 2018, Ingy döt Net. Released under the MIT License.
