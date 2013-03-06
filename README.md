sysadmin-tools
==============

openfire-add-to-rosters.pl
--------------------------
Need to edit variables for database, servername, skiplist.  The script would need to be modified if you have a table prefix, or other customizations to Openfire.  It requires Perl 5.10 due to the use of the ~~ operator.

    usage: ./openfire-add-to-rosters.pl newusername
