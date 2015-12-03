#/bin/sh

echo "#EXTM3U";

curl -s http://listen.di.fm/premium | grep -o '"key":"[^"]*"' | sed 's/"key":"\([^"]*\)"/\1/g' | sort | awk '{print "#EXTINF:-1,DI.FM - "$1"\nhttp://listen.di.fm/premium/"$1".pls?KEY"}' | KEY=""; sed 's/KEY/$KEY/g'
