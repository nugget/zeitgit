# Zeitgit - git collaboration suite #

Zeitgit is a nascent suite of tools designed to ease the administration of
remote git repositories, allowing a development group to coordinate a shared,
common environment despite git's federated design.

At FlightAware we wanted a mechanism that allowed us to continue using daily
development activity emails, but the distributed nature of git made this 
impractical.  Simply logging commits as they were pushed up to the central
repository didn't provide visibility into local developer branches and posed
date-range challenges for commits which weren't pushed upstream the same
day they were made.

Zeitgit was created to capture commit activity locally and centralize it for
logging purposes.  Currently it provides the following functions to a network
of developers who use git for their coordinated version control:

* Maintain a centralized log of developer activity which tracks commits which
  take place in remote and potentially orphan code branches.

* Make it simple to deploy and maintain a common set of git hooks among 
  disparate repositories maintained by individual developers

## Design philosophy ##

Any code which needs to run at the remote repository level should be as 
boring and portable as possible.  Where practical, hooks and scripts are 
written in basic bourne shell with minimal toolkit assumptions.

## Quick-start Guide ##

The core of Zeitgit is the collector script which runs on a central host
and accepts commit information from developers via email.  This collector
script requires PostgreSQL and TCL on the host.  It can easily be launched
automatically via procmail, although integration into any mail delivery agent
should be a relatively straightforward process.

1. Create the database to store the Zeitgit log data and initialize the schema.
   You'll also want to set a custom password on the committer role:
        $ createdb zeitgit 
	$ psql < db/schema.sql
	$ psql zeitgit -c "ALTER ROLE committer WITH ENCRYPTED PASSWORD 'password';"

2. Configure the receiver script to use your local database configuration:
        $ cd receiver
	$ cp config.tcl.sample config.tcl
   Then edit config.tcl to taste.  Minimally you'll need to change the password.

3. Hook up the collector script to an email account or alias you've created.  How
   this works exactly will be site-specific depending on your host configuration,
   but here's how it works for us.  There's a unix account on the server which 
   receives the commit emails from the repo hooks.  That account has a .procmailrc
   that contains:
        LOGFILE=$HOME/log/procmail.log
	VERBOSE=yes
	LOGABSTRACT=all

	:0 H
	* ^Subject:.*gitcommit
	| $HOME/src/zeitgit/receiver/receiver.tcl
   This catches any incoming commit email from a Zeitgit client and pipes it into
   the receiver script, which in turn stores the commit info in the database.
