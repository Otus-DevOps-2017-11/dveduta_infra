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

## Домашняя работа 07

**примечание**
в archlinux исполняемый файл называется packer-io, а не packer.
Приводится исходное имя бинарника, однако возможны непреднамеренные опечатки.

### фактический variables.json

```
{
  "proj_id": "beaming-pillar-188917",
  "src_img_family": "reddit-base",
  "type_mach": "f1-micro",
  "d_size": "20",
  "d_type": "pd-standard",
  "net_name": "default",
  "u_tags": "puma-server"
}
```

### Проверка
#### Без параметров
```
packer validate ./ubuntu16.json 
```
#### С параметрами
```
packer validate -var-file=variables.json ./ubuntu16.json 
```

### Сборка
```
packer build -var-file=variables.json ./ubuntu16.json 
```

### * immutable, сборка
Аналогичным образом
```
packer build -var-file=variables.json ./immutable.json 
```
В качестве параметров, помимо proj_id (project_id) src_img_family (source_image_family), можно указать

  * machine_type - type_mach
  * image_description - img_desc
  * disk_size - d_size
  * disk_type - d_type
  * network - net_name
  * tags - u_tags

## Домашняя работа 08

В файле main.tf с использованием провайдера google описан ресурс "google_compute_instance" c названием "app".

Провайдер google, после описания в файле, однократно подгружается командой

```  
terraform init  
```

Ресурс описывает запуск виртуалки на основе образа reddit-base, созданного в предыдущем домашнем задании.
Размер g1-small
Тег - reddit-app

При запуске в пользователя добавляется публичный ключ из metadata и создается пользователь из первой части значения (dveduta в данном случае)
После запуска виртуалки применяеются два провижинера, которые подключаются с использованием учетной записи с приватным описанных в connection.
Первый провижинер загружает файл с описанием сервиса puma
Второй - выполняет bash-скрипт с клонированием репозитория и настройкой сервиса.

Далее описывается правило файерволла , разрешающее входящие соединения для порта 9292, и применяющееся ко всем вирталкам с тегом reddit-app.

Часть параметров определены в виде переменных, и могут быть изменены в файле terraform.tfvars, пример для которого - terraform.tfvars.example находится в репозитории.

Таким образом, после применения шаблона (terraform apply) получится виртуалка reddit-app  с запущенным приложением. В силу тега reddit-app порт для подключения будет открыт.

Адрес для подключения отобразится после применения шаблона как output переменная app_external_ip.

 * Проверка шаблона - terraform plan
 * Удаление всего, описанного в tf-файлах - terraform destroy
 * Пометить для пересоздания - terrafom taint resource_name

