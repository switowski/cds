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
                sh './.travis-extra-install.sh'
                sh 'export PATH=$PATH:/tmp/ffmpeg'
                sh './scripts/setup-npm.sh'
                sh './.travis-requirements-build.sh'

                sh 'pip install -r .travis-${REQUIREMENTS}-requirements.txt'
                sh 'pip install -e .[all]'
                sh './scripts/setup-assets.sh'
            }
        }

        stage("Run tests") {
            steps {
                sh "./run-tests.sh"
            }
        }
    }
}
