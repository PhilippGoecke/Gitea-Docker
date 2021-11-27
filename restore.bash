#docker-compose up --no-start
#docker-compose up -d
#docker-compose logs -f
#docker-compose down

# decrypt & decompress Backup
gpg --pinentry-mode=loopback --passphrase 'secret' --decrypt gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg | tar -xvzf -

# tar -tvf gitea_data_$(date '+%Y-%m-%d').tar
# Restore Volume
docker run --rm \
  --volume gitea-docker_gitea-data:/gitea/data \
  --volume gitea-docker_gitea-config:/gitea/config \
  --volume $(pwd):/backup \
  debian:bullseye-slim \
  sh -c "rm -rf /gitea/data/* /gitea/data/..?* /gitea/data/.[!.]* /gitea/config/* /gitea/config/..?* /gitea/config/.[!.]*" \
  sh -c "tar -xvf /backup/gitea_data_$(date '+%Y-%m-%d').tar -C /data/ --strip 1"

# Restore DB
cat gitea_data_$(date '+%Y-%m-%d').sql | docker exec -i gitea-docker_db_1 /usr/bin/mysql -u root --password=gitea gitea
