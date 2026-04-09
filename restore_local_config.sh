#!/bin/bash
echo "Restauration des fichiers de configuration..."
cp docker-compose.yml.restore docker-compose.yml
cp nginx.conf.restore apps/dashboard/nginx.conf
echo "Fichiers restaurés. Vous pouvez redéployer."
