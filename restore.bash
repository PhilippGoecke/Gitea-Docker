# decrypt & decompress Backup
gpg --pinentry-mode=loopback --passphrase 'secret' --decrypt gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg | tar -xvzf -

# tar -tvf gitea_data_$(date '+%Y-%m-%d').tar
# Restore Volume
docker run --rm \
  --volume gitea_gitea:/data \
  --volume $(pwd):/backup \
  debian:bullseye \
  sh -c "rm -rf /data/* /data/..?* /data/.[!.]* ; tar -C /data/ -xf /backup/gitea_data_$(date '+%Y-%m-%d').tar"

# Restore DB
cat gitea_data_$(date '+%Y-%m-%d').sql | docker exec -i gitea_db_1 /usr/bin/mysql -u root --password=gitea gitea
