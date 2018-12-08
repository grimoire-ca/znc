# ZNC for Grimoire.ca

This sets up an EC2 instance running ZNC, a popular and open-source IRC
bouncer. Configuration is stored on an EBS volume, to preserve it across
instance replacements.

The initial credentials provided by this configuration **MUST** be changed
immediately, or the bouncer will be trivially available to every Thomas,
Richard, or Harriet who can read a Terraform manifest.
