#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

// define which TensorFlow versions to use
def getTFVers(){
    return ["1.12.0", "1.14.0", "2.0.0"]
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

                    tf_vers = getTFVers()
                    n_vers = tf_vers.size()

                    // CAREFUL! For-loop might fail in some Jenkins versions
                    // Other options: 
                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
                    for(int j=0; j < n_vers; j++) {
                        tags = ['tf'+tf_vers[j]+'-cpu', 
                                'tf'+tf_vers[j]+'-gpu'] 

                        tf_tags = [tf_vers[j]+'-py3',
                                   tf_vers[j]+'-gpu-py3']

                        for(int i=0; i < tags.size(); i++) {
                            tag_id = [tags[i]]
                            if (j == (n_vers - 1) && tags[i].contains("-cpu")) {
                                tag_id = [tags[i], 'latest']
                            }
                            tf_tag = tf_tags[i]
                            id_docker = DockerBuild(id,
                                                    tag: tag_id,
                                                    build_args: ["tag=${tf_tag}",
                                                                 "pyVer=python3"])
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

        stage('Docker image building (TF 1.12.0 with python2, python3.6)') {
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

                    tf_vers = getTFVers()
                    n_vers = tf_vers.size()

                    // For the case of TF1.12.0 we also build images with 
                    // - python2
                    // - custom images with Ubuntu 18.04 + python3.6
                    tags_1120 = ['tf1.12.0-cpu-py2', 
                                 'tf1.12.0-gpu-py2',
                                 'tf1.12.0-cpu-py36',
                                 'tf1.12.0-gpu-py36' ]

                    tf_images_1120 = ['tensorflow/tensorflow',
                                      'tensorflow/tensorflow',
                                      'deephdc/tensorflow',
                                      'deephdc/tensorflow']

                    tf_tags_1120 = ['1.12.0', '1.12.0-gpu', 
                                    '1.12.0-py36', '1.12.0-gpu-py36']

                    pyVers_1120 = ['python', 'python', 'python3', 'python3']

                    for(int i=0; i < tags_1120.size(); i++) {
                        tag_id = [tags_1120[i]]
                        tf_image = tf_images_1120[i]
                        tf_tag = tf_tags_1120[i]
                        py_ver = pyVers_1120[i]
                        id_1120 = DockerBuild(id,
                                              tag: tag_id,
                                              build_args: ["image=${tf_image}",
                                                           "tag=${tf_tag}",
                                                           "pyVer=${py_ver}"])
                         DockerPush(id_1120)

                         // immediately remove local image
                         id_this = id_1120[0]
                         sh("docker rmi --force \$(docker images -q ${id_this})")
                         //sh("docker rmi --force \$(docker images -q ${tf_image}:${tf_tag})")
                    }
               }
            }
            post {
                failure {
                   DockerClean()
                }
            }
        }

        stage('Docker image building (ubuntu 18.04)') {
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
                    // ubuntu 18.04 image without deep learning framework
                    id_u1804 = DockerBuild(id,
                                           tag: ['u18.04'],
                                           build_args: ["image=ubuntu",
                                                        "tag=18.04",
                                                        "pyVer=python3"])
                    DockerPush(id_u1804)

                    // immediately remove local image
                    id_this = id_u1804[0]
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
