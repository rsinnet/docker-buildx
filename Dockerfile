########## Dockerfile for 'docker buildx' on Alpine Linux. ##########
#                                                                   #
#####################################################################
#      DOCKERISED DOCKER SERVICE WITH BUILDX SUPPORT BUILT ON       #
#                       TOP OF ALPINE LINUX                         #
#-------------------------------------------------------------------#
#               Original built and maintained by                    #
#                       Harsha Vardhan J                            #
#               https://github.com/HarshaVardhanJ                   #
#                                                                   #
#               This fork built and maintained by                   #
#                         Ryan Sinnet                               #
#                  https://github.com/rsinnet                       #
#####################################################################
#                                                                   #
# This Dockerfile does the following:                               #
#                                                                   #
#    1. Imports a pinned version of Alpine Linux.                   #
#    2. Adds the Community repository which contains Docker.        #
#    3. Downloads a specific version of Docker and sets a flag to   #
#       enable experimental features(buildx) in Docker.             #
#    4. Downloads a specific version of the 'buildx' binary from    #
#       GitHub, extracts it, moves it to a directory in $PATH,      #
#       and sets the execute bit on it.                             #
#    5. Sets the 'run as' user as root.                             #
#    6. Copies the 'entrypoint.sh' script to a directory in $PATH.  #
#    7. Runs the 'entrypoint.sh' script, which takes care of        #
#       setting up 'buildx'.                                        #
#                                                                   #
# Note : This file is meant to be on GCP Cloud Build to build       #
#        images with multiple-architecture support. If you wish to  #
#        run the image locally, you will need to bind mount the     #
#        socket on which the Docker daemon listens to the           #
#        container.                                                 #
#                                                                   #
#####################################################################

FROM alpine:3.15
WORKDIR /
ARG BUILDX_VERSION=0.7.0
ARG DOCKER_VERSION=20.10.11-r0
ARG GCR_CRED_VERSION=2.1.0

RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update -U --no-cache && apk add --no-cache curl openssh docker=$DOCKER_VERSION \
    && curl -fSsLo /usr/bin/buildx https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64 \
    && curl -fSsL https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${GCR_CRED_VERSION}/docker-credential-gcr_linux_amd64-${GCR_CRED_VERSION}.tar.gz \
    | tar xzp -C /usr/bin docker-credential-gcr \
    && docker-credential-gcr configure-docker --registries asia-docker.pkg.dev,eu-docker.pkg.dev,us-docker.pkg.dev,gcr.io,asia.gcr.io,eu.gcr.io,us.gcr.io \
    && chmod a+x /usr/bin/buildx \
    && rm -rf /lib/apk/db/scripts.tar \
    && rm -r /var/cache/apk

COPY ./entrypoint.sh /usr/bin/
ENTRYPOINT ["entrypoint.sh"]
ENV DOCKER_BUILDKIT=1 DOCKER_CLI_EXPERIMENTAL=1

LABEL maintainer="Ryan Sinnet" \
    github.account="https://github.com/rsinnet" \
    dockerfile.github.page="https://github.com/rsinnet/docker-buildx/blob/main/Dockerfile" \
    description="This Dockerfile creates an image of Docker with support for \
    `buildx` added. This way, images can be built for multiple architectures. The \
    suggested way to use this image is with GCP Cloud Build via a `cloudbuild.yaml` \
    file in which this image will need to be invoked as a Cloud Builder. The \
    arguments to the Cloud Builder will the same as the argument to the `docker buildx` \
    executable. Start the arguments with 'build -f [DOCKERFILE] [BUILD-CONTEXT]. \
    Check the sample `cloudbuild.yaml` file in this directory for an example of \
    how this image is to be used in a `cloudbuild.yaml` file." \
    version="2.0"

STOPSIGNAL SIGTERM
