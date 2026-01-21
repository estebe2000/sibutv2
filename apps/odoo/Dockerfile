FROM odoo:17.0

USER root
# Installation de gettext pour avoir envsubst
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

COPY odoo.conf.template /etc/odoo/odoo.conf.template

# Script de démarrage pour substituer la variable
CMD ["/bin/sh", "-c", "envsubst < /etc/odoo/odoo.conf.template > /etc/odoo/odoo.conf && /entrypoint.sh odoo"]
