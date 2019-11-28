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
        dockerhub_repo = "vykozlov/deep-oc-generic-dev"
        url_repo_clean = "https://cloud.docker.com/v2/repositories/${dockerhub_repo}"
    }

    stages {

        stage('Validate metadata') {
            steps {
                checkout scm
                sh 'deep-app-schema-validator metadata.json'
            }
        }

        stage('Docker image building') {
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
                    echo "${env.url_repo_clean}"
                    // Test if we can clean whole repository:
                    docker_credentials  = credentials('indigobot')
                    sh "curl -u ${docker_credentials_USR}:${docker_credentials_PSW} -X \"DELETE\" ${env.url_repo_clean}"

                    //withDockerRegistry([credentialsId: 'indigobot', url: '']) {
                    //withCredentials([usernamePassword(credentialsId: 'indigobot', 
                    //                 usernameVariable: 'USERNAME', 
                    //                 passwordVariable: 'PASSWORD')]) {
                    //    def url_clean = "${env.url_repo_clean}"
                    //    sh '''
                    //       echo "${url_clean}"
                    //       curl -u ${USERNAME}:${PASSWORD} -X "DELETE" ${url_clean}"
                    //       '''
                    }

                    tf_vers = getTFVers()

                    // CAREFUL! For-loop might fail in some Jenkins versions
                    // Another option: 
                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
                    for(int j=0; j < tf_vers.size(); j++) {
                        tags = ['tf'+tf_vers[j]+'-cpu', 
                                'tf'+tf_vers[j]+'-gpu'] 

                        tf_tags = [tf_vers[j]+'-py3',
                                   tf_vers[j]+'-gpu-py3']

                        n_tags = tags.size()
                        for(int i=0; i < n_tags; i++) {
                            tag_id = [tags[i]]
                            if (i == (n_tags - 1)) {
                                tag_id = [tags[i], 'latest']
                            }
                            tf_tag = tf_tags[i]
                            id_docker = DockerBuild(id,
                                                    tag: tag_id,
                                                    build_args: ["tag=${tf_tag}",
                                                                 "pyVer=python3"])
                           DockerPush(id_docker)
                           DockerClean(id_docker[0]) //id_docker is an array
                        }
                    }

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
                                    'tf-py36', 'tf-gpu-py36']

                    pyVes_1120 = ['python', 'python', 'python3', 'python3']

                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }

        //stage('Docker Hub delivery') {
        //
        //    steps{
        //        script {
        //            //DockerPush(id_cpu)
        //            //DockerPush(id_gpu)
        //            //DockerPush(id_cpu_py2)
        //            //DockerPush(id_gpu_py2)
        //            //DockerPush(id_cpu_py36)
        //            //DockerPush(id_gpu_py36)
        //            //DockerPush(id_u1804)
        //        }
        //    }
        //    post {
        //        failure {
        //            DockerClean()
        //        }
        //        always {
        //            cleanWs()
        //        }
        //    }
        //}

        stage("Render metadata on the marketplace") {
            when {
                allOf {
                    branch 'master'
                    changeset 'metadata.json'
                }
            }
            steps {
                script {
                    //def job_result = JenkinsBuildJob("Pipeline-as-code/deephdc.github.io/pelican")
                    job_result_url = job_result.absoluteUrl
                }
            }
        }
    }
}
