# dveduta_infra

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

