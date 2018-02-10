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
 * Переформатировать шаблоны (== выставить отступы, что очень круто) - terraform fmt

## Домашняя работа 09

 * Изучили: Terrafom умеет переопределять дефолтные правила файерволла. Однако для этого требуется импортировать желаемое правило в созданное нами

```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```

 * Изучили: Terraform логично работает с неявными зависимостями ресурсов. Например, если создать ресурс ip адреса google_compute_address с названием app_ip и затем использовать его в описании сетевого интерфейса ресурса виртуалки

 ```
 network_interface {
 network = "default"
 access_config = {
 nat_ip = "${google_compute_address.app_ip.address}"
 }
 }
 ```
то tf сначала создаст ресурс адреса, и только после этого - виртуалку, с использованием созданного айпишника.

 * Далее шаблон ubuntu16.json для packer, созданный в предыдущем ДЗ, распилили на две отдельные сущности - приложение app.json и базу данных db.json

 * Распилили конфиг main.tf также на две сущности для приложения и БД
   * при этом добавили правила файерволла для app (разрешение подключаться на порт 9292 для всех) и db (разрешение подключаться на порт БД 27017 только для виртуалок с тегом reddit-app)
   * Семейства образов для виртуалок передаются в виде переменных (app_disk_image db_disk_image) с соответствующими дефолтными значениями (reddit-app-base reddit-db-base)
 * Вынесли в отдельный конфиг vpc.tf правило файерволла для ssh.
 Итого в исходном файле осталось только определение провайдера
 ```
 provider "google" {
 version = "1.4.0"
 project = "${var.project}"
 region = "${var.region}"
}
```

Созданные конфиги есть практически готовые модули.
Чтобы сделать их реальными модулями - раскладываем по папкам с переименованием (module/<modulename>/main.tf) - так будет удобнее работать.

Также для конвертации в полноценные модули задаем/переносим переменные, которые необходимы им для работы (ключ, зона и образ для app и db; диапазон разрешенных адресов для входящих запросов для vpc)

В модуле app у нас определена выходная переменная app_external_ip.
Чтобы получить её значение в основной части конфига используем конструкцию
```
output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}
```
При этом в app остается исходная конструкция
```
output "app_external_ip" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
}
```

Далее, разделяем определяем два окружения - stage и prod: переносим конфиги в папки, исправляем пути до модулей.

Если скопировать всё кроме модулей - будет достаточно `terraform get` для подготовки окружения к работе.

Если же не скопировать terraform.tfstate - то потребуется полная инициализация `terrafom init`.

Логично, при "боевом" создании окружений разделить stage и prod в том числе и по namespace, поскольку при текущей конфигурации stage и prod работают с одними и теми же виртуалками.

---

Готовые модули для terrafom можно найти в https://registry.terraform.io/
Подключаются аналогичным образом.
```
module "storage-bucket" {
 source = "SweetOps/storage-bucket/google"
 version = "0.1.1"
 name = ["storage-bucket-test", "storage-bucket-test2"]
}
```
Данные имена gcp отказался принимать - сказал есть совпадающие названия. Пришлось переименовать в sbt и sbt2

## Домашняя работа 10

```
yaourt -Qs ansible
community/ansible 2.4.3.0-1
    Radically simple IT automation platform
community/ansible-lint 3.4.20-1
    Checks playbooks for practices and behaviour that could potentially be improved.
```
requirements не пригодился, но добавлен.

 * Создали inventory файл с данными об appserver и dbserver, а также описании подключения (пользователь и ключ)
 * Создали ansible.cfg и вынесли в него общие настройки - учетные данные для подключения, inventory-файл, отключение проверки ключей хостов (ssh-keygen -R временно не нужен, да)
 * Описали две группы хостов (по одному серверу в каждой) и научились призывать как каждую группу по отдельности, так и всё сразу
 * Сделали inventory в формате yml

---
 Сделать задание со '*' - inventory в формате json и по примеру https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6 не удалось - попытка представлена в inventory_2.json. Полный текст ошибки:
 ```
 [WARNING]:  * Failed to parse dveduta_infra/ansible/inventory_2.json with yaml plugin: Invalid children entry for all group, requires a dictionary, found <type 'list'> instead.
 ```
 Пример по ссылке выдает аналогичную ошибку.
 Неканоничный, но рабочий вариант - в inventory.json

---
* Выполнение команд

```
ansible app -m command -a 'ruby -v'
appserver | SUCCESS | rc=0 >>
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
```

```
ansible app -m command -a 'bundler -v'
appserver | SUCCESS | rc=0 >>
Bundler version 1.11.2
```

```
ansible app -m shell -a 'ruby -v; bundler -v'
appserver | SUCCESS | rc=0 >>
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
Bundler version 1.11.2
```

