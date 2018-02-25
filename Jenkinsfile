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
                sh 'echo "Nothing here yet"'
            }
        }

        stage("Run tests") {
            steps {
                sh "./run-tests.sh"
            }

            post {
                always {
                    junit "build/junit/*.xml"
                    step([
                        $class: "CloverPublisher",
                        cloverReportDir: "build/coverage",
                        cloverReportFileName: "clover.xml"
                    ])
                }
            }
        }
    }
}
