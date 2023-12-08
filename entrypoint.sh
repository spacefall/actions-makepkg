#!/usr/bin/env bash
set -e

directory=$(readlink "/github/workspace/$1" -f)
command=$2
pgpkey=$3

march=$4
mtune=$5

# Makepkg.conf edits
sudo sed -i 's/COMPRESSZST=(zstd -c -z -q -)/COMPRESSZST=(zstd -c -z -q -T0 -)/g' /etc/makepkg.conf
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(nproc)'"/g' /etc/makepkg.conf;
sudo sed -i 's/!lto/lto/g' /etc/makepkg.conf;
sudo sed -i 's/-fcf-protection/-fcf-protection -fuse-ld=mold -ftree-vectorize/g' /etc/makepkg.conf;
sudo sed -i 's/#RUSTFLAGS="-C opt-level=2"/RUSTFLAGS="-C opt-level=2 -C strip=symbols -C link-arg=-fuse-ld=mold -C target-cpu='$march'"/g' /etc/makepkg.conf;

sudo sed -i 's/-march=x86-64/-march='$march'/g' /etc/makepkg.conf;
sudo sed -i 's/-mtune=generic/-mtune='$mtune'/g' /etc/makepkg.conf;

if [[ ! -d $directory ]]; then
    echo "$directory should be a directory."
    exit 1
fi

if [[ ! -e $directory/PKGBUILD ]]; then
    echo "$directory does not contain a PKGBUILD file."
    exit 1
fi

sudo chown -R builder "$directory"
cd $directory

# Makes a copy of the source directory
#echo "* Copy PKGBUILD ..."
#echo "* Copying source directory"
#rsync -av --exclude=".*" $directory /tmp/pkg/
#cd /tmp/pkg

# Install dependencies using yay
echo "* Installing dependencies"
#yay -Syu --noconfirm --ignore filesystem
yay -S --noconfirm $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${checkdepends[@]} ${makedepends[@]}))

# Import PGP key if available
if [[ -n "$pgpkey" ]]
then
  echo "* Importing PGP key"
  echo "$pgpkey" | base64 -d | gpg --import -
  echo "* Initializing lsign-key"
  pacman-key --init
fi

# Run commands
if [[ -n "$command" ]]
then
  echo "* Running pre-build commands"
  echo "${command}" > /tmp/cmd.sh
  bash /tmp/cmd.sh
fi 

# Build
echo "* Building"
# If $pgpkey is empty, don't sign the package
[ -n "$pgpkey" ] && makepkg --syncdeps --noconfirm --sign || makepkg --syncdeps --noconfirm

# Checking
echo "* Verifying package"
source /etc/makepkg.conf # get PKGEXT
namcap "${pkgname}"*"${PKGEXT}"
pacman -Qip "${pkgname}"*"${PKGEXT}"
pacman -Qlp "${pkgname}"*"${PKGEXT}"

#echo "* Moving back provided package"
#sudo chown $(stat -c '%u:%g' $directory/PKGBUILD) ./*.pkg.tar.*
#sudo mv ./*.pkg.tar.* $directory
