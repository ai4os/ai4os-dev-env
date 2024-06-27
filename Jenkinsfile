#!/usr/bin/groovy

//////////  DEFINE WHAT VERSIONS TO BUILD  //////////
// define which Ubuntu versions to use
def getUbuntuVers(){
    return ["20.04", "22.04"]
}

// define which nvidia/cuda versions to use
def getNVCudaVers(){
    return["11.3.1","12.3.2"]
}
// define which nvidia/cuda tags to use
def getNVCudaTags(){
    return ["11.3.1-cudnn8-runtime-ubuntu20.04",
            "12.3.2-cudnn9-runtime-ubuntu22.04"]
}

// define which TensorFlow versions to use
def getTFVers(){
    return ["2.9.3", "2.10.0", "2.11.0", "2.12.0", "2.13.0", "2.14.0"]
}

// define which pytorch versions to use
def getPyTorchVers(){
    return ["1.11", "1.12", "1.13", "2.0", "2.1"]
}
// define which pytorch tags to use
def getPyTorchTags(){
    return ["1.11.0-cuda11.3-cudnn8-runtime", 
            "1.12.0-cuda11.3-cudnn8-runtime", 
            "1.13.0-cuda11.6-cudnn8-runtime", 
            "2.0.0-cuda11.7-cudnn8-runtime", 
            "2.1.0-cuda11.8-cudnn8-runtime"]
}
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
            }
            steps {
                checkout scm
                script {
                    withFolderProperties{
                        docker_registry = env.AI4OS_REGISTRY
                        docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS
                        docker_registry_org = env.AI4OS_REGISTRY_REPOSITORY
                    }
                    // get docker image name from metadata.json
                    meta = readJSON file: "metadata.json"
                    image_name = meta["sources"]["docker_registry_repo"].split("/")[1]
                    docker_repository = docker_registry_org + "/" + image_name
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
                    steps{
                        checkout scm
                        script {
                            // Ubuntu versions
                            def dev_env_u_tags = []
                            def ubuntu_vers = getUbuntuVers()
                            ubuntu_vers.each { dev_env_u_tags.add("u$it")}
                            dev_env_build("ubuntu", getUbuntuVers(), dev_env_u_tags, true)
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
                    steps{
                        checkout scm
                        script {
                            // nvidia CUDA versions
                            def dev_env_cuda_tags = []
                            def cuda_vers = getNVCudaVers()
                            cuda_vers.each { dev_env_cuda_tags.add("cuda$it")}
                            dev_env_build("nvidia/cuda", getNVCudaTags(), dev_env_cuda_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }

                stage('Docker images building (pytorch)') {
                    agent { label 'docker-build' }
                    when {
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
                    steps{
                        checkout scm
                        script {
                            // Pytorch versions
                            def dev_env_torch_tags = []
                            def pytorch_vers = getPyTorchVers()
                            pytorch_vers.each { dev_env_torch_tags.add("pytorch$it")}
                            dev_env_build("pytorch/pytorch", getPyTorchTags(), dev_env_torch_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }

                stage('Docker images building (tensorflow-cpu)') {
                    agent { label 'docker-build' }
                    when {
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
                    steps{
                        checkout scm
                        script {
                            // TensorFlow - CPU versions
                            def tfcpu_vers = getTFVers()
                            def dev_env_tfcpu_tags = []
                            tfcpu_vers.each { dev_env_tfcpu_tags.add("tf$it"+"-cpu")}
                            dev_env_build("tensorflow/tensorflow", tfcpu_vers, dev_env_tfcpu_tags, true)
                       }
                    }
                    post {
                        failure {
                            docker_clean()
                            sh "rm -rf ai4os-hub-check-artifact"
                        }
                    }
                }
                
                stage('Docker images building (tensorflow-gpu)') {
                    agent { label 'docker-build' }
                    when {
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
                    steps{
                        checkout scm
                        script {
                            // TensorFlow - GPU versions
                            def base_image_tfgpu_tags = []
                            def tfgpu_vers = getTFVers()
                            tfgpu_vers.each { base_image_tfgpu_tags.add("$it"+"-gpu")}
                            def dev_env_tfgpu_tags = []
                            tfgpu_vers.each { dev_env_tfgpu_tags.add("tf$it"+"-gpu")}
                            dev_env_build("tensorflow/tensorflow", base_image_tfgpu_tags, dev_env_tfgpu_tags, false)
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
