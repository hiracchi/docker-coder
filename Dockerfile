FROM ubuntu:18.04

ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:en" LC_ALL="ja_JP.UTF-8" TZ="Asia/Tokyo"
ENV DEBIAN_FRONTEND=noninteractive

ARG CODER_VERSION="2.1692-vsc1.39.2-linux-x86_64"
ARG CODER_PATH=/usr/local/coder
ARG WORKDIR="/work"

RUN set -x && \
    apt-get update && \
    apt-get install -y \
    apt-utils sudo wget gnupg locales tzdata wget curl && \
    locale-gen ja_JP.UTF-8 && \
    update-locale LANG=ja_JP.UTF-8 && \
    apt-get install -y tzdata && \
    echo "${TZ}" > /etc/timezone && \
    mv /etc/localtime /etc/localtime.orig && \
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# RUN set -x && \
#     apt-get update && \
#     apt-get install -y \
#     vim build-essential gfortran \
#     pkg-config ca-certificates \
#     git automake autoconf libtool cmake \
#     libopenblas-base libopenblas-dev \
#     libscalapack-openmpi-dev \
#     openmpi-bin openmpi-common \
#     \
#     libeigen3-dev \
#     \
#     opencl-headers libclc-dev mesa-opencl-icd clinfo \
#     \
#     libboost-all-dev \
#     hdf5-tools \
#     libhdf5-dev \
#     libhdf5-openmpi-dev \
#     \
#     python3-dev python3-pip python3-setuptools python3-pip python3-wheel \
#     python3-numpy python3-scipy python3-scipy python3-pandas \
#     python3-xlrd \
#     python3-yaml python3-msgpack \
#     python3-tqdm \
#     python3-requests python3-jinja2 python3-bs4 \
#     python3-matplotlib \
#     python3-sklearn \
#     python3-h5py \
#     pylint3 \
#     && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# install
RUN set -x && \
    mkdir -p ${CODER_PATH} && \
    wget "https://github.com/cdr/code-server/releases/download/2.1692-vsc1.39.2/code-server${CODER_VERSION}.tar.gz" && \
    tar -xzf "code-server${CODER_VERSION}.tar.gz" -C ${CODER_PATH} --strip-components 1


# workdir
RUN set -x && \
    mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

# WORKDIR /works/app
#
# RUN set -x && \
#     ${WORKDIR}/code-server --install-extension ms-vscode.cmake-tools && \
#     ${WORKDIR}/code-server --install-extension cschlosser.doxdocgen && \
#     ${WORKDIR}/code-server --install-extension manuth.markdown-converter && \
#     ${WORKDIR}/code-server --install-extension davidanson.vscode-markdownlint && \
#     \
#     ${WORKDIR}/code-server --install-extension ms-vscode.cpptools && \
#     ${WORKDIR}/code-server --install-extension mitaki28.vscode-clang && \
#     ${WORKDIR}/code-server --install-extension xaver.clang-format && \
#     \
#     ${WORKDIR}/code-server --install-extension ms-python.python
#
# RUN set -x && \
#     ${WORKDIR}/code-server --install-extension mhutchie.git-graph
#
# #    ${WORKDIR}/code-server --install-extension MS-CEINTL.vscode-language-pack-ja &&
# #    ${WORKDIR}/code-server --install-extension editorconfig.editorconfig &&
# #    ${WORKDIR}/code-server --install-extension mhutchie.git-graph &&
# #    ${WORKDIR}/code-server --install-extension austin.code-gnu-global && \
# #    ${WORKDIR}/code-server --install-extension tht13.python

# fixuid
ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV GROUP_NAME=${GROUP_NAME}
ENV USER_NAME=${USER_NAME}
#
# RUN set -x && \
#     addgroup --gid ${GROUP_ID} ${GROUP_NAME} && \
#     adduser --uid ${USER_ID} --ingroup ${GROUP_NAME} --home /home/${USER_NAME} --shell /bin/sh --disabled-password --gecos "" ${USER_NAME}
# RUN set -x && \
#     curl -SsL "https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz" | tar -C /usr/local/bin -xzf - && \
#     chmod 4755 /usr/local/bin/fixuid && \
#     mkdir -p /etc/fixuid && \
#     printf "user: ${USERNAME}\ngroup: ${GROUPNAME}\n" > /etc/fixuid/config.yml
#
# USER ${USERNAME}:${GROUPNAME}
#
# ENTRYPOINT ["fixuid"]


# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
RUN set -x \
  && mkdir -p /etc/sudoers.d/ \
  && echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ALL \
  && chmod u+s /usr/sbin/useradd \
  && chmod u+s /usr/sbin/groupadd
COPY docker-entrypoint.sh /usr/local/bin

# ENV CODER_PATH=${CODER_PATH}
WORKDIR ${WORKDIR}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "/usr/local/coder/code-server", "--auth", "none", "--port", "8443", "/work"]
