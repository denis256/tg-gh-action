FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    unzip \
    wget \
    awscli \
    && rm -rf /var/lib/apt/lists/*

ARG TF_ENV_VERSION=master
ARG TG_ENV_VERSION=master

# clone tfenv
RUN git clone --depth=1 --branch $TF_ENV_VERSION https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile

# clone tgenv
RUN git clone  --depth=1 --branch $TG_ENV_VERSION https://github.com/cunymatthieu/tgenv.git ~/.tgenv
RUN echo 'export PATH="$HOME/.tgenv/bin:$PATH"' >> ~/.bash_profile

ENV PATH="/root/.tfenv/bin:/root/.tgenv/bin:${PATH}"

ENV TF_INPUT=0
ENV TF_IN_AUTOMATION=1

COPY ["src", "/src/"]

ENTRYPOINT ["/src/main.sh"]