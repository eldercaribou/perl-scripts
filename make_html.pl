#!/usr/bin/perl -w

# created 11/22/00 for makeing web pages out of directories of pictures
# (C) 1999 by Brian Manning <brian@sunset-cliffs.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA 

@filedir= <*.jpg>;
$start = time;
$counter = 0;
$row = 1;
$column = 1;

open (OUT, "> index.html");

print OUT "<HTML>\n<HEAD>\n";
print OUT "<TITLE>JPEG Images</TITLE>\n</HEAD>\n";
print OUT "<BODY BGCOLOR=\"#ffffff\">\n\n";

print OUT "<H3>Full size pictures take the longest to download<BR>\n";
print OUT "Half-size pictures take 1/2 as long :)</H3>\n";

print OUT "<TABLE BORDER=0 WIDTH=\"90%\">";
print OUT "<TR>\n";

foreach $oldname (@filedir) {
	$newname = $oldname;
	$newname =~ s/.jpg\b//;			# the token file
	print "adding $oldname to html file in row $row, column $column\n";
	print OUT "<TD ALIGN=\"CENTER\">\n";
	print OUT "<IMG SRC=\"125/$newname.125.jpg\"><BR>\n";
	print OUT "<A HREF=\"50/$newname.50.jpg\">Half Size</A>&nbsp;&nbsp;\n";
	print OUT "<A HREF=\"$oldname\">Full Size</A>\n";
	print OUT "</TD>\n";
	$column++;
	$counter++;	
	if ($column == 4) {
		print OUT "</TR>\n\n<TR>\n";
		$column = 1;
		$row++;
	}
	
} 
print OUT "</TR>\n</TABLE>\n";
print OUT "</BODY>\n</HTML>";

$end = time - $start;
print "Added $counter jpegs in $end seconds\n";


