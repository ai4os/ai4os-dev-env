#!/usr/bin/groovy

// function to build a docker image
def docker_build(image, base_image, base_tag) {
    docker.build(image,
                "--no-cache --force-rm --build-arg image=${base_image} --build-arg tag=${base_tag} .")

}
// function to push image to registry
def docker_push(id_this) {
    println ("[DEBUG] $id_this")
    docker.withRegistry(docker_registry, 
        docker_registry_credentials) {
        id_this.push()
    }

}

def docker_clean() {
    def dangling_images = sh(
		returnStdout: true,
		script: "docker images -f 'dangling=true' -q"
	)
    if (dangling_images) {
        sh(script: "docker rmi --force $dangling_images")
    }
}

// define which Ubuntu versions to use
def getUbuntuVers(){
    return ["20.04", "22.04"]
}

// define which TensorFlow versions to use
def getTFVers(){
    return ["2.9.3", "2.10.0", "2.11.0", "2.12.0", "2.13.0"]
}

// define which pytorch tags to use
def getPyTorchTags(){
    return ["1.11.0-cuda11.3-cudnn8-runtime", "1.12.0-cuda11.3-cudnn8-runtime", "1.13.0-cuda11.6-cudnn8-runtime", "2.0.0-cuda11.7-cudnn8-runtime", "2.1.0-cuda11.8-cudnn8-runtime"]
}

// define which pytorch versions to use
def getPyTorchVers(){
    return ["1.11", "1.12", "1.13", "2.0", "2.1"]
}

pipeline {
    agent {
        label 'docker-build'
    }

    stages {

        stage("Variable initialization") {
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
                    println("[DEBUG] ${docker_registry}")
                    println("[DEBUG] ${docker_repository}")
                }
            }
        }

        stage('Docker images building (ubuntu)') {
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // clone check-artifact script
                    sh "rm -rf ai4os-hub-check-artifact"
                    sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
                    // Let's put all AI4OS components in 
                    // ubuntu images without deep learning framework
                    base_image="ubuntu"
                    ubuntu_vers = getUbuntuVers()
                    u_vers = ubuntu_vers.size()
                    for(int j=0; j < u_vers; j++) {
                        image = docker_repository + ":u" + ubuntu_vers[j]
                        println("[DEBUG] ${image}")
                        id_ubuntu = docker_build(image, base_image, ubuntu_vers[j])

                        // let's check builded artifact
                        sh "bash ai4os-hub-check-artifact/check-artifact ${image} 8888"

                        // if OK, push to registry
                        docker_push(id_ubuntu)

                        // immediately remove local image
                        sh("docker rmi --force \$(docker images -q ${image})")
                    }
                    sh "rm -rf ai4os-hub-check-artifact"
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
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // clone check-artifact script
                    sh "rm -rf ai4os-hub-check-artifact"
                    sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"

                    // pyTorch
                    base_image = "pytorch/pytorch"
                    pytorch_vers = getPyTorchVers()
                    pytorch_tags = getPyTorchTags()
                    p_vers = pytorch_vers.size()

                    // CAREFUL! For-loop might fail in some Jenkins versions
                    // Other options: 
                    // https://stackoverflow.com/questions/37594635/why-an-each-loop-in-a-jenkinsfile-stops-at-first-iteration
                    for(int j=0; j < p_vers; j++) {
                        image = docker_repository + ":" + "pytorch" + pytorch_vers[j]
                        println("[DEBUG] ${image}")
                        id_pytorch = docker_build(image, base_image, pytorch_tags[j])

                        // let's check builded artifact
                        sh "bash ai4os-hub-check-artifact/check-artifact ${image} 8888"

                        // if OK, push to registry
                        docker_push(id_pytorch)

                        // immediately remove local image
                        sh("docker rmi --force \$(docker images -q ${image})")
                    }
               }
            }
            post {
                failure {
                    docker_clean()
                    sh "rm -rf ai4os-hub-check-artifact"
                }
            }
        }

        stage('Docker images building (tensorflow)') {
            when {
                anyOf {
                   branch 'master'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // clone check-artifact script
                    sh "rm -rf ai4os-hub-check-artifact"
                    sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"

                    // TensorFlow
                    base_image = "tensorflow/tensorflow"
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
                            image = docker_repository + ":" + tags[i]
                            println("[DEBUG] ${image}")
                            id_tf = docker_build(image, base_image, tf_tags[i])

                            // let's check builded artifact (only "cpu" image)
                            if (tags[i].contains("-cpu")) {
                                sh "bash ai4os-hub-check-artifact/check-artifact ${image} 8888"
                            }

                            // if OK, push to registry
                            docker_push(id_tf)
                            // tag last cpu tag as "latest"
                            if (j == (n_vers - 1) && tags[i].contains("-cpu")) {
                                println ("[DEBUG] $id_tf")
                            }
                            // tag last gpu tag as "latest-gpu"
                            if (j == (n_vers - 1) && tags[i].contains("-gpu")) {
                                println ("[DEBUG] $id_tf")
                            }

                            // immediately remove local image
                            sh("docker rmi --force \$(docker images -q ${image})")
                        }
                    }
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
