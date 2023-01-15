#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

// define which TensorFlow versions to use
def getTFVers(){
    return ["2.10.0", "2.11.0"]
}

def getDefaultOneclient(){
    return "20.02.19-1~focal"
}

def getPyTorchTags(){
    return ["1.12.0-cuda11.3-cudnn8-runtime", "1.13.0-cuda11.6-cudnn8-runtime"]
}

def getPyTorchVers(){
    return ["1.12", "1.13"]
}

def getPyTorchOneclient(){
    return ["20.02.19-1~bionic", "20.02.19-1~bionic"]
}

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-generic-dev"
    }

    stages {

        stage('Validate metadata') {
            steps {
                checkout scm
                sh 'deep-app-schema-validator metadata.json'
            }
        }

        stage('Docker image building (std)') {
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    // pyTorch
//                    pytorch_tags = getPyTorchTags()
//                    pytorch_vers = getPyTorchVers()
//                    pytorch_oneclient_vers = getPyTorchOneclient()
//                    p_vers = pytorch_vers.size()
//
//                    // CAREFUL! For-loop might fail in some Jenkins versions
//                    // Other options: 
//                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
//                    for(int j=0; j < p_vers; j++) {
//                        tag_id = ['pytorch'+pytorch_vers[j]]
//                        pytorch_tag = pytorch_tags[j]
//                        oneclient_ver = pytorch_oneclient_vers[j]
//                        id_pytorch = DockerBuild(id,
//                                                 tag: tag_id,
//                                                 build_args: ["image=pytorch/pytorch",
//                                                              "tag=${pytorch_tag}",
//                                                              "oneclient_ver=${oneclient_ver}"])
//                        DockerPush(id_pytorch)
//
//                        // immediately remove local image
//                        id_this = id_pytorch[0]
//                        sh("docker rmi --force \$(docker images -q ${id_this})")
//                    }

                    // TensorFlow
                    tf_vers = getTFVers()
                    n_vers = tf_vers.size()

                    // CAREFUL! For-loop might fail in some Jenkins versions
                    // Other options: 
                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
                    for(int j=0; j < n_vers; j++) {
                        tags = ['tf'+tf_vers[j]+'-cpu', 
                                'tf'+tf_vers[j]+'-gpu'] 

                        tf_tags = [tf_vers[j],
                                   tf_vers[j]+'-gpu']

                        tf_oneclient_ver = getDefaultOneclient()

                        for(int i=0; i < tags.size(); i++) {
                            tag_id = [tags[i]]
                            if (j == (n_vers - 1) && tags[i].contains("-cpu")) {
                                tag_id = [tags[i], 'latest']
                            }
                            tf_tag = tf_tags[i]
                            id_docker = DockerBuild(id,
                                                    tag: tag_id,
                                                    build_args: ["tag=${tf_tag}",
                                                                 "oneclient_ver=${tf_oneclient_ver}"])
                            DockerPush(id_docker)

                            // immediately remove local image
                            id_this = id_docker[0]
                            sh("docker rmi --force \$(docker images -q ${id_this})")
                            //sh("docker rmi --force \$(docker images -q tensorflow/tensorflow:${tf_tag})")
                        }
                    }
               }
            }
            post {
                failure {
                   DockerClean()
                }
            }
        }

        stage('Docker image building (ubuntu 20.04)') {
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    // Finally, we put all DEEP components in 
                    // ubuntu 20.04 image without deep learning framework
                    oneclient_ver = getDefaultOneclient()
                    id_u2004 = DockerBuild(id,
                                           tag: ['u20.04'],
                                           build_args: ["image=ubuntu",
                                                        "tag=20.04",
                                                        "oneclient_ver=${oneclient_ver}"])
                    DockerPush(id_u2004)

                    // immediately remove local image
                    id_this = id_u2004[0]
                    sh("docker rmi --force \$(docker images -q ${id_this})")
                    //sh("docker rmi --force \$(docker images -q ubuntu:18.04)")
                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }

        stage("Render metadata on the marketplace") {
            when {
                allOf {
                    branch 'master'
                    changeset 'metadata.json'
                }
            }
            steps {
                script {
                    def job_result = JenkinsBuildJob("Pipeline-as-code/deephdc.github.io/pelican")
                    job_result_url = job_result.absoluteUrl
                }
            }
        }
    }
}
