#docker-compose up --no-start
#docker-compose up -d
#docker-compose logs -f
#docker-compose stop
#docker-compose rm
#docker-compose down
#docker-compose down --volumes # Remove named volumes
echo "docker-compose down --volumes # Remove named volumes"

# decrypt & decompress Backup
#gpg --pinentry-mode=loopback --passphrase 'secret' --decrypt gitea_backup_$(date '+%Y-%m-%d').tar.gz.gpg | tar -xvzf -
age --decrypt -i key.txt gitea_backup_$(date '+%Y-%m-%d').tar.gz.age > gitea_backup_$(date '+%Y-%m-%d').tar.gz

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
