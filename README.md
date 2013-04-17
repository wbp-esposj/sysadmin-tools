sysadmin-tools
==============

openfire-add-to-rosters.pl
--------------------------
Need to edit variables for database, servername, skiplist.  The script would need to be modified if you have a table prefix, or other customizations to Openfire.  It requires Perl 5.10 due to the use of the ~~ operator.

    usage: ./openfire-add-to-rosters.pl newusername

delete-emails-to-user.pl
------------------------
This script is used to purge a postfix queue of outgoing messages to a single user.  Useful for messageboards where a user is subscribed to threads, etc and has an email address that doesn't work.

It needs to be able to execute the postsuper command.

    usage: ./delete-emails-to-user.pl emailaddress

pagerduty_nagios_skiplist.pl
----------------------------
This script is a replacement for pagerduty_nagios.pl from pagerduty.  It implements a skiplist for services that you don't want to go over pagerduty.  We've found this to be the least intrusive way to allow pager duty to act on all servers while ignoring less important services (such as APT checks for package updates).  An admin can check them on a daily basis through the nagios web console or their inbox.


