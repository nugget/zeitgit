#!/usr/bin/env tclsh8.5

package require Pgtcl

# Fail gracefully if the fogbugz api package isn't installed
catch {package require fogbugz}

source [string map {receiver.tcl ""} [info script]]config.tcl

proc epoch_ts {epoch} {
	return [pg_quote [clock format $epoch -format "%Y-%m-%d %H:%M:%S" -gmt 1]]
}

proc count_char {char buf} {
	return [string length [regsub -all "\[^$char\]" $buf ""]]
}

proc do_sql {sql} {
	global db

	# puts "debug:\n$sql\n"
	# return 0

	set res [pg_exec $db $sql]
	set err [pg_result $res -error]
	if {$err != ""} {
		puts stderr "Error executing SQL:\n$sql\n-- \n$err\n"
		set retcode 0
	} else {
		set retcode 1
	}
	pg_result $res -clear

	return $retcode
}

proc fogbugz_log_commit {bugzid repo commit_hash} {
	if {![info exists ::fogbugz::config(api_url)]} {
		# tcl-fogbugz-api package is not configured
		puts stderr "No Config"
		return
	}

	lassign [::fogbugz::login] logged_in token
	if {!$logged_in} {
		puts stderr "Unable to log in to FogBugz: $token"
		return
	}

	puts stderr "Trying newCheckin $bugzid $repo $commit_hash"
	::fogbugz::raw_cmd newCheckin [dict create ixBug $bugzid sFile $repo sNew $commit_hash ixRepository 5]

    ::fogbugz::logoff $token

	return
}


if {[catch {set db [pg_connect -connlist [array get DB]]} result] == 1} {
	puts "Unable to connect to database: $result"
	exit
}

set in_body 0
set dump 0

set lh [open "/var/log/zeitgit.log" "w"]
while {[gets stdin line] >= 0} {
	puts $lh $line

	if {[regexp {^ZEITGIT } $line]} {
		puts "New record"
		unset -nocomplain cdata
	}
	if {[regexp {^([A-Z]+) (.*)$} $line _ key value]} {
		set cdata($key) "$value"
		if {$key == "BODY"} {
			set in_body 1
			set cdata(BODY) "$value"
		}
	} elseif {[regexp { (.+) \| +(\d+) ([-+]+)} $line _ filename lines plusminus]} {
		set in_body 0
		set dump 1
	} elseif {[regexp { (.+) \|  Bin} $line _ filename]} {
		# webroot/images/moo.gif |  Bin 1125 -> 0 bytes
		set in_body 0
		set dump 1
		set lines 0
		set plusminus ""
	} elseif {$in_body} {
		append cdata(BODY) "$line\n"
	}

	if {$dump} {
		set dump 0
		if {![info exists stored($cdata(HASH))]} {
			puts "Inserting $cdata(HASH)"

			set sql "INSERT INTO commits (hash, tree_hash, parent_hash,
                                author_name,author_email,author_date,
	                        commit_name,commit_email,commit_date,
	                        subject,body)
	                 SELECT
	                    [pg_quote $cdata(HASH)],
	                    [pg_quote $cdata(TREEHASH)],
	                    [pg_quote $cdata(PARENTHASH)],
	                    [pg_quote $cdata(AUTHORNAME)],
	                    [pg_quote $cdata(AUTHOREMAIL)],
	                    [epoch_ts $cdata(AUTHORDATE)],
	                    [pg_quote $cdata(COMMITERNAME)],
	                    [pg_quote $cdata(COMMITEREMAIL)],
	                    [epoch_ts $cdata(COMMITERDATE)],
	                    [pg_quote $cdata(SUBJECT)],
	                    [pg_quote $cdata(BODY)]
	                 WHERE [pg_quote $cdata(HASH)] NOT IN (SELECT DISTINCT hash FROM commits);"

			do_sql $sql

			puts "--\n$sql\n--\n"

			set sql "INSERT INTO commit_location (hash,branch,hostname,origin,path,version) VALUES ([pg_quote $cdata(HASH)], [pg_quote $cdata(BRANCH)],
                                     [pg_quote $cdata(HOSTNAME)], [pg_quote $cdata(ORIGIN)], [pg_quote $cdata(PATH)], [pg_quote $cdata(ZEITGIT)]);"

			do_sql $sql

			set stored($cdata(HASH)) 1
		}

		set insertions [count_char + $plusminus]
		set deletions  [count_char - $plusminus]

		set sql "INSERT INTO commit_file (hash,filename,insertions,deletions) VALUES (
		                     [pg_quote $cdata(HASH)],
				     [pg_quote $filename],
				     $insertions,
				     $deletions);"
		do_sql $sql

		unset -nocomplain bugzid
		if {[regexp {BUGZID: ?(\d+)} $cdata(BODY) _ bidbuf]} {
			set bugzid $bidbuf
		} elseif {[regexp {BUGZID: ?(\d+)} $cdata(SUBJECT) _ bidbuf]} {
			set bugzid $bidbuf
		}
		if {[info exists bugzid]} {
			if {[regexp {git.flightaware.com/home/git/(.*)} $cdata(ORIGIN) _ repo]} {
				fogbugz_log_commit $bugzid $repo $cdata(HASH)
			}
		}
	}

	#  tools/{zeitgit => zeitgit.in} |    0   (a rename)
}
close $lh
