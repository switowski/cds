#!/usr/bin/env groovy
pipeline {
    agent any

    environment {
        TAG = "${env.BRANCH_NAME}_${env.BUILD_NUMBER}"
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
                    source ./scripts/setup-npm.sh
                    source ./.travis-requirements-build.sh

                    pip install -r .travis-${REQUIREMENTS}-requirements.txt
                    pip install -e .[all]
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
