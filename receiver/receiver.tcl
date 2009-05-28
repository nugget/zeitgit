#!/usr/bin/env tclsh8.4

package require Pgtcl

array set DB {
	dbname          zeitgit
	host            localhost
	port            5432
	user            committer
	password        password
	connect_timeout 5
}
proc epoch_ts {epoch} {
	return "(SELECT TIMESTAMP WITH TIME ZONE 'epoch' + $epoch * INTERVAL '1 second')"
}

if {[catch {set db [pg_connect -connlist [array get DB]]} result] == 1} {
	puts "Unable to connect to database: $result"
	exit
}
while {[gets stdin line] >= 0} {
	if {[regexp {^([A-Z]+) (.*)$} $line _ key value]} {
		set cdata($key) "$value"
	}

	puts $line
	if {$line == ""} {
		puts "Inserting $cdata(hash)"

		set res [pg_exec $db "INSERT INTO commits (hash, tree_hash, parent_hash,
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
	             WHERE [pg_quote $cdata(HASH)] NOT IN (SELECT DISTINCT hash FROM commits);"]

		puts [pg_result $res -error]
		pg_result $res -clear
	
		set res [pg_exec $db "INSERT INTO commit_branch (hash,branch) VALUES ([pg_quote $cdata(HASH)], [pg_quote $cdata(BRANCH)]);"]
		puts [pg_result $res -error]
		pg_result $res -clear

		unset -nocomplain cdata
	}
}
