# dveduta_infra

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



