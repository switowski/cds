# Config for CDS is forcing SSL which is undesirable on localhost
# Let's use the one from Invenio instead

# FROM nginx
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY conf.d/* /etc/nginx/conf.d/
# COPY test.key /etc/ssl/private/test.key
# COPY test.crt /etc/ssl/certs/test.crt

FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
# RUN rm /etc/nginx/conf.d/default.conf
# ADD conf.d/default.conf /etc/nginx/conf.d/