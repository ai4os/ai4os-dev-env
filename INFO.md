<div align="center">
<img src="https://marketplace.deep-hybrid-datacloud.eu/images/logo-deep.png" alt="logo" width="300"/>
</div>

# Welcome to DEEP Developement Environment

**Project:** This work is part of the [DEEP Hybrid-DataCloud](https://deep-hybrid-datacloud.eu/) project that has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 777435.

## Table of Content

* [Introduction](#Introduction)
* [Configure git for commits](#Configure-git-for-commits)
* [Start your project with DEEP Data Science template](#Start-your-project-with-DEEP-Data-Science-template)
* [Access remote storages](#Access-remote-storages)
* [DEEP Documentation](#DEEP-Documentation)
* [DEEP related services](#DEEP-related-services)
* [List of installed tools](#List-of-installed-tools)
* [Acknowledgments](#Acknowledgments)

## Introduction

DEEP Development Environment (DDE) aims to facilitate the integration of your code with DEEP solutions, development and testing it directly in the cloud environment. Please, see the [List of installed tools](#List-of-installed-tools) and [DEEP Documentation](#DEEP-Documentation) for more details.

## Configure git for commits

Using pre-installed `git` you can easily clone projects in DDE. If you want to commit your changes back, you have to configure global `user.name` and `user.email` as follows: 

```bash
$ git config --global user.name "Your Name"
$ git config --global user.email "your_email_for_git_account@domain.zone"
```

## Start your project with DEEP Data Science template

Create your new project using our [Data Science template](https://github.com/deephdc/cookiecutter-deep) for easier integration with DEEP components ([DEEPaaS API](https://docs.deep-hybrid-datacloud.eu/projects/deepaas/en/latest/), Dockerfile, Jenkinsfiles etc):

```bash
$ cookiecutter https://github.com/indigo-dc/cookiecutter-data-science
```

## Access remote storages

You can use 
* [rclone](https://rclone.org) to sync with a remote cloud storage (e.g. [DEEP Nextcloud](https://data-deep.a.incd.pt/)), or 
* [oneclient](https://onedata.org/docs/doc/using_onedata/oneclient.html) to access OneData distributed storage.


## DEEP Documentation

Comprehensive documentation on DEEP tools and components can be found in:

* [DEEP-Hybrid-DataCloud documentation](https://docs.deep-hybrid-datacloud.eu/en/latest/)
    * [Quickstart guide](https://docs.deep-hybrid-datacloud.eu/en/latest/user/quickstart.html)
    * [Overview](https://docs.deep-hybrid-datacloud.eu/en/latest/user/overview/index.html)
    * [HowTo's](https://docs.deep-hybrid-datacloud.eu/en/latest/user/howto/index.html)
* [YouTube channel](https://www.youtube.com/playlist?list=PLJ9x9Zk1O-J_UZfNO2uWp2pFMmbwLvzXa) with tutorials

## DEEP related services
* [DEEP-IAM](https://iam.deep-hybrid-datacloud.eu/login) : DEEP central authentication and authorisation 
* [DEEP Open Catalog](https://marketplace.deep-hybrid-datacloud.eu/) : a curated repository of applications ready to be used or extended
* [Training Dashboard](https://train.deep-hybrid-datacloud.eu/): Dashboard that allows users to interact with the modules hosted at the DEEP Open Catalog, as well as deploying external Docker images hosted in Dockerhub.
* [Nextcloud storage](https://data-deep.a.incd.pt/) :  a sync&share solution to host and share data.

## List of installed tools
DEEP Development Environment uses as a base a Docker Image of either 
* [TensorFlow](https://tensorflow.org) framework (2.10.0 | 2.11.0)
* [PyTorch](https://pytorch.org/) (1.12 | 1.13)
* or Ubuntu 20.04 (Focal)

It leverages 
* [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/index.html) web-based user interface for developing and debugging your code (hint: use **Shift+Right click** to copy/paste);

Includes: 
* [cookiecutter](https://cookiecutter.readthedocs.io/en/latest/) template tool to start or integrate your project with DEEP solutions profiting from [DEEP Data Science template](https://github.com/deephdc/cookiecutter-deep):

Contains DEEP components:
* [DEEP as a Service API](https://docs.deep-hybrid-datacloud.eu/projects/deepaas/en/latest/) is REST API that provids access to machine learning models;
* [flaat](https://github.com/indigo-dc/flaat) : FLAsk support for handling oidc Access Tokens;
* [oidc-agent](https://github.com/indigo-dc/oidc-agent) : a set of tools to manage OpenID Connect tokens and make them easily usable from the command line;

Python related packages:
* python
* python-dev
* pip

And a number of external tools to facilitate the development:
* git
* curl : command line tool for transferring data with URL syntax
* jq : lightweight and flexible command-line JSON processor
* [mc](https://midnight-commander.org/) : Midnight Commander, a visual file manager
* nano : a simple terminal-based text editor
* [oneclient](https://onedata.org/docs/doc/using_onedata/oneclient.html) : a command-line based client for Onedata
* openssh-client
* [rclone](https://rclone.org) : a command line program to sync files and directories to and from cloud storages
* wget : a free utility for non-interactive download of files from the Web

## Acknowledgements

Please consider citing the DEEP Hybrid DataCloud project:

> García, Álvaro López, et al. [A Cloud-Based Framework for Machine Learning Workloads and Applications.](https://ieeexplore.ieee.org/abstract/document/8950411/authors) IEEE Access 8 (2020): 18681-18692. 
