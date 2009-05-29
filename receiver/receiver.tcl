#!/usr/bin/env tclsh8.4

package require Pgtcl

source config.tcl

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

	if {$line == "" && [info exists cdata(HASH)]} {
		puts "Inserting $cdata(HASH)"

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
	
		set res [pg_exec $db "INSERT INTO commit_location (hash,branch,hostname,origin,path,version) VALUES ([pg_quote $cdata(HASH)], [pg_quote $cdata(BRANCH)],
                                             [pg_quote $cdata(HOSTNAME)], [pg_quote $cdata(ORIGIN)], [pg_quote $cdata(PATH)], [pg_quote $cdata(VERSION)]);"]
		puts [pg_result $res -error]
		pg_result $res -clear

		unset -nocomplain cdata
	}
}
