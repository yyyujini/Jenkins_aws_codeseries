FROM httpd:2.4
COPY index.html /usr/local/apache2/htdocs/
COPY index.html /var/www/html
EXPOSE 80