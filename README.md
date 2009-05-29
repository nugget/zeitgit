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
written in basic bourne shell with minimal toolkit assumptions.

## Credits ##

Zeitgit was developed internally at FlightAware to facilite a company-wide
migration from CVS and Subversion to git.
