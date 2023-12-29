###############################################

FROM ubuntu:20.04

COPY ./sources.list /etc/apt


# Set locale.
RUN apt-get update -y && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install common libraries.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
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

# Set up non-interactive for software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata && apt install -y -qq software-properties-common
# Install tools for installers.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    gpg-agent \
    curl \
    g++ \
    ninja-build \
    unzip \
    wget \
    zip \
    python3.8-dev \
    libopencv-dev \
 && rm -rf /var/lib/apt/lists/*


# Install cmake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' && \
    apt-get update -y && apt-get install -y --no-install-recommends cmake

# Install coding utils for installers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    zsh  \
    exuberant-ctags \
    libncurses5-dev \
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

COPY install.sh /work/zsh/

RUN sudo chsh -s $(which zsh) && \
    sh /work/zsh/install.sh

RUN cd && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .

COPY vim-8.2.3434.tar.gz /work/

RUN mkdir -p /work && cd /work/ && tar -xzvf vim-8.2.3434.tar.gz && cd /work/vim && \
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
    CC=gcc-8 CXX=g++-8 ./install.py --clangd-completer --force-sudo

RUN sudo apt-get update -y && \
    sudo apt-get install -y --no-install-recommends xclip tmux tree iputils-ping \
        nodejs npm \
        python3-venv \
        ripgrep

RUN sudo apt-get update -y && \
    sudo apt-get install -y --no-install-recommends python3-pip python-numpy \
        libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev \
        libeigen3-dev libgoogle-glog-dev libfmt-dev libgtest-dev libboost-dev \
        libssl-dev less


COPY yaml-cpp.tar.gz /work/
COPY glog.tar.gz /work/

RUN cd /work/ && tar -xzvf yaml-cpp.tar.gz && cd /work/yaml-cpp/ && \
    mkdir -p build && cd build && cmake -DBUILD_SHARED_LIBS=ON .. && make -j4 && make install


RUN cd /work/ && tar -xzvf glog.tar.gz && cd /work/glog/ && \
    mkdir -p build && cd build && \
    cmake -S .. -B build -G "Unix Makefiles" && \
    cmake --build build --target install

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN zsh -c "source ~/.zshrc && nvm install 18"

# Install cmake
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 15 all
RUN apt-get purge -y libunwind-15 

# Install ceres
RUN apt-get update && apt-get install -y --no-install-recommends libceres-dev

# Install Sophus
COPY Sophus-1.0.0.tar.gz /work/
RUN cd /work/ && tar -xzvf Sophus-1.0.0.tar.gz && cd /work/Sophus-1.0.0/ && \
    mkdir -p build && cd build && \
    cmake .. && make -j13 && make install 

# Install neo-vim
COPY nvim.appimage /work/

# Install npm releated packages
RUN npm install -g commitizen --registry https://registry.npm.taobao.org/
RUN npm install -g cz-customizable --registry https://registry.npm.taobao.org/
RUN npm install -g @commitlint/config-conventional @commitlint/cli --registry https://registry.npm.taobao.org/

