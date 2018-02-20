# Secrets

## Overview

This directory and its contents should live at: `secret-keys`

It contains cleartext secrets:

* SSH private keys
* Amazon credentials
* Ansible Vault symmetric key

Please treat it accordingly by using it only on trusted systems, with appropriate permissions and ownership set.

## Just a thought on setting it up

Create a service account that will run your Ansible playbooks (e.g. via cron).

```bash
groupadd playgroup
useradd -g playgroup playrunner
```

And then:

```bash
_p=secret/keys

chown -R root:playgroup "${_p}"
find "${_p}" -type d -exec chmod 0750 {} \;
find "${_p}" -type f -exec chmod 0640 {} \;
```

Maybe use FACLs or a regular cronjob to ensure permissions stay this way. You get the idea.

## Keeping secrets out of your git repo

Lastly, if you fork this project make sure `secret-keys` is excluded from your commits. Example `.gitignore`:

```
secret-keys/*
!secret-keys/README.md
```

This configuration will include this README.md file, but exclude everything else.
