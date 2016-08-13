#!/bin/bash
# Automatically create the patched qvm files for Smokin' Guns.
set -eux

# download and extract
wget "https://github.com/smokin-guns/SmokinGuns/archive/v1.1.tar.gz"
tar xvf "v1.1.tar.gz"

# patch
for diffile in *.diff; do
	patch -p1 -d "SmokinGuns-1.1/" < "$diffile"
done

# compile and pack qvm
make -j5 -C "SmokinGuns-1.1/"
pushd "SmokinGuns-1.1/build/release-linux-x86_64/smokinguns/"
zip -r "zz_jeuxlinuxfr.pk3" "vm/"
popd

# output
if [ ! -d "pk3/" ]; then
	mkdir "pk3/"
fi

# add qvm to pk3 folder
if [ "$(find 'pk3/' -type f -name 'zz_jeuxlinuxfr_*.pk3')" ]; then
	# find older most recent pk3
	pk3num="$(find 'pk3/' -name 'zz_jeuxlinuxfr_*.pk3' \
		| sed 's#pk3/zz_jeuxlinuxfr_##' \
		| sed 's#\.pk3##' \
		| sort -n \
		| tail -n 1)"
	pk3num="$(($pk3num + 1))"
	pk3num="$(printf %04d%s $pk3num)" # force 4 digits display
	mv "SmokinGuns-1.1/build/release-linux-x86_64/smokinguns/zz_jeuxlinuxfr.pk3" \
		"pk3/zz_jeuxlinuxfr_$pk3num.pk3"
else
	mv "SmokinGuns-1.1/build/release-linux-x86_64/smokinguns/zz_jeuxlinuxfr.pk3" \
		"pk3/zz_jeuxlinuxfr_0000.pk3"
fi

# cleanup
rm -r "SmokinGuns-1.1/"
rm "v1.1.tar.gz"
