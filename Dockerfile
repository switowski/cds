# CDS production docker build
FROM python:3.5-slim
MAINTAINER CDS <cds-admin@cern.ch>

ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
    && apt-get -qy upgrade --fix-missing --no-install-recommends \
    && apt-get -qy install --fix-missing --no-install-recommends \
        curl \
        git \
        gcc \
        # Postgres
        libpq-dev \
        # python-pillow
        libjpeg-dev \
        libffi-dev \
        libfreetype6-dev \
        libmsgpack-dev \
        # CairoSVG
        libcairo2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt-dev \
        imagemagick \
    # Node.js and NPM modules
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    && npm update \
    && npm install --silent -g node-sass@3.8.0 clean-css@3.4.24 requirejs uglify-js \
    # Cleanup to save some space on the disk
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg}/ \
    && rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* \
    && find /usr/share/doc -depth -type f ! -name copyright -delete


# RUN apt-get update && \
#     apt-get install -y lsb-release

# # install dependencies
# RUN apt-get update \
#     && apt-get -qy upgrade --fix-missing --no-install-recommends \
#     && apt-get -qy install --fix-missing --no-install-recommends \
#         curl \
#         git \
#         gcc \
#         # Postgres
#         libpq-dev \
#         # python-pillow
#         libjpeg-dev \
#         libffi-dev \
#         libfreetype6-dev \
#         libmsgpack-dev \
#         # CairoSVG
#         libcairo2-dev \
#         libssl-dev \
#         libxml2-dev \
#         libxslt-dev \
#         imagemagick \
#     # Install node
#     && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
#     && apt-get install -y nodejs\
#     && npm install -g bower node-sass clean-css requirejs uglify-js \
#     && npm install -g clean-css@3.4.24 \
#     && npm install -g node-sass@3.8.0

# no need to install ES here, it will be installed by the docker-compose.yml
# install python libraries
RUN pip install --upgrade pip setuptools py && \
    pip install --upgrade twine wheel coveralls requirements-builder flask-shell-ipython gunicorn httpie

# Create instance/static folder
ENV APP_INSTANCE_PATH /usr/local/var/instance
RUN mkdir -p ${APP_INSTANCE_PATH}
WORKDIR /code/cds

# Copy and install requirements. Faster build utilizing the Docker cache.
COPY requirements*.txt /code/cds/
RUN pip install -r requirements.devel.txt --src /code/

# Copy source code
COPY . /code/cds/

# Install CDS
RUN pip install -e .[all]

# Install bower dependencies and build assets.
RUN python -O -m compileall . \
    && cds npm \
    && cd ${APP_INSTANCE_PATH}/static \
    && npm install \
    && cds collect -v \
    && cds assets build


# # Run container as user `cds` with UID `1000`, which should match
# # current host user in most situations:
# RUN adduser --uid 1000 --disabled-password --gecos '' cds && \
#     chown -R cds:cds /code ${APP_INSTANCE_PATH}
# USER cds

VOLUME ["/code/cds"]
# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cds", "run", "-h", "0.0.0.0"]

# # Install dependencies
# RUN apt-get update \
#     && apt-get -qy upgrade --fix-missing --no-install-recommends \
#     && apt-get -qy install --fix-missing --no-install-recommends \
#         curl \
#         git \
#         gcc \
#         # Postgres
#         libpq-dev \
#         # python-pillow
#         libjpeg-dev \
#         libffi-dev \
#         libfreetype6-dev \
#         libmsgpack-dev \
#         # CairoSVG
#         libcairo2-dev \
#         libssl-dev \
#         libxml2-dev \
#         libxslt-dev \
#         imagemagick \
#     # Node.js
#     && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
#     && apt-get -qy install --fix-missing --no-install-recommends \
#         iojs \

#     && apt-get clean autoclean \
#     && apt-get autoremove -y \
#     && rm -rf /var/lib/{apt,dpkg}/ \
#     && rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* \
#     && find /usr/share/doc -depth -type f ! -name copyright -delete

# # Basic Python tools
# RUN pip install --upgrade pip setuptools ipython gunicorn

# # NPM
# COPY ./scripts/setup-npm.sh /tmp
# RUN /tmp/setup-npm.sh

# # CDS specific

# # Set copy for static files, linking is a nightmare
# ENV APP_COLLECT_STORAGE=flask_collect.storage.file

# # Pre-install modules for caching
# COPY ./docker/docker-entrypoint.sh /

# # Create instance/static folder
# ENV APP_INSTANCE_PATH /usr/local/var/instance
# RUN mkdir -p ${APP_INSTANCE_PATH}
# WORKDIR /code/cds

# # Copy and install requirements. Faster build utilizing the Docker cache.
# COPY requirements*.txt /code/cds/
# RUN pip install -r requirements.devel.txt --src /code/

# # Copy source code
# COPY . /code/cds/

# # Install CDS
# RUN pip install -e .[all]

# # Install bower dependencies and build assets.
# RUN cds npm \
#     && cd ${APP_INSTANCE_PATH}/static \
#     && npm install \
#     && cd /code/cds \
#     && cds collect -v \
#     && cds assets build

# RUN adduser --uid 1000 --disabled-password --gecos '' cds \
#     && chown -R cds:cds /code ${APP_INSTANCE_PATH}

# USER cds

# VOLUME ["/code/cds"]
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["cds", "run", "-h", "0.0.0.0"]
