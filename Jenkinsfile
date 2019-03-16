#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-generic-dev"
        tf_ver = "1.10.0"
    }

    stages {
        stage('Docker image building') {
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    // CPU + python3 (aka default)
                    id_cpu = DockerBuild(id,
                                         tag: ['latest','tf-cpu'],
                                         build_args: ["tag=${env.tf_ver}-py3",
                                                      "pyVer=python3"])

                    // GPU + python3
                    id_gpu = DockerBuild(id,
                                         tag: ['tf-gpu'], 
                                         build_args: ["tag=${env.tf_ver}-gpu-py3",
                                                      "pyVer=python3"])

                    // CPU + python2
                    id_cpu_py2 = DockerBuild(id,
                                            tag: ['tf-py2'], 
                                            build_args: ["tag=${env.tf_ver}",
                                                         "pyVer=python"])

                    // GPU + python2
                    id_gpu_py2 = DockerBuild(id,
                                             tag: ['tf-gpu-py2'], 
                                             build_args: ["tag=${env.tf_ver}-gpu",
                                                          "pyVer=python"])

                    // CPU + python3.6 (ubuntu18.04 + python3.6 + tf1.12.0)
                    id_cpu_py36 = DockerBuild(id,
                                              tag: ['tf-py36'],
                                              build_args: ["image=deephdc/tensorflow",
                                                           "tag=1.12.0-py36",
                                                           "pyVer=python3"])

                    // GPU + python3.6 (ubuntu18.04 + python3.6 + tf1.12.0)
                    id_gpu_py36 = DockerBuild(id,
                                              tag: ['tf-gpu-py36'],
                                              build_args: ["image=deephdc/tensorflow",
                                                           "tag=1.12.0-gpu-py36",
                                                           "pyVer=python3"])
                    // ubuntu-only (18.04 + python3.6)
                    id_u1804 = DockerBuild(id,
                                           tag: ['u18.04'],
                                           build_args: ["image=ubuntu",
                                                        "tag=18.04",
                                                        "pyVer=python3"])
                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }

        stage('Docker Hub delivery') {
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                script {
                    DockerPush(id_cpu)
                    DockerPush(id_gpu)
                    DockerPush(id_cpu_py2)
                    DockerPush(id_gpu_py2)
                    DockerPush(id_cpu_py36)
                    DockerPush(id_gpu_py36)
                    DockerPush(id_u1804)
                }
            }
            post {
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
