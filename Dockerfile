FROM ubuntu:16.04

RUN \
  apt-get update && \
  apt-get install -y git man gcc vim-nox cscope exuberant-ctags silversearcher-ag \
                    screen wget curl libcurl4-openssl-dev xz-utils ncdu pax-utils \
                    pkg-config zlib1g-dev python unzip zip g++ bash-completion \
                    make bison flex &&\
  rm -rf /var/lib/apt/lists/* &&\
  apt-get clean -yq


# donwload java 8 directly and extract
RUN wget -qO-  --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz|tar xvz
ENV JAVA_HOME /jdk1.8.0_45
ENV PATH $JAVA_HOME/bin:$PATH

# 1. git clone the vim setting
# 2. git clone the env setting
RUN \
  rm -fr ~/.vim ~/.vimrc &&\
  cd ~ && git clone https://github.com/chin33z/dotvim.git ~/.vim &&\
  ln -s ~/.vim/vimrc ~/.vimrc &&\
  cd ~ && git clone https://github.com/chin33z/dotfiles.git ~/dotfiles &&\
  cd dotfiles && ./link.sh

ENV HOME /root
WORKDIR /root

RUN apt-get update \
    && apt-get install -y apt-utils
RUN apt-get install -y autoconf automake libtool curl make unzip wget git

RUN apt-get install -y ant ivy

RUN apt-get install -y liblog4cxx10v5 libjansson-dev libcppunit-dev
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntugis/ppa && apt-get update && apt-get install -y gdal-bin
RUN apt-get install -y binutils libproj-dev
RUN apt-get install -y liblog4cxx-dev liblog4cxx10-dev

RUN apt-get install -y libpthread-stubs0-dev
RUN apt-get install -y libgdal-dev

ADD . /home/cpp/mr4c
WORKDIR /home/cpp/mr4c/native
RUN make
RUN make deploy
ENV MR4C_HOME /usr/local/mr4c
RUN /usr/local/mr4c/native/bin/post_install

WORKDIR /home/cpp/mr4c/java
RUN tools/build_yarn
RUN ant deploy
RUN /usr/local/mr4c/java/bin/post_install
