# dveduta_infra

## Домашняя работа 05

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

---

Хост bastion, IP: 35.198.86.41, внутр. IP: 10.156.0.2.
Хост: someinternalhost, внутр. IP: 10.156.0.3 

Примечание: для корректного поведения сети удалил маршрут 0.0.0.0/0 из впн сервера, добавил маршрут 10.156.0.0/24 , запретил клиенту использовать впн как маршрут по умолчанию.



---

## Домашняя работа 06

### Команда для запуска инстанса с использованием локального startup script 

```
gcloud compute instances create reddit-app-n2\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west3-b \
  --metadata-from-file startup-script=startup_script.sh
```

### Команда для запуска инстанса с использованием startup script из gs (предварительно создан региональный сегмент и загружен скрипт)


```
gcloud compute instances create reddit-app-n2\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west3-b \
  --metadata startup-script-url=https://storage.cloud.google.com/scriptsstartup/startup_script.sh
```


### Вариант со ссылкой типа gs


```
  --metadata startup-script-url=gs://scriptsstartup/startup_script.sh
```

### Подходит любой общедоступный урл, по которому отдается файл 


```
  --metadata startup-script-url=https://raw.githubusercontent.com/Otus-DevOps-2017-11/dveduta_infra/950f040206fff602dc060fd4b7b705840de054cf/startup_script.sh
```

