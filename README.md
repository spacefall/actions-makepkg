# actions-makepkg | pkg-db

Takes packages and creates a new repo database on github actions

## Inputs

### `dir`

**Required** 
Absolute path to directory containing packages.

### `reponame`

**Required** 
Name of repository to create.

### Example
 ```yml
 uses: spacefall/actions-makepkg@pkg-db
 with:
   dir: pkg/
   reponame: myrepo
 ```
