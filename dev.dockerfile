###############################################

FROM ubuntu:18.04

# Set locale.
RUN apt-get update -y && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install common libraries.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential=12.4* \
    curlftpfs \
    gdb \
    git=1:2.17.1* \
    lcov \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    locate \
    lsof \
    net-tools \
    mesa-utils=8.4.0* \
    nfs-common \
    pkg-config=0.29.1* \
    sshfs \
    subversion \
    sudo \
    file \
 && rm -rf /var/lib/apt/lists/*


# Install tools for installers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake=3.10.2* \
    curl=7.58.0* \
    g++=4:7.4.0* \
    ninja-build=1.8.2* \
    software-properties-common=0.96.24* \
    unzip=6.0* \
    wget=1.19.4* \
    zip=3.0* \
    python-minimal \
 && rm -rf /var/lib/apt/lists/*


# Install coding utils for installers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    zsh  \
    exuberant-ctags \
    libncurses5-dev \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /work && cd /work/ && git clone https://github.com/vim/vim.git && cd /work/vim && \
    git checkout v8.2.3434 && \
    ./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local && \
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim82 && \
    make install

COPY install.sh /work/zsh/

RUN chsh -s $(which zsh) && \
    sh /work/zsh/install.sh

RUN cd /work && git clone https://github.com/gpakosz/.tmux.git && cd /root && \
    ln -s -f /work/.tmux/.tmux.conf && cp /work/.tmux/.tmux.conf.local .

