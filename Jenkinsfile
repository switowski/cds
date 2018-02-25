#!/usr/bin/env groovy
pipeline {
    agent any

    environment {
        TAG = "${env.BRANCH_NAME}_${env.BUILD_NUMBER}"
        REQUIREMENTS = 'prod'
        SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://postgres@localhost:5432/cds"
        ES_VERSION = '2.2.0'
        ES_HOST = '127.0.0.1'
        HOME = '.'
    }

    stages {
        stage("Checkout") {
          steps {
            checkout scm
          }
        }
        stage("Build and start test image") {
            steps {
                sh '''
                    virtualenv venv --distribute
                    . venv/bin/activate
                    ./.travis-extra-install.sh
                    export PATH=$PATH:/tmp/ffmpeg
                    # source ./scripts/setup-npm.sh
                    npm install --unsafe-perm -g node-sass@3.8.0 clean-css@3.4.24 uglify-js requirejs
                    source ./.travis-requirements-build.sh

                    pip install -r .travis-${REQUIREMENTS}-requirements.txt
                    pip install -e .[all]
                    pip install pydocstyle # For some reason, it is not installed by default
                    source ./scripts/setup-assets.sh
                '''
            }
        }

        stage("Run tests") {
            steps {
                sh "./run-tests.sh"
            }
        }
    }
}
