# Config for CDS is forcing SSL which is undesirable on localhost
# Let's use the one from Invenio instead
FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
ADD nginx.conf /etc/nginx/conf.d/
