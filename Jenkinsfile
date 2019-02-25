#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.0.0']) _

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
                    DockerBuild(id,
                                build_args: ["tag=${env.tf_ver}-py3",
                                             "pyVer=python3"])

                    // GPU + python3
                    DockerBuild("${id}:tf-gpu", 
                                build_args: ["tag=${env.tf_ver}-gpu-py3",
                                             "pyVer=python3"])

                    // CPU + python2
                    DockerBuild("${id}:tf-py2", 
                                build_args: ["tag=${env.tf_ver}",
                                             "pyVer=python"])

                    // GPU + python2
                    DockerBuild("${id}:tf-gpu-py2", 
                                build_args: ["tag=${env.tf_ver}-gpu",
                                             "pyVer=python"])

                    // ubuntu-only (18.04 + python3.6)
                    DockerBuild("${id}:u18.04", 
                                build_args: ["image=ubuntu",
                                             "tag=18.04",
                                             "pyVer=python3"])
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
