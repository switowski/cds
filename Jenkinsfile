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
                // Get docker compose
                sh "curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
                sh "docker-compose build"
                sh "docker-compose up -d"
            }
        }

        stage("Run tests") {
            steps {
                sh "docker-compose exec -T ./run-tests.sh"
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

    post {
        always {
            sh "docker-compose down || true"
        }
    }
}
