FROM nginx:alpine

# On copie les fichiers originaux comme templates
COPY index.html /usr/share/nginx/html/index.html.template
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# Script pour remplacer les variables d'env au démarrage (DOMAIN doit être défini)
CMD ["/bin/sh", "-c", "envsubst '${DOMAIN}' < /usr/share/nginx/html/index.html.template > /usr/share/nginx/html/index.html && envsubst '${DOMAIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]