#docker-compose up --no-start
docker-compose up -d
#docker-compose logs -f
#docker-compose down

# decrypt & decompress Backup
gpg --pinentry-mode=loopback --passphrase 'secret' --decrypt gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg | tar -xvzf -

# tar -tvf gitea_data_$(date '+%Y-%m-%d').tar
# Restore Volume
docker run --rm \
  --volume gitea_gitea:/data \
  --volume $(pwd):/backup \
  debian:bullseye-slim \
  sh -c "rm -rf /data/* /data/..?* /data/.[!.]* ; tar -xvf /backup/gitea_data_$(date '+%Y-%m-%d').tar -C /data/ --strip 1"

# Restore DB
cat gitea_data_$(date '+%Y-%m-%d').sql | docker exec -i gitea-docker_db_1 /usr/bin/mysql -u root --password=gitea gitea
