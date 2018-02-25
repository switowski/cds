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
                    easy_install pip
                    export PATH=${PATH}:/usr/local/bin # For pip
                    ./.travis-extra-install.sh
                    export PATH=$PATH:/tmp/ffmpeg
                    ./scripts/setup-npm.sh
                    ./.travis-requirements-build.sh

                    pip install -r .travis-${REQUIREMENTS}-requirements.txt
                    pip install -e .[all]
                    ./scripts/setup-assets.sh
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
