docker-compose down
# docker-compose exec server bash

# Backup Volumes
docker run --rm \
  --volume gitea-docker_gitea-data:/gitea/data \
  --volume gitea-docker_gitea-config:/gitea/config \
  --volume $(pwd):/backup \
  debian:bullseye-slim \
  tar -cvf /backup/gitea_data_$(date '+%Y-%m-%d').tar /gitea

# Backup Gitea
# docker exec -u <OS_USERNAME> -it -w <--tempdir> $(docker ps -qf "name=<NAME_OF_DOCKER_CONTAINER>") bash -c '/app/gitea/gitea dump -c </etc/gitea/app.ini>'
#docker exec -u root -i $(docker ps -qf "name=gitea-docker_server_1") bash -c "/app/gitea/gitea dump --skip-repository --skip-log --file gitea_data_dump_$(date '+%Y-%m-%d').zip"
docker exec -u root -i $(docker ps -qf "name=gitea-docker_server_1") bash -c "/app/gitea/gitea dump --skip-log --file gitea_data_dump_$(date '+%Y-%m-%d').zip"

# Backup DB
docker exec gitea-docker_db_1 /usr/bin/mysqldump -u root --password=gitea gitea > gitea_data_$(date '+%Y-%m-%d').sql

# Compess & Encrypt Backup
age-keygen -o key.txt
grep public key.txt | cut -d ' ' -f 4 > key.pub
#tar -cvzf - gitea_data_* | gpg --symmetric --pinentry-mode loopback --passphrase 'secret' --armor --output gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg
tar cvzf - gitea_data_* | age --recipients-file key.pub > gitea_backup_$(date '+%Y-%m-%d').tar.gz.age
#age --decrypt -i key.txt gitea_backup_$(date '+%Y-%m-%d').tar.gz.age > gitea_backup_$(date '+%Y-%m-%d').tar.gz

rm gitea_data_*
