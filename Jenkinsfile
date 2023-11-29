#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

// define which TensorFlow versions to use
def getTFVers(){
    return ["2.9.3", "2.10.0", "2.11.0", "2.12.0", "2.13.0"]
}

def getPyTorchTags(){
    return ["1.11.0-cuda11.3-cudnn8-runtime", "1.12.0-cuda11.3-cudnn8-runtime", "1.13.0-cuda11.6-cudnn8-runtime", "2.0.0-cuda11.7-cudnn8-runtime", "2.1.0-cuda11.8-cudnn8-runtime"]
}

def getPyTorchVers(){
    return ["1.11", "1.12", "1.13", "2.0", "2.1"]
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
                    pytorch_tags = getPyTorchTags()
                    pytorch_vers = getPyTorchVers()
                    pytorch_oneclient_vers = getPyTorchOneclient()
                    p_vers = pytorch_vers.size()

                    // CAREFUL! For-loop might fail in some Jenkins versions
                    // Other options: 
                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
                    for(int j=0; j < p_vers; j++) {
                        tag_id = ['pytorch'+pytorch_vers[j]]
                        pytorch_tag = pytorch_tags[j]
                        oneclient_ver = pytorch_oneclient_vers[j]
                        id_pytorch = DockerBuild(id,
                                                 tag: tag_id,
                                                 build_args: ["image=pytorch/pytorch",
                                                              "tag=${pytorch_tag}"])
                        DockerPush(id_pytorch)

                        // immediately remove local image
                        id_this = id_pytorch[0]
                        sh("docker rmi --force \$(docker images -q ${id_this})")
                    }

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

                        for(int i=0; i < tags.size(); i++) {
                            tag_id = [tags[i]]
                            // tag last cpu tag as "latest"
                            if (j == (n_vers - 1) && tags[i].contains("-cpu")) {
                                tag_id = [tags[i], 'latest']
                            }
                            // tag last gpu tag as "latest-gpu"
                            if (j == (n_vers - 1) && tags[i].contains("-gpu")) {
                                tag_id = [tags[i], 'latest-gpu']
                            }
                            tf_tag = tf_tags[i]
                            id_docker = DockerBuild(id,
                                                    tag: tag_id,
                                                    build_args: ["image=tensorflow/tensorflow",
                                                                 "tag=${tf_tag}"])
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

        stage('Docker image building (ubuntu)') {
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

                    // Finally, we put all AI4OS components in 
                    // ubuntu 20.04 image without deep learning framework
                    id_u2004 = DockerBuild(id,
                                           tag: ['u20.04'],
                                           build_args: ["image=ubuntu",
                                                        "tag=20.04"])
                    DockerPush(id_u2004)

                    id_u2204 = DockerBuild(id,
                                           tag: ['u22.04'],
                                           build_args: ["image=ubuntu",
                                                        "tag=22.04"])
                    DockerPush(id_u2204)

                    // immediately remove local image
                    id_this = id_u2004[0]
                    sh("docker rmi --force \$(docker images -q ${id_this})")
                    id_this = id_u2204[0]
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

    }
}
