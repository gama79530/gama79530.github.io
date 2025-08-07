FROM ubuntu:22.04

ARG USERNAME=test
ARG USER_UID=1000
ARG USER_GID=1000

# Prevent interactive operations
ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
&&  apt-get install -y git locales \
&&  apt-get install -y python3 python3-setuptools python3-pip python3-distutils python3-venv \
&&  apt-get install -y build-essential \
&&  rm -rf /var/lib/apt/lists/* 

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt \
&&  rm /tmp/requirements.txt


# Set locale settings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Create the user
RUN mkdir -p /etc/sudoers.d \
&&  groupadd --gid $USER_GID $USERNAME \
&&  useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
&&  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
&&  chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

RUN printf '%s\n' \
  'if [ -f /usr/share/bash-completion/completions/git ]; then' \
  '  . /usr/share/bash-completion/completions/git' \
  'fi' >> ~/.bashrc