```
ansible db -m service -a name=mongod
dbserver | SUCCESS => {
    "changed": false,
    "name": "mongod",
    "status": {
        "ActiveEnterTimestamp": "Mon 2018-02-05 18:54:16 UTC",
        "ActiveEnterTimestampMonotonic": "13380839",
        "ActiveExitTimestampMonotonic": "0",
        "ActiveState": "active",
        "After": "sysinit.target basic.target system.slice systemd-journald.socket network.target",
        "AllowIsolate": "no",
        "AmbientCapabilities": "0",
        "AssertResult": "yes",
...
```

```
 ansible app -m git -a 'repo=https://github.com/Otus-DevOps-2017-11/reddit.git dest=/home/dveduta/reddit'
 appserver | SUCCESS => {
     "after": "61a7f75b3d3e6f7a8f279896fb4e9f0556e1a70a",
     "before": null,
     "changed": true
 }
```
```
ansible app -m command -a 'git clone https://github.com/Otus-DevOps-2017-11/reddit.git /home/dveduta/reddit'
appserver | FAILED | rc=128 >>
fatal: destination path '/home/dveduta/reddit' already exists and is not an empty directory.non-zero return code
```

## Домашняя работа 11
### Один плейбук - один сценарий
 * unit для mongod
  * проверка `ansible-playbook reddit_app.yml --check --limit db`
  * переменные - с дефолтным значением и без
  * handler на рестарт mongod
  * применение плейбука `ansible-playbook reddit_app.yml --limit db`
 * Unit для приложения
  * Сервис и handler для puma
  * Таск для шаблона db_config
  * тестовый прогон `ansible-playbook reddit_app.yml --check --limit app --tags app-tag`
  * актуальный запуск `ansible-playbook reddit_app.yml  --limit app --tags app-tag`
 * Деплой
  * клонирование через модуль git и установка зависимостей через bundler
  * handler для перезапуска puma
  * проверка и запуск `ansible-playbook reddit_app.yml --limit app --tags deploy-tag`
  * Проверка работы приложения ![App working][ansible2itsalive]

[ansible2itsalive]: ansible2itsalive.png "Ansible works"

### Один плейбук - несколько сценариев  
 * Разделили исходный сценарий на 2
  * Hosts и tags для каждого отдельный
  * become: true для всего сценария
 * Пересоздали виртуалки. Поправили айпишники в inventory
 * Проверили и применили `ansible-playbook reddit_app2.yml --tags db-tag`
 * Проверили и применили `ansible-playbook reddit_app2.yml --tags app-tag`
 * Сделали сценарий для deploy, проверили и применили `ansible-playbook reddit_app2.yml --tags deploy-tag`. Приложение работает.

### Несколько плейбуков
  * переименовали предыдущие плейбуки
  * разделили сценарии по файлам {app|db|deploy}.yml
  * Сделали головной файл site.yml, проверили и применили плейбуки
  `ansible-playbook site.yml` - приложение работает по внешнему адресу.

### Провижининг в Packer
 * Заменили bash-скрипты на плейбуки ansible
 * пересоздали образы
 ```
==> Builds finished. The artifacts of successful builds are:
--> googlecompute: A disk image was created: reddit-app-base-1517958565

--> googlecompute: A disk image was created: reddit-db-base-1517958897
```
 * пересоздали stage
```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

app_external_ip = 146.148.7.110
app_internal_ip = 10.132.0.3
db_external_ip = 104.199.85.140
db_internal_ip = 10.132.0.2
```
 * накатили плейбук `ansible-playbook site.yml`
```
appserver                  : ok=9    changed=7    unreachable=0    failed=0
dbserver                   : ok=3    changed=2    unreachable=0    failed=0
```

## Домашняя работа 12
* Создали роли app и db
* Скопировали tasks, template, handler и variables из плейбука db в роль db
* Аналогично заполнили роль app
* Перевели плейбуки на роли
* пересоздали виртуалки
* применили плейбук и проверили работу приложения
#### Окружения
* Создали окружения stage и prod, внесли туда inventory
* определили дефолтное окружение - stage
* group_vars для stage и prod, задание переменной env
* добавили вывод текущего окружения через debug
* разложили файлы по папкам в соответствии с best practices
* пересоздали виртуалки и проверили накатывание stage энва ансибла
* приложение работает
* Пересоздали виртуалки в prod окружении
* применили ansible с прод окружением и проверили работоспособность приложения
#### Коммьюнити роли
* Добавили и поставили роль jdauphant.nginx
* Добавила нстройки проксирования nginx на puma
* пересоздали виртуалки stage, применили ansible, проверили работоспособность приложение на стандартном 80 порту

## Домашнаяя работа 13