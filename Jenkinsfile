#!/usr/bin/groovy

//////////              !!! IMPORTANT !!!             //////////
//////////  DEFINE WHAT FLAVOR and VERSIONS TO BUILD  //////////

// define which flavors of ai4os-dev-env to build
def builds = ['Ubuntu': false, 'NVCuda': true, 'PyTorch': true, 'TF': true]

// Ubuntu versions to use
// OnneData not yet ready for Ubuntu:26.04
def UbuntuVers = ["24.04"]
// legacy
//def UbuntuVers = ["20.04", "22.04"]

// nvidia/cuda versions to use
def NVCudaVers = ["12.8.1","13.0.3"]
def NVCudaTags = ["12.8.1-cudnn-runtime-ubuntu22.04","13.0.3-cudnn-runtime-ubuntu24.04"]
// legacy
//def NVCudaVers = ["11.3.1","12.3.2"]
//def NVCudaTags = ["11.3.1-cudnn8-runtime-ubuntu20.04", "12.3.2-cudnn9-runtime-ubuntu22.04"]


// pytorch versions and tags to use
def PyTorchVers = ["2.5", "2.6"]
def PyTorchTags = ["2.5.1-cuda12.4-cudnn9-runtime", "2.6.0-cuda12.6-cudnn9-runtime"]
//def PyTorchVers = ["2.3", "2.4"]
//def PyTorchTags = ["2.3.1-cuda11.8-cudnn8-runtime", "2.4.1-cuda12.4-cudnn9-runtime"]
// legacy
//def PyTorchVers = ["1.11", "1.12", "1.13", "2.0", "2.1"]
//def PyTorchTags = ["1.11.0-cuda11.3-cudnn8-runtime", "1.12.0-cuda11.3-cudnn8-runtime", "1.13.0-cuda11.6-cudnn8-runtime", 
//                   "2.0.0-cuda11.7-cudnn8-runtime",  "2.1.0-cuda11.8-cudnn8-runtime"]

// tensorflow versions to use - only version number!
// "-gpu" suffix is added below such that base images become e.g. tensorflow/tensorflow:2.16.2-gpu
def TFVers = ["2.17.0", "2.18.0"]
//def TFVers = ["2.15.0", "2.16.2"]
// legacy
//def TFVers = ["2.9.3", "2.10.0", "2.11.0", "2.12.0", "2.13.0", "2.14.0"]

//////////

// function to build a docker image
def docker_build(image, base_image, base_tag) {
    docker.build(image,
                "--no-cache --force-rm --build-arg image=${base_image} --build-arg tag=${base_tag} .")

}
// function to push image to registry
def docker_push(id_this) {
    println ("[DEBUG] Docker image to push: $id_this")
    docker.withRegistry(docker_registry, 
        docker_registry_credentials) {
        id_this.push()
    }
}
// function to remove built images
def docker_clean() {
    def dangling_images = sh(
		returnStdout: true,
		script: "docker images -f 'dangling=true' -q"
	)
    if (dangling_images) {
        sh(script: "docker rmi --force $dangling_images")
    }
}

// function to build dev-env for the certain framework
def dev_env_build(base_image, base_image_tags, dev_env_tags, check){
    // clone check-artifact script
    if (check) {
        sh "rm -rf ai4os-hub-check-artifact"
        sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
    }
    def n_tags = dev_env_tags.size()
    for(int j=0; j < n_tags; j++) {
        def image = docker_repository + ":" + dev_env_tags[j]
        println("[DEBUG] Docker image to build: ${image}")
        def id_docker = docker_build(image, base_image, base_image_tags[j])
        // let's check builded artifact
        if (check) {
            sh "bash ai4os-hub-check-artifact/check-artifact ${image} 8888"
        }
        // if OK, push to registry
        docker_push(id_docker)
        // immediately remove local image
        sh("docker rmi --force \$(docker images -q ${image})")
    }
    if (check) {
        sh "rm -rf ai4os-hub-check-artifact"
    }
}

