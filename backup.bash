# Backup Volume
docker run --rm \
  --volume gitea_gitea:/data \ #[DOCKER_COMPOSE_PREFIX]_[VOLUME_NAME]:/[TEMPORARY_VOLUME_DATA_DIRECTORY]
  --volume $(pwd):/backup \ # $(pwd):/[TEMPORARY_BACKUP_DIRECTORY]
  debian:bullseye \
  tar cvf /backup/gitea_data_$(date '+%Y-%m-%d').tar /data
# tar -tvf gitea_data_$(date '+%Y-%m-%d').tar

# Backup DB
docker exec gitea_db_1 /usr/bin/mysqldump -u root --password=gitea gitea > gitea_data_$(date '+%Y-%m-%d').sql

# Compess & Encrypt Backup
tar -cvzf - gitea_data_* | gpg --symmetric --pinentry-mode loopback --passphrase 'secret' --armor --output gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg
rm gitea_data_*
