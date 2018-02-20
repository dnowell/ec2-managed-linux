# ec2-managed-linux-template

Ansible playbooks and roles to get started with. Designed for EC2 + EL 7.

Ansible controller requirements:
* ansible-2.2 (or greater)
* python2-boto (Python >= 2.7 required for the AMI search task)
* git-1.8.3 needed to push to git.iq.it.umich.edu

## Onetime setup

1. Clone this repository
2. cp deploy/ansible.cfg.sample deploy/ansible.cfg (Or somewhere appropriate)
   - Set paths in ansible.cfg.
   - Default is ~/ec2-managed-linux-template
   - This example assumes a shared Ansible server, which is why we are localizing everything
3. Set up AWS EC2 keypairs.

## Secret keys

Various secrets are required for Ansible playbook operation.

* AWS credentials are used by Python boto with the ec2.py inventory script.
  - Use temporary credentials generated by logging in through the aws-saml-api container - details below
  - Alternately, put a profile in your ~/.aws/credentials file and define that when setting up a server

```bash
[vdc-ra]
aws_access_key_id = AEEEEEEEEEABEJQVYDNA
aws_secret_access_key = 1234567896t7yNSegjZNMnBuwp+Vc9kQvm44KuCr
region = us-east-2

[vdc-ci]
aws_access_key_id = AEEEEEEEEEKDUEAKOLRQ
aws_secret_access_key = 123456789LMcN1n1yTVlS4N10rWqZ7rjMGzSrcf4
region = us-east-2
``` 

* SSH private keys are used by Ansible to log in and manage remote systems. - These are created in EC2 - Keypairs
  Get the .pem file and put it in the secret-keys/ssh-keys
* Ansible Vault keyfile is used for encrypting/decrypting Ansible files (e.g. a variables.yml file that contains sensitive data).
  Optional - Use it if appropriate.

```
Remember to set permissions on your keys (ex. chmod 600 your-keys.pem)
```

### Directory structure

The `secret-keys` directory should be set up similar to:

```bash
ls -lR

-rw-r--r-- root root    Sep 19 19:03 README.md
drwxr-x--- root private Aug  4 11:24 ssh-keys
-r--r----- root private Mar 30 23:55 vault-key

./ssh-keys:
-r--r----- root private Jul 20 15:57 mos-linux.pem
```

### AWS credentials & IAM

You will need temporary credentials to make the AWS API calls with.
Get credentials by using https://github.com/umich-iam/aws-saml-api
Once the docker container has been configured run the following

```bash
sudo docker run -it --rm -v ~/.aws:/root/.aws aws-saml-api

OR

sh aws-saml-api.sh
```

These scripts install utilities that allow EC2 instances to describe their tags.

In order to support that, we had to set up an IAM role & policy.
If your account is in the UM VDC, that should be created for you.

Those of you using these scripts in other accounts, here's what I did:
* Rolename: ec2Instances-role
* Policy: ec2GetTags

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeTags"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```

### Ansible Vault keyfile

This is needed if you want to encrypt data.  Recommended to do on a bastion host where you will be running these scripts.

Uncomment the vault entry in ansible.cfg

Generate a *strong* keyfile containing pseudo-random data. For example (courtesy [StackExchange](https://unix.stackexchange.com/questions/33629/how-can-i-populate-a-file-with-random-data)):

```bash
head -c 2M < /dev/urandom > secret-keys/vault-key
```

In order to encrypt files, make sure you are running from a directory that contains your ansible.cfg file, so Vault knows where the key is instead of prompting for a password.

```
cd ~/ec2-managed-linux-template/deploy
ansible-vault encrypt ../secret-keys/duo-credentials.yml
ansible-vault view ../secret-keys/duo-credentials.yml
ansible-vault edit ../secret-keys/duo-credentials.yml
```

## Run playbooks

Please see the sample-server.yml file in the deploy/servers directory for added configuration options.  It can be customized and tagged to include Production status, name, instance type, etc.

```
General note: The directory deploy/servers should contain 1 file for each server you want to build. 
```

### Launch EC2 instance
Note: Make sure that you have a Network Security Group set appropriately to allow SSH and you have added that Policy to the  SECURITYGROUPS section in your server.yml file. 

Also make sure you have valid credentials configured in your ~/.aws/credentials file

```bash
cd deploy
ansible-playbook mos-linux.yml --extra-vars @servers/sample-server.yml
```

### Ensure configuration remains in place on existing EC2 instance

- TBD for MOS Linux

You can do the configuration management thing by scheduling this at regular intervals (using cron or Jenkins).

```bash
cd deploy
ansible-playbook main.yml --extra-vars @servers/sample-server.yml
```