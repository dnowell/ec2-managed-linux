# Amazon Keypairs
Create a keypair in the AWS console

Copy the .pem file to this directory

```bash
chmod 600 filename.pem
```

Note that this is the keypair that Ansible will use to connect to your server and configure it.

Only people with access to that keypair will be able to manage this server initially!  Systems can't do their thing until after Ansible has run and installed their SSH key.
