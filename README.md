# molecule_test_mysql_replication

# Table of contents
<!--ts-->
* [molecule_test_mysql_replication](#molecule_test_mysql_replication)
* [Table of contents](#table-of-contents)
* [Disclaimer](#disclaimer)
* [Description](#description)
* [Mysql root password](#mysql-root-password)
* [Requirements](#requirements)
* [Automated build](#automated-build)
* [Building the image](#building-the-image)
   * [Build arguments (aka --build-arg)](#build-arguments-aka---build-arg)
   * [Example build commands](#example-build-commands)
* [Running a container](#running-a-container)
* [Contributing](#contributing)
   * [Dependencies](#dependencies)
   * [Installing the git hooks](#installing-the-git-hooks)
<!--te-->

# Disclaimer
**TL;DR: /!\ Do not run this image on production /!\ (you've been warned)**

This image has systemd enabled (requiring a few [specific volumes](#launching-a-container))
and contains a mysql server with a [dummy root password](#mysql-root-password). As such
it is only intended for automated tests (with original focus on ansible molecule tests) and
**must not be run on production environments (you've been warned twice)**.

# Description
A systemd enabled ubuntu image with mysql installed to test ansible role/collection
for replication/switching using molecule

# Mysql root password
The password set for root mysql user at install time is `test`. This can be overidden
building the image locally by passing `--build-arg MYSQL_ROOT_PASSWORD=mypassword`
to the `docker build` command

See [building the image](#building-the-image)

# Requirements
* A functional and fairly recent docker engine
* Buildkit enabled for docker builds

# Automated build
This image can be built on dockerhub and will take advantage of the [dockerhub build hook](/hooks/build)
to adapt the image content based on the target tag (5 or 8)

# Building the image
## Build arguments (aka `--build-arg`)

| Variable                 | Default                    | Desription                                                                                 |
|--------------------------|:---------------------------|:-------------------------------------------------------------------------------------------|
| MYSQL_ROOT_PASSWORD      | test                       | Initial mysql root password for the installed db server                                    |
| mysql_version            | 8                          | Mysql version to install. Allowed values: 5 -> latest 5.7 version, 8 -> latest 8.0 version |
| mysql_apt_config_version | 0.8.12-1_all               | Version of the `mysql-apt-config` package to install                                       |
| download_dir             | /tmp                       | Path to the internal image directoy where to download `mysql-apt-config` package           |
| download_base_url        | https://dev.mysql.com/get/ | Base url where to download the `mysql-apt-config` package                                                            |

## Example build commands
```bash
export DOCKER_BUILDKIT=1
export mysql_version=5
docker build --build-arg mysql_version="${mysql_version}" -t "my_local_img:${mysql_version}" .
```

# Running a container

This image has systemd enabled and requires running in privileged mode with a number of default mounts

Example run command:
```bash
export mysql_version=8
docker run -d --name "test_molecule_mysql${mysql_version}" --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro
  --tmpfs /tmp --tmpfs /run --tmpfs /run/lock
  "my_local_img:${mysql_version}"
```

# Contributing
If you intend to contribute to this git repository, make sure you install the distributed
local hooks for git and the required dependencies. At time of this writting there is a single
`pre-commit` hook which will run basic checks and update the README.md toc if needed

## Dependencies
* [github markdonw toc](https://github.com/ekalinin/github-markdown-toc). This is used to automatically
  generate the `README.md` table of content whenever its content is changed.

## Installing the git hooks
right after cloning the repo, run
```bash
git config core.hooksPath .githooks
```
