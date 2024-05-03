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


RUN apt-get update && apt-get -y install sudo

# Install coding utils for installers.
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    cmake \
    tmux \
    zsh  \
    exuberant-ctags \
    libncurses5-dev \
    python3-dev \
 && sudo rm -rf /var/lib/apt/lists/*

RUN cd && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends g++-8

# for the GLIBCXX_3.4.26
RUN sudo apt-get clean && sudo apt-get update && sudo add-apt-repository ppa:ubuntu-toolchain-r/test && sudo apt-get update -y && \
    sudo apt-get install -y --only-upgrade libstdc++6

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


RUN sudo apt-get update -y && \
    sudo apt-get install -y --no-install-recommends libgflags-dev protobuf-compiler libprotobuf-dev

# Install yaml-cpp and glog
COPY yaml-cpp.tar.gz /work/
COPY glog.tar.gz /work/
RUN cd /work/ && tar -xzvf yaml-cpp.tar.gz && cd /work/yaml-cpp/ && \
    mkdir -p build && cd build && cmake -DBUILD_SHARED_LIBS=ON .. && make -j4 && sudo make install
RUN cd /work/ && tar -xzvf glog.tar.gz && cd /work/glog/ && \
    mkdir -p build && cd build && \
    cmake -S .. -B build -G "Unix Makefiles" && \
    sudo cmake --build build --target install

# Install and setup nvm
RUN sudo npm install -g npm-install-peers
RUN sudo npm install -g typescript
RUN sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN echo $HOME
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install 18

# Install npm releated packages
RUN sudo npm cache clean -f
RUN sudo npm install -g commitizen --registry https://mirrors.huaweicloud.com/repository/npm/
RUN sudo npm install -g cz-customizable --registry https://mirrors.huaweicloud.com/repository/npm/
RUN sudo npm install -g @commitlint/config-conventional @commitlint/cli --registry https://mirrors.huaweicloud.com/repository/npm/

# Install cmake
RUN sudo wget https://apt.llvm.org/llvm.sh && sudo chmod +x llvm.sh && sudo ./llvm.sh 15 all
RUN sudo apt-get purge -y libunwind-15 

# Install ceres
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libceres-dev

# Install Sophus
COPY Sophus-1.0.0.tar.gz /work/
RUN cd /work/ && tar -xzvf Sophus-1.0.0.tar.gz && cd /work/Sophus-1.0.0/ && \
    mkdir -p build && cd build && \
    cmake .. && make -j13 && sudo make install 

# Install neo-vim
COPY nvim.appimage /work/

# Install cilantro, recorder dependencies
COPY cilantro-master.zip /work/
RUN cd /work/ && unzip cilantro-master.zip && cd /work/cilantro-master/ && \
    mkdir -p build && cd build && \
    cmake .. && make -j13 && sudo make install