pipeline {
    agent none
    stages {

        stage("Variable initialization") {
            agent any
            environment {
                AI4OS_REGISTRY_CREDENTIALS = credentials('AIOS-registry-credentials')
                // Remove .git from the GIT_URL link
                REPO_URL = "${env.GIT_URL.endsWith(".git") ? env.GIT_URL[0..-5] : env.GIT_URL}"
                REPO_NAME = "${REPO_URL.tokenize('/')[-1]}"                
            }
            steps {
                checkout scm
                script {
                    withFolderProperties{
                        docker_registry = env.AI4OS_REGISTRY
                        docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS
                        docker_registry_org = env.AI4OS_REGISTRY_REPOSITORY
                    }
                    // docker image name is the same as the repository name, e.g. ai4os-dev-env
                    image_name = env.REPO_NAME
                    docker_repository = docker_registry_org + "/" + image_name
                    sh "docker --version"
                }
            }
        }

        // attempt to run builds in parallel
        stage('Build') {
            parallel {

                stage('Docker images building (ubuntu)') {
                    agent { label 'docker-build' }
                    when {
                        allOf {
                            expression { builds['Ubuntu'] }
                            anyOf {
                                triggeredBy 'UserIdCause'

                                allOf {
                                    anyOf {
                                        branch 'main'
                                        buildingTag()
                                    }
                                    anyOf {
                                        changeset 'Jenkinsfile'
                                        changeset 'Dockerfile'
                                        changeset 'entrypoint.sh'
                                    }
                                }
                            }
                        }
                    }
                    steps{
                        checkout scm
                        script {
                            // Ubuntu versions
                            def dev_env_u_tags = []
                            def ubuntu_vers = UbuntuVers
                            ubuntu_vers.each { dev_env_u_tags.add("u$it")}
                            dev_env_build("ubuntu", UbuntuVers, dev_env_u_tags, true)
                        }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }

                stage('Docker images building (nvidia/cuda)') {
                    agent { label 'docker-build' }
                    when {
                        allOf {
                            expression { builds['NVCuda'] }
                            anyOf {
                                triggeredBy 'UserIdCause'

                                allOf {
                                    anyOf {
                                        branch 'main'
                                        buildingTag()
                                    }
                                    anyOf {
                                        changeset 'Jenkinsfile'
                                        changeset 'Dockerfile'
                                        changeset 'entrypoint.sh'
                                    }
                                }
                            }
                        }
                    }
                    steps{
                        checkout scm
                        script {
                            // nvidia CUDA versions
                            def dev_env_cuda_tags = []
                            def nvcuda_vers = NVCudaVers
                            nvcuda_vers.each { dev_env_cuda_tags.add("cuda$it")}
                            dev_env_build("nvidia/cuda", NVCudaTags, dev_env_cuda_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }

                stage('Docker images building (PyTorch)') {
                    agent { label 'docker-build' }
                    when {
                        allOf {
                            expression { builds['PyTorch'] }
                            anyOf {
                                triggeredBy 'UserIdCause'

                                allOf {
                                    anyOf {
                                        branch 'main'
                                        buildingTag()
                                    }
                                    anyOf {
                                        changeset 'Jenkinsfile'
                                        changeset 'Dockerfile'
                                        changeset 'entrypoint.sh'
                                    }
                                }
                            }
                        }
                    }
                    steps{
                        checkout scm
                        script {
                            // Pytorch versions
                            def dev_env_torch_tags = []
                            def pytorch_vers = PyTorchVers
                            pytorch_vers.each { dev_env_torch_tags.add("pytorch$it")}
                            dev_env_build("pytorch/pytorch", PyTorchTags, dev_env_torch_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }
                
                stage('Docker images building (TensorFlow)') {
                    agent { label 'docker-build' }
                    when {
                        allOf {
                            expression { builds['TF'] }
                            anyOf {
                                triggeredBy 'UserIdCause'

                                allOf {
                                    anyOf {
                                        branch 'main'
                                        buildingTag()
                                    }
                                    anyOf {
                                        changeset 'Jenkinsfile'
                                        changeset 'Dockerfile'
                                        changeset 'entrypoint.sh'
                                    }
                                }
                            }
                        }
                    }
                    steps{
                        checkout scm
                        script {
                            // TensorFlow : since 16-Aug-2024 we use only TF GPU versions,
                            // as they can also work on CPU-only instances
                            def base_image_tf_tags = []
                            def tf_vers = TFVers
                            tf_vers.each { base_image_tf_tags.add("$it"+"-gpu")}
                            def dev_env_tf_tags = []
                            tf_vers.each { dev_env_tf_tags.add("tf$it")}
                            dev_env_build("tensorflow/tensorflow", base_image_tf_tags, dev_env_tf_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }
            }
        }
    }
}
