# dveduta_infra

Однострочное подключение к someinternalhost:

```
ssh -At dveduta@35.198.86.41 ssh 10.156.0.3
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.10.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Wed Dec 13 18:08:58 2017 from 10.156.0.2
dveduta@someinternalhost:~$ 
```

Однокомандное подключение через алиас internalhost:

```
cat ~/.ssh/config

Host internalhost
  ForwardAgent yes
  ProxyCommand ssh -q dveduta@35.198.86.41 nc -q0 10.156.0.3 22
```

```
ssh internalhost
The authenticity of host 'internalhost (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:aW/nPZYlY6DW7e0wlOcx8dNOtMTJe/RhTWrEceedwBI.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'internalhost' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.10.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Wed Dec 13 18:18:05 2017 from 10.156.0.2
dveduta@someinternalhost:~$ 
```
