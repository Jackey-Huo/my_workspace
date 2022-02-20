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
    git \
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
    gpg-agent \
    curl=7.58.0* \
    g++=4:7.4.0* \
    ninja-build=1.8.2* \
    software-properties-common=0.96.24* \
    unzip=6.0* \
    wget=1.19.4* \
    zip=3.0* \
    python-minimal \
    python3.6-dev \
 && rm -rf /var/lib/apt/lists/*


# Install cmake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    apt-get update -y && apt-get install -y --no-install-recommends cmake

# Install coding utils for installers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    zsh  \
    exuberant-ctags \
    libncurses5-dev \
    python3-dev \
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

RUN sudo chsh -s $(which zsh) && \
    sh /work/zsh/install.sh

RUN cd && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .


COPY spf13-vim.sh /home/$DOCKER_USER/spf13-vim/

RUN sh /home/$DOCKER_USER/spf13-vim/spf13-vim.sh

RUN cd /root && ln -s -f .spf13-vim-3/.vimrc.before.local && \
    ln -s -f .spf13-vim-3/.vimrc.local && \
    vim +BundleInstall! +y +q +q && \
    ln -s -f /root/.spf13-vim-3/cpp_header_template. /root/.vim/


RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends g++-8

# for the GLIBCXX_3.4.26
RUN sudo apt-get clean && sudo apt-get update && sudo add-apt-repository ppa:ubuntu-toolchain-r/test && sudo apt-get update -y && \
    sudo apt-get install -y --only-upgrade libstdc++6

RUN cd /root/.vim/bundle/YouCompleteMe/ && \
    CC=gcc-8 CXX=g++-8 ./install.py --clangd-completer

RUN sudo apt-get update -y && \
    sudo apt-get install -y --no-install-recommends xclip tmux tree iputils-ping

RUN sudo apt-get update -y && \
    sudo apt-get install -y --no-install-recommends python-pip python-numpy \
        libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

# for bazel 4.1.0
COPY _bazel /root/.oh-my-zsh/cache/completions/_bazel
RUN cd /usr/bin && sudo ln -s -f /root/My_Project/dreame/bazel-4.1.0-linux-arm64 bazel
