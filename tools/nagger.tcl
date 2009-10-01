#!/usr/local/bin/tclsh8.5
#
# Internal tool we use at FlightAware to nag developers.
#
# This script isn't really groomed for generalized use yet.
#

package require Tclx

package require mime
package require smtp
package require xml

set fh [open "|find /usr/home/nugget/nagtest -type d -name .git"] 

while {[gets $fh line] >= 0} {
	set repo [regsub {\.git$} $line ""]
	set owner [file attributes $line -owner]

	lappend repolist($owner) $repo
}

foreach user [array names repolist] {
	set hits 0

	set email "$user@flightaware.com"
	set body "
Hi!

The automated Zeitgit crawler has detected one or more git repositories
on [info host] which are not Zeitgit-enabled.

You should consider running the following commands to enable Zeitgit!"

	foreach repo $repolist($user) {
		cd $repo
		set error ""
		set confcheck ""

		catch {set confcheck [exec git config zeitgit.enabled]} error

		if {$error != "true" && $error != "false"} {
			incr hits
			append body "\n  cd $repo\n  zeitgit enable gitcommit@flightaware.com\n"
		}
	}

	if {$hits > 0} {
		append body "\nIf you don't want to use Zeitgit for some of those repositories,\n"
		append body "you can instead do 'zeitgit disable' and you will no longer be\n"
		append body "nagged for that directory.\n"

		puts "Sending nag email to $user"

		set part_text [mime::initialize -canonical text/plain -string $body]
		set msg [mime::initialize -canonical multipart/alternative -parts [list $part_text]]
		eval [concat smtp::sendmessage $msg \
		[list -header [list Subject "Zeitgit Nagger on [info host]"]] \
		[list -header [list X-No-Archive "Yes"]] \
		[list -header [list CC "nugget@flightaware.com"]] \
		[list -header [list From "\"FlightAware Dev Central\" <development@corp.flightaware.com>"]] \
		[list -header [list To "$email"]] -servers localhost]
	}
}
