# Zeitgit - git collaboration suite #

Zeitgit is a nascent suite of tools designed to ease the administration of
remote git repositories, allowing a development group to coordinate a shared,
common environment despite git's federated design.

The distributed nature of git makes logging and tracking developers
impractical.  Simply logging commits as they are pushed up to the central
repository doesn't provide visibility into local developer branches and poses
challenges for commits which weren't pushed upstream the same day they were
made.

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
written in basic Bourne shell with minimal toolkit assumptions.

Zeitgit uses email as the transport mechanism so it doesn't require an 
active net connection while commits are being logged.  Commit mails to
the receiver service will simply queue and be sent when a net connection
is available later.

## Requirements ##

* Assumes you use Unix.  cygwin might be OK but is totally untested.
* Tcl and PostgreSQL required on the logging server
* Procmail or some other mechanism to automatically pipe some emails
  into a script.
* /bin/sh on the repository (client) side. 

## Credits ##

Zeitgit was developed internally at FlightAware to facilitate a company-wide
migration from CVS and Subversion to git.

## Known Issues ##

OS X 10.8 (Mountain Lion) broke Unix mail sending.  You can fix this by 
executing the following commands in a Terminal window:

    sudo mkdir -p /Library/Server/Mail/Data/spool
    sudo /usr/sbin/postfix set-permissions

OS X 10.9 (Mavericks) settings to allow SASL-authenticated mail through
your authorized SMTP relay:

In /private/etc/postfix/main.cf add these lines:

    smtp_use_tls = yes
    smtp_tls_note_starttls_offer = yes
    relayhost = mail.example.com:587
    smtp_sasl_security_options = noanonymous
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/private/etc/postfix/sasl_password
	# Optionally rewrite username@local. envelope senders
	# myorigin = example.com

In /private/etc/postfix/sasl_password:

    mail.example.com:587 username:password

Then run postmap sasl_password
