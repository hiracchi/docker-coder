FROM ubuntu:18.04

ARG CODER_TAG="2.1698"
ARG CODER_VERSION="2.1698-vsc1.41.1"
ARG CODER_PATH=/usr/local/coder
ARG WORKDIR="/work"

# -----------------------------------------------------------------------------
# env
# -----------------------------------------------------------------------------
ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:en" LC_ALL="ja_JP.UTF-8" TZ="Asia/Tokyo"
ENV DEBIAN_FRONTEND=noninteractive
ENV CODER_PATH=${CODER_PATH}

# -----------------------------------------------------------------------------
# base setup
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# fixuid
# -----------------------------------------------------------------------------
ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV GROUP_NAME=${GROUP_NAME}
ENV USER_NAME=${USER_NAME}

RUN set -x && \
    addgroup --gid ${GROUP_ID} ${GROUP_NAME} && \
    adduser --uid ${USER_ID} --ingroup ${GROUP_NAME} --home /home/${USER_NAME} --shell /bin/sh --disabled-password --gecos "" ${USER_NAME}
RUN set -x && \
     curl -SsL "https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz" | tar -C /usr/local/bin -xzf - && \
     chmod 4755 /usr/local/bin/fixuid && \
     mkdir -p /etc/fixuid && \
     printf "user: ${USER_NAME}\ngroup: ${GROUP_NAME}\n" > /etc/fixuid/config.yml


# -----------------------------------------------------------------------------
# install code-server
# -----------------------------------------------------------------------------
RUN set -x && \
    mkdir -p ${CODER_PATH} && \
    wget "https://github.com/cdr/code-server/releases/download/${CODER_TAG}/code-server${CODER_VERSION}-linux-x86_64.tar.gz" && \
    tar -xzf "code-server${CODER_VERSION}-linux-x86_64.tar.gz" -C ${CODER_PATH} --strip-components 1 && \
    rm code-server${CODER_VERSION}-linux-x86_64.tar.gz

# RUN set -x && \
#     mkdir -p ${CODER_PATH}/extensions && \
#     chown -R root:${GROUP_NAME} ${CODER_PATH}/extensions && \
#     chmod 774 ${CODER_PATH}/extensions

# RUN set -x && \
#     ${CODER_PATH}/code-server --extensions-dir ${CODER_PATH}/extensions --install-extension ms-vscode.cmake-tools
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


# -----------------------------------------------------------------------------
# workdir
# -----------------------------------------------------------------------------
RUN set -x && \
    mkdir -p ${WORKDIR}
ENV WORKDIR=${WORKDIR}
WORKDIR ${WORKDIR}


# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin

USER ${USER_NAME}:${GROUP_NAME}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "${CODER_PATH}/code-server", "--auth", "none", "--extensions-dir", "${WORKDIR}/extensions", "--port", "8443"]
