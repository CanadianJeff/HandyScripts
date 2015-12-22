#!/bin/bash
rm -rf /tmp/fixlist.pkg
touch /tmp/fixlist.pkg

timestamp() {
    date +"%T"
}

fixpackage() {
    echo "[$(timestamp)] [$count/$total] Fixing $pkg ...";
    echo "$pkg" >> /tmp/fixlist.pkg;
    dpkg --force-all --purge "$pkg" 1>/dev/null;
    pkg_deb=$(apt-cache show $pkg | awk '$1 ~ /Filename:/ {print $2}' | rev | cut -d'/' -f 1 | rev)
    dpkg --force-all -i /var/cache/apt/archives/"$pkg_deb" 2>&1 >>/tmp/debsums.log;
}

verify() {
    apt-get install --reinstall --download-only "$pkg" 1>/dev/null;
    echo "[$(timestamp)] [$count/$total] Checking $pkg ...";
    debsums -cagp /var/cache/apt/archives "$pkg";
    exit=$?;
    if [[ $exit -ne "0" ]]; then
        fixpackage;
    fi;
}

# Get List Installed Packages
dpkg -l | awk '$1 ~ /ii/ {print $2}' > /tmp/installed.pkg
#Get List Reinstall Packages
dpkg -l | awk '$1 ~ /ri/ {print $2}' > /tmp/reinstall.pkg

cat /tmp/installed.pkg /tmp/reinstall.pkg | sort > /tmp/verify.pkg
sed -i '/^\s*$/d' /tmp/verify.pkg
count=1
total=$(wc -l /tmp/verify.pkg | awk '{print $1}')

while read -r pkg; do
    if [[ $pkg == *":"* ]]; then
        echo "[$(timestamp)] [$count/$total] Arch Package $pkg ...";
        echo $pkg >> /tmp/archlist.pkg;
    else
        verify;
    fi
    let count=count+1
done < /tmp/verify.pkg

echo "Done! Packages that need fixing are in /tmp/fixlist.pkg";
echo "Arch Packages are listed in /tmp/archlist.pkg";
