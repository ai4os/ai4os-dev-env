#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library']) _

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-generic-dev"
        tf_ver = "1.10.0"
    }

    stages {
        stage('DockerHub delivery') {
            //when {
            //    anyOf {
            //       branch 'master'
            //       buildingTag()
            //   }
            //}
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    // CPU + python3 (aka default)
                    sh "docker build --no-cache --force-rm -t ${id} \
                        --build-arg tag=${env.tf_ver}-py3 \
                        --build-arg pyVer=python3 ."

                    // GPU + python3
                    sh "docker build --no-cache --force-rm -t ${id}:tf-gpu \
                        --build-arg tag=${env.tf_ver}-gpu-py3 \
                        --build-arg pyVer=python3 ."

                    // CPU + python2
                    sh "docker build --no-cache --force-rm -t ${id}:tf-py2 \
                        --build-arg tag=${env.tf_ver} \
                        --build-arg pyVer=python ."

                    // GPU + python2
                    sh "docker build --no-cache --force-rm -t ${id}:tf-gpu-py2 \
                        --build-arg tag=${env.tf_ver}-gpu \
                        --build-arg pyVer=python ."

                    // ubuntu-only (18.04 + python3.6)
                    sh "docker build --no-cache --force-rm -t ${id}:u18.04 \
                        --build-arg image=ubuntu \
                        --build-arg tag=18.04 \
                        --build-arg pyVer=python3 ."

                }
            }
            post {
                success {
                    DockerPush(dockerhub_repo) // should push all tags
                }
                failure {
                    DockerClean()
                }
                always {
                    cleanWs()
                }
            }
        }
    }
}
