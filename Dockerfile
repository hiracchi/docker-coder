FROM hiracchi/ubuntu-ja:latest

ARG CODER_TAG="3.2.0"
ARG CODER_VERSION="3.2.0"
ARG CODER_PATH=/usr/local/coder
ARG WORKDIR="/work"

# -----------------------------------------------------------------------------
# env
# -----------------------------------------------------------------------------
ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:en" LC_ALL="ja_JP.UTF-8" TZ="Asia/Tokyo"
ENV DEBIAN_FRONTEND=noninteractive
ENV CODER_PATH=${CODER_PATH}

ENV PACKAGES="\
    build-essential gfortran cmake git \
    python3 python3-pip \
    libblas-dev liblapack-dev liblapacke-dev \
    libblacs-mpi-dev libscalapack-openmpi-dev \
    libatlas-base-dev \
    libopenblas-base libopenblas-dev \
    libeigen3-dev \
    ocl-icd-opencl-dev \
    libclc-dev opencl-headers \
    libboost-all-dev libviennacl-dev \
    libhdf5-dev \
    "

# -----------------------------------------------------------------------------
# packages
# -----------------------------------------------------------------------------
RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# install code-server
# -----------------------------------------------------------------------------
RUN set -x && \
    mkdir -p ${CODER_PATH} && \
    wget "https://github.com/cdr/code-server/releases/download/${CODER_TAG}/code-server-${CODER_VERSION}-linux-x86_64.tar.gz" && \
    tar -xzf "code-server-${CODER_VERSION}-linux-x86_64.tar.gz" -C ${CODER_PATH} --strip-components 1 && \
    rm code-server-${CODER_VERSION}-linux-x86_64.tar.gz

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
COPY scripts/* /usr/local/bin/

USER ${USER_NAME}:${GROUP_NAME}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "${CODER_PATH}/code-server", "--auth", "none", "--extensions-dir", "${WORKDIR}/extensions", "--bind-addr", "0.0.0.0:8080"]
