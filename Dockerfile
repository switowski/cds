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

VOLUME ["/code/cds"]

# Required to support Support Arbitrary User IDs in OpenShift
# https://docs.openshift.org/latest/creating_images/guidelines.html
# source: https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile.centos7
ENV PATH=${APP_INSTANCE_PATH}/bin:${PATH} HOME=${APP_INSTANCE_PATH}
COPY docker/uid_entrypoint ${APP_INSTANCE_PATH}/bin/
RUN chmod -R u+x ${APP_INSTANCE_PATH}/bin && \
    chgrp -R 0 ${APP_INSTANCE_PATH} && \
    chmod -R g=u ${APP_INSTANCE_PATH} /etc/passwd

### Containers should NOT run as root as a good practice
USER 10001
WORKDIR ${APP_INSTANCE_PATH}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT [ "uid_entrypoint" ]

# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cds", "run", "-h", "0.0.0.0"]
