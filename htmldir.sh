echo "<html>" > index.html;
echo "<head>" >> index.html;
pwd | awk '{print "<title>Index of "$1"</title>"}' >> index.html;
echo "</head>" >> index.html;
echo "<body>" >> index.html;
pwd | awk '{print "<h1>Index of "$1"</h1>"}' >> index.html;
echo "<table><tr><th></th><th>Name</th><th>Last modified</th><th>Size</th><th>Description</th></tr><tr><th colspan=\"5\"><hr></th></tr>" >> index.html;
find . -type d | awk '{print "<tr><td valign=\"top\"></td><td><a href=\""$1"\">"$1"/</a></td><td>09-Jul-2013 02:02</td><td>-</td><td></td></tr>"}' >> index.html;
find . -type f | awk \
'{print "<tr><td valign=\"top\"></td><td><a href=\""$1"\">"$1"</a></td><td>09-Jul-2013 02:02</td><td>1.0G</td><td></td></tr>"}' >> index.html;
echo "<tr><th colspan=\"5\"><hr></th></tr>" >> index.html;
echo "</table>" >> index.html;
echo "<address>Apache Server at 192.168.0.100 Port 80</address>" >> index.html;
echo "</body>" >> index.html;
echo "</html>" >> index.html;
