# flutter-docker

Base flutter development server

## Disclaimer

I'm just learning Docker, this is a personal test implementation and is used on my daily workflow

The idea is to have a Docker container where I can connect and run any flutter application, without need to install all on my PC

## Default values

- ARG OS_PACKAGES="sudo curl unzip sed bash git openssh-server xz-utils xauth libglvnd0 x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx"
- ARG DEV_USER=dev
- ARG JAVA_VERSION="8"
- ARG ANDROID_VERSION="29"
- ARG FLUTTER_VERSION="2.2.1"
- ARG ANDROID_BUILD_TOOLS_VERSION="29.0.3"
- ARG ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"

## Build with args and replace the values you need

`docker build --build-arg DEV_USER=user1 --build-args ANDROID_VERSION="30" -t [docker-register][/id]/fluttserver .`

## Run or register

`docker run -d --rm --privileged --name fluttserver -v "[code-folder]:/code/apps" -v "/dev/kvm:/dev/kvm" -it [docker-register][/id]/fluttserver`
