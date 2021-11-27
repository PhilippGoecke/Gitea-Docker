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

# Backup DB
docker exec gitea-docker_db_1 /usr/bin/mysqldump -u root --password=gitea gitea > gitea_data_$(date '+%Y-%m-%d').sql

# Compess & Encrypt Backup
tar -cvzf - gitea_data_* | gpg --symmetric --pinentry-mode loopback --passphrase 'secret' --armor --output gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg
rm gitea_data_*
