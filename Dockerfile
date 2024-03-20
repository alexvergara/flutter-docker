# Author: Alex Vergara
# Description: This file contains the Dockerfile for the flutter image
# Version: 1.0


# Use the official image as a parent image // TODO: Check for a smaller image?
FROM ubuntu:22.04

# Set default parameters
ARG OS_PACKAGES="sudo curl unzip sed bash git openssh-server xz-utils xauth libglvnd0 x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx libxdamage-dev cmake"

ARG DEV_USER=dev

# -- This are old versions, used for old applications, build the image with arguments to use newer versions
ARG JAVA_VERSION="18"
# Android 14
ARG ANDROID_VERSION="34"
ARG ANDROID_BUILD_TOOLS_VERSION="34.0.0"
ARG ANDROID_ARCHITECTURE="x86_64"
ARG FLUTTER_VERSION="3.16.5"
#ARG DART_VERSION="3.0.6"
# 6858069 7302050 8092744 8512546 10572941
ARG ANDROID_SDK_TOOLS_VERSION="10572941"

ENV ANDROID_SDK_ROOT="/home/${DEV_USER}/android"
ENV CHANNEL="stable"
# The URL could change, check the latest version in the flutter website... // TODO: Use argument instead?
#ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra/releases/${CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${CHANNEL}.tar.xz"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/${CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${CHANNEL}.tar.xz"
#ENV DART_URL="https://storage.googleapis.com/dart-archive/channels/${CHANNEL}/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip"
ENV CMDLINE_TOOS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip"
ENV FLUTTER_HOME="/home/${DEV_USER}/flutter"
ENV FLUTTER_ROOT="${FLUTTER_HOME}"
ENV FLUTTER_WEB_PORT="8090"
ENV FLUTTER_DEBUG_PORT="42000"
ENV FLUTTER_EMULATOR_NAME="flutter_emulator"
#ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/platforms:${FLUTTER_HOME}/bin:"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/platforms:${FLUTTER_HOME}/bin:"


# Avoid user interaction
ARG DEBIAN_FRONTEND=noninteractive

# Update the image
RUN apt-get update
#RUN apt-get install python-software-properties \
#  && add-apt-repository ppa:webupd8team/java \
#  && apt-get update

# Install required packages
RUN apt-get install -y --no-install-recommends openjdk-${JAVA_VERSION}-jdk ${OS_PACKAGES} \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

# User -----------------------------------------

# Create dev_user and group, set password as ${DEV_USER}
RUN groupadd -g 1000 ${DEV_USER}
RUN useradd -u 1000 -g ${DEV_USER} -m ${DEV_USER} -s /usr/bin/bash && echo "${DEV_USER}:${DEV_USER}" | chpasswd && adduser ${DEV_USER} sudo
# Create and enable KVM for emulator
RUN groupadd -r kvm
RUN gpasswd -a ${DEV_USER} kvm && adduser ${DEV_USER} kvm


RUN echo 'export PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/platforms:${FLUTTER_HOME}/bin"' >> /home/${DEV_USER}/.bashrc

RUN cat <<EOT >> /home/${DEV_USER}/.bashrc

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\e[91m\]\$(parse_git_branch)\[\e[00m\] $PS1"

EOT

# Working directory
RUN mkdir -p /code/apps

# Change the working directory permissions to dev_user
RUN chown -R ${DEV_USER}:${DEV_USER} /code


# Switch to the dev user to run next commands and login shell
USER "${DEV_USER}"

# Set the working directory
WORKDIR /code/apps


# Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT} \
  && mkdir -p /home/${DEV_USER}/.android \
  && touch /home/${DEV_USER}/.android/repositories.cfg \
  && curl -o android_tools.zip "${CMDLINE_TOOS_URL}"
RUN unzip -qq -d "${ANDROID_SDK_ROOT}" android_tools.zip \
  && rm android_tools.zip \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools ${ANDROID_SDK_ROOT}/latest \
  && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && mv ${ANDROID_SDK_ROOT}/latest ${ANDROID_SDK_ROOT}/cmdline-tools \
  && yes "y" | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
  && yes "y" | sdkmanager "platforms;android-${ANDROID_VERSION}" \
  && yes "y" | sdkmanager "platform-tools"
RUN yes "y" | sdkmanager "emulator"
RUN yes "y" | sdkmanager "system-images;android-${ANDROID_VERSION};google_apis_playstore;${ANDROID_ARCHITECTURE}"


# Flutter
RUN mkdir -p ${FLUTTER_HOME} \
  && curl -o flutter.tar.xz ${FLUTTER_URL}
RUN tar xf flutter.tar.xz -C /home/${DEV_USER} \
  && rm flutter.tar.xz \
  && flutter config --no-analytics --android-sdk ${ANDROID_SDK_ROOT} \
  && flutter precache \
  && yes "y" | flutter doctor --android-licenses \
  && flutter doctor
RUN flutter emulators --create \
  && flutter update-packages

#RUN echo "Vulkan = on" >> /home/${DEV_USER}/.android/advancedFeatures.ini
#RUN echo "GLDirectMem = on" >> /home/${DEV_USER}/.android/advancedFeatures.ini

EXPOSE 5037 5900 9100

# // TODO:: Add other packages

