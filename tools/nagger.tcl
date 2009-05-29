#!/usr/bin/env tclsh8.4
#
# Internal tool we use at FlightAware to nag developers.
#
# This script isn't really groomed for generalized use yet.
#

package require Tclx

package require mime
package require smtp
package require xml

 set fh [open "|find / -type d -name .git"] 

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
		set confcheck [system git config zeitgit.enabled >/dev/null]
		if {$confcheck} {
			incr hits
			append body "

    cd $repo
    zeitgit enable gitcommit@flightaware.com
"

		}
	}

	if {$user != "nugget"} {
		set hits 0
	}

	if {$hits > 0} {
		append body "
If you don't want to use Zeitgit for some of those repositories,
you can instead do 'zeitgit disable' and you will no longer be
nagged for that directory."

		puts "Sending nag email to $user"

		set part_text [mime::initialize -canonical text/plain -string $body]
		set msg [mime::initialize -canonical multipart/alternative -parts [list $part_text]]
		eval [concat smtp::sendmessage $msg \
		[list -header [list Subject "Zeitgit Nagger on [info host]"]] \
		[list -header [list X-No-Archive "Yes"]] \
		[list -header [list From "\"FlightAware Dev Central\" <development@corp.flightaware.com>"]] \
		[list -header [list To "$email"]] -servers localhost]
	}
}
