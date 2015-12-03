#!/bin/bash
rm -rf /tmp/fixlist.pkg
touch /tmp/fixlist.pkg

# Get List Installed Packages
dpkg -l | awk '$1 ~ /ii/ {print $2}' > /tmp/installed.pkg

while read package; do
    echo "Checking $package ...";
    debsums -s $package;
    exit=$?;
    if [[ $exit -eq "2" ]];
        then echo "Adding $package To List ...";
        echo $package >> /tmp/fixlist.pkg
    fi;
done < /tmp/installed.pkg

#Get List Reinstall Packages
dpkg -l | awk '$1 ~ /ri/ {print $2}' > /tmp/reinstall.pkg

while read package; do
    echo "Checking $package ...";
    debsums -s $package;
    exit=$?;
    if [[ $exit -eq "2" ]];
        then echo "Adding $package To List ...";
        echo $package >> /tmp/fixlist.pkg
    fi;
done < /tmp/reinstall.pkg

echo "Done! Packages that need fixing are in /tmp/fixlist.pkg"
