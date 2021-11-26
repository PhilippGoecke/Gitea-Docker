docker-compose down

# Backup Volume
docker run --rm \
  --volume gitea_gitea:/data \
  --volume $(pwd):/backup \
  debian:bullseye \
  tar -cvf /backup/gitea_data_$(date '+%Y-%m-%d').tar /data

# Backup DB
docker exec gitea-docker_db_1 /usr/bin/mysqldump -u root --password=gitea gitea > gitea_data_$(date '+%Y-%m-%d').sql

# Compess & Encrypt Backup
tar -cvzf - gitea_data_* | gpg --symmetric --pinentry-mode loopback --passphrase 'secret' --armor --output gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg
rm gitea_data_*
