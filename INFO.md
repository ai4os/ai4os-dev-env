<div align="center">
<img src="https://ai4eosc.eu/wp-content/uploads/sites/10/2022/09/horizontal-transparent.png" alt="logo" width="300"/>
</div>

# Welcome to AI4OS Developement Environment

## Table of Content

* [Introduction](#Introduction)
* [Configure git for commits](#Configure-git-for-commits)
* [Start your project with AI4OS Data Science template](#Start-your-project-with-AI4OS-Data-Science-template)
* [Access remote storages](#Access-remote-storages)
* [AI4OS Documentation](#AI4OS-Documentation)
* [AI4OS related services](#AI4OS-related-services)
* [List of installed tools](#List-of-installed-tools)
* [Acknowledgments](#Acknowledgments)

## Introduction

AI4OS Development Environment (AI4Dev) aims to facilitate the integration of your code with AI4OS software solutions, development, and testing it directly in the cloud environment. Please, see the [List of installed tools](#List-of-installed-tools) and [AI4OS Documentation](#AI4OS-Documentation) for more details.

## Configure git for commits

Using pre-installed `git` you can easily clone projects in AI4Dev. If you want to commit your changes back, you have to configure global `user.name` and `user.email` as follows: 

```bash
$ git config --global user.name "Your Name"
$ git config --global user.email "your_email_for_git_account@domain.zone"
```

## Start your project with AI4OS Data Science template

Create your new project using our [AI4OS templates](https://github.com/deephdc/cookiecutter-deep) for easier integration with AI4OS components ([DEEPaaS API](https://docs.deep-hybrid-datacloud.eu/projects/deepaas/en/latest/), Dockerfile, Jenkinsfiles etc). You can use either:

* Our web-interface: [https://templates.cloud.ai4eosc.eu/](https://templates.cloud.ai4eosc.eu/)

OR

* external command-line tool [cookiecutter](https://pypi.org/project/cookiecutter/):

```bash
$ cookiecutter https://github.com/deephdc/cookiecutter-deep
```

## Access remote storages

You can use 
* [rclone](https://rclone.org) to sync with a remote cloud storage (e.g. [AI4OS Nextcloud](https://data-deep.a.incd.pt/)), or 
* [oneclient](https://onedata.org/docs/doc/using_onedata/oneclient.html) to access OneData distributed storage.


## AI4OS Documentation

Comprehensive documentation on AI4OS tools and components can be found in:

* [AI4OS documentation](https://docs.ai4eosc.eu/)
    * [Quickstart guide](https://docs.ai4eosc.eu/en/latest/user/quickstart.html)
    * [Overview](https://docs.ai4eosc.eu/en/latest/user/index.html#overview)
    * [HowTo's](https://docs.ai4eosc.eu/en/latest/user/index.html#how-to-s)
* [YouTube channel](https://www.youtube.com/playlist?list=PLJ9x9Zk1O-J_UZfNO2uWp2pFMmbwLvzXa) with tutorials

## AI4OS related services
* [AI4OS AAI](https://aai.egi.eu/registry/co_petitions/start/coef:550) : Join our Virtual Organisation (VO) in order to access the services
* [AI4OS Open Catalog and the Dashboard](https://dashboard.cloud.ai4eosc.eu/) : a curated repository of applications ready to be used or extended. Logged-in users can deploy modules directly on the platform.
* [Nextcloud storage](https://data-deep.a.incd.pt/) :  a sync&share solution to host and share data.

## List of installed tools
AI4OS Development Environment uses as a base a Docker Image of either 
* [TensorFlow](https://tensorflow.org) framework (2.10.0 | 2.11.0)
* [PyTorch](https://pytorch.org/) (1.12 | 1.13)
* or Ubuntu 20.04 (Focal)

It leverages 
* [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/index.html) web-based user interface for developing and debugging your code (hint: use **Shift+Right click** to copy/paste);
* [VS Code in the browser](https://coder.com/docs/code-server/latest) VS Code that runs in the browser, see [code-server](https://github.com/coder/code-server)

Includes: 
* [cookiecutter](https://cookiecutter.readthedocs.io/en/latest/) template tool to start or integrate your project with AI4OS solutions profiting from [AI4OS Data Science template](https://github.com/deephdc/cookiecutter-deep):

Contains AI4OS components:
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

This work is co-funded by [AI4EOSC](https://ai4eosc.eu/) project that has received funding from the European Union's Horizon Europe 2022 research and innovation programme under agreement No 101058593

This work is co-funded by [DEEP Hybrid-DataCloud](https://deep-hybrid-datacloud.eu/) project that has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 777435.
Please consider citing the DEEP Hybrid DataCloud project:

> García, Álvaro López, et al. [A Cloud-Based Framework for Machine Learning Workloads and Applications.](https://ieeexplore.ieee.org/abstract/document/8950411/authors) IEEE Access 8 (2020): 18681-18692. 

