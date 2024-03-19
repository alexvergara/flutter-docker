# Author: Alex Vergara
# Description: This file contains the Dockerfile for the flutter image
# Version: 1.0


# Use the official image as a parent image // TODO: Check for a smaller image?
FROM ubuntu:22.04

# Set default parameters
ARG OS_PACKAGES="sudo curl unzip sed bash git openssh-server xz-utils xauth libglvnd0 x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx"

ARG DEV_USER=dev

# -- This are old versions, used for old applications, build the image with arguments to use newer versions
ARG JAVA_VERSION="8"
# Android 10
ARG ANDROID_VERSION="29"
ARG ANDROID_BUILD_TOOLS_VERSION="29.0.3"
ARG ANDROID_ARCHITECTURE="x86_64"
ARG FLUTTER_VERSION="2.2.1"
ARG ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"

ENV ANDROID_SDK_ROOT="/home/${DEV_USER}/android"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
ENV FLUTTER_HOME="/home/${DEV_USER}/flutter"
ENV FLUTTER_WEB_PORT="8090"
ENV FLUTTER_DEBUG_PORT="42000"
ENV FLUTTER_EMULATOR_NAME="flutter_emulator"
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/platforms:${FLUTTER_HOME}/bin:${PATH}"


# Avoid user interaction
ARG DEBIAN_FRONTEND=noninteractive

# Update the image
RUN apt-get update

# Install required packages
RUN apt-get install -y --no-install-recommends openjdk-${JAVA_VERSION}-jdk ${OS_PACKAGES} \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

# User -----------------------------------------

# Create dev_user and group, set password as ${DEV_USER}
RUN groupadd -g 1000 ${DEV_USER}
RUN useradd -u 1000 -g ${DEV_USER} -m ${DEV_USER} -s /usr/bin/bash && echo "${DEV_USER}:${DEV_USER}" | chpasswd && adduser ${DEV_USER} sudo


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
  && curl -o android_tools.zip ${ANDROID_TOOLS_URL} \
  && unzip -qq -d "${ANDROID_SDK_ROOT}" android_tools.zip \
  && rm android_tools.zip \
  && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/bin ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/lib ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
  && yes "y" | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
  && yes "y" | sdkmanager "platforms;android-${ANDROID_VERSION}" \
  && yes "y" | sdkmanager "platform-tools" \
  && yes "y" | sdkmanager "emulator" \
  && yes "y" | sdkmanager "system-images;android-${ANDROID_VERSION};google_apis_playstore;${ANDROID_ARCHITECTURE}"

# Flutter
RUN curl -o flutter.tar.xz ${FLUTTER_URL} \
  && mkdir -p ${FLUTTER_HOME} \
  && tar xf flutter.tar.xz -C /home/${DEV_USER} \
  && rm flutter.tar.xz \
  && flutter config --no-analytics \
  && flutter precache \
  && yes "y" | flutter doctor --android-licenses \
  && flutter doctor \
  && flutter emulators --create \
  && flutter update-packages


# // TODO:: Add other packages

