# actions-makepkg

Builds an Arch package from github actions

## Inputs

### `dir`

**Required** 
Absolute path to PKGBUILD directory.

### `command`

Command to run before building.

### `pgpkey`

PGP key to use for signing the package.  
Should be a base64 encoded string.

### `march`

Architecture to build for.  
Defaults to "x86-64".

### `mtune`

Tunes the build for a specific CPU.  
Defaults to "generic".

### `skipruntimedeps`

Boolean that specifies if the script should install runtime dependencies or not.
Might result in a faster build since less packages are downloaded but might not build at all.

### Example
 ```yml
 uses: spacefall/actions-makepkg@main
 with:
   dir: pkg/
   command: "ls ./ && rm -f file" 
   pgpkey: $(base64 /path/to/key.pgp)
   march: x86-64-v2
   mtune: skylake
   skipruntimedeps: false
 ```
