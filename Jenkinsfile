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
                    id = ${dockerhub_repo}

                    // 'default': GPU + python3
                    sh "docker build --no-cache --force-rm -t ${id} \
                        --build-arg tag=${tf_ver}-gpu-py3 \
                        --build-arg pyVer=python3 ."

                    // CPU + python3
                    sh "docker build --no-cache --force-rm -t ${id}:cpu \
                        --build-arg tag=${tf_ver}-py3 \
                        --build-arg pyVer=python3 ."

                    // GPU + python2
                    sh "docker build --no-cache --force-rm -t ${id}:py2 \
                        --build-arg tag=${tf_ver}-gpu \
                        --build-arg pyVer=python ."

                    // CPU + python2
                    sh "docker build --no-cache --force-rm -t ${id}:cpu-py2 \
                        --build-arg tag=${tf_ver} \
                        --build-arg pyVer=python ."

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
