#!/bin/bash
rm -rf /tmp/fixlist.pkg
touch /tmp/fixlist.pkg

timestamp() {
    date +"%T"
}

fixpackage() {
    echo "###################";
    echo "# Fixing $pkg ... #";
    echo "###################";
    echo ""
    set -x;
    echo "$pkg" >> /tmp/fixlist.pkg;
    dpkg --force-all --purge "$pkg";
    apt-get install "$pkg";
    set +x;
    echo ""
    echo "############";
    echo "# Done ... #";
    echo "############";
    sleep 15;
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
    verify;
    let count=count+1
done < /tmp/verify.pkg

echo "Done! Packages that need fixing are in /tmp/fixlist.pkg";
