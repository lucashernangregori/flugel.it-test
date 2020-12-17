# Trimmed down version of:
# https://github.com/github/super-linter/blob/master/Dockerfile

#########################################
# Get dependency images as build stages #
#########################################
FROM golangci/golangci-lint:v1.33.0 as golangci-lint
FROM wata727/tflint:0.21.0 as tflint
FROM alpine/terragrunt:0.14.0 as terragrunt
FROM accurics/terrascan:2d1374b as terrascan

##################
# Get base image #
##################
FROM python:3.6-alpine

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    bash \
    coreutils \
    curl \
    file \
    gcc \
    git git-lfs\
    go \
    gnupg \
    icu-libs \
    jq \
    krb5-libs \
    libc-dev libcurl libffi-dev libgcc \
    libintl libssl1.1 libstdc++ \
    libxml2-dev libxml2-utils \
    linux-headers \
    lttng-ust-dev \
    make \
    musl-dev \
    npm nodejs-current \
    py3-setuptools python3-dev\
    readline-dev \
    ruby ruby-dev ruby-bundler ruby-rdoc \
    zlib zlib-dev

########################################
# Copy dependencies files to container #
########################################
COPY dependencies/* /

################################
# Installs python dependencies #
################################
RUN pip3 install --no-cache-dir pipenv
# Bug in hadolint thinks pipenv is pip
# hadolint ignore=DL3042
#RUN pipenv install --clear --system

####################
# Run NPM Installs #
####################
RUN npm config set package-lock false \
    && npm config set loglevel error \
    && npm --no-cache install

#############################
# Add node packages to path #
#############################
ENV PATH="/node_modules/.bin:${PATH}"

##############################
# Installs ruby dependencies #
##############################
RUN bundle install

#####################
# Install Go Linter #
#####################
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/bin/

##################
# Install TFLint #
##################
COPY --from=tflint /usr/local/bin/tflint /usr/bin/

##################
# Install Terrascan #
##################
COPY --from=terrascan /go/bin/terrascan /usr/bin/
RUN terrascan init

######################
# Install Terragrunt #
######################
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/bin/

################################
# Create and install Bash-Exec #
################################
RUN printf '#!/bin/bash \n\nif [[ -x "$1" ]]; then exit 0; else echo "Error: File:[$1] is not executable"; exit 1; fi' > /usr/bin/bash-exec \
    && chmod +x /usr/bin/bash-exec

#############################
# Copy scripts to container #
#############################
COPY lib /action/lib

##################################
# Copy linter rules to container #
##################################
COPY TEMPLATES /action/lib/.automation

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/linter.sh"]