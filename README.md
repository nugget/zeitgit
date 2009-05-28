# Zeitgit - git collaboration suite #

Zeitgit is a nascent suite of tools designed to ease the administration of
remote git repositories, allowing a development group to coordinate a shared,
common environment despite git's federated design.

## Initial Feature Goals ##

* Allow for a centralized log of commit activity which can
  track activity in remote and potentially un-shared code branches.

* Make it simple to deploy and maintain a common set of git hooks among 
  disparate repositories maintained by individual developers

## Design philosophy ##

Any code which needs to run at the remote repository level should be as 
boring and portable as possible.  Where practical, hooks and scripts are 
written in basic bourne shell with minimal toolkit assumptions.
