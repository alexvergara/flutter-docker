# flutter-docker

Base flutter development server

## Disclaimer

I'm just learning Docker, this is a personal test implementation and is used on my daily workflow

The idea is to have a Docker container where I can connect and run any flutter application, without need to install all on my PC

## Default values

- ARG OS_PACKAGES="sudo curl unzip sed bash git openssh-server xz-utils xauth libglvnd0 x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx libxdamage-dev cmake"
- ARG DEV_USER=dev
- ARG JAVA_VERSION="18"
- ARG ANDROID_VERSION="34"
- ARG FLUTTER_VERSION="3.16.5"
- ARG ANDROID_SDK_TOOLS_VERSION="10572941"
- ARG ANDROID_BUILD_TOOLS_VERSION="34.0.0"
- ARG GRADLE_VERSION="7.6.3"

## Build with args and replace the values you need

`docker build --build-arg DEV_USER=user1 --build-args ANDROID_VERSION="30" -t [docker-register][/id]/fluttserver .`

## Run or register

`docker run -d --rm --privileged --name fluttserver -v "[code-folder]:/code/apps" -v "/dev/kvm:/dev/kvm" -it [docker-register][/id]/fluttserver`
