ARG TEXLIVE_RELEASE=2022
ARG TEXLIVE_SNAPSHOT=2022.07.10
ARG LILYPOND_RELEASE=2.22.2
ARG REVISION=3
FROM ghcr.io/lbssousa/texlive-music:TL${TEXLIVE_RELEASE}-${TEXLIVE_SNAPSHOT}-LilyPond-${LILYPOND_RELEASE}-${REVISION}

COPY install-packages upgrade-packages /usr/bin/

### base ###
RUN install-packages \
        zip \
        unzip \
        bash-completion \
        build-essential \
        ninja-build \
        htop \
        jq \
        less \
        locales \
        man-db \
        nano \
        ripgrep \
        software-properties-common \
        sudo \
        time \
        emacs-nox \
        vim \
        multitail \
        lsof \
        ssl-cert \
        zsh \
        git \
        git-lfs \
        openssh-client \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

### Update and upgrade the base image ###
RUN upgrade-packages

### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/zsh -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" && \
    # Install Oh My ZSH
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    # Install ZSH plugin zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    # Install ZSH plugin zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    # Install ZSH theme powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

COPY dotfiles/.zshrc $HOME/.zshrc
COPY dotfiles/.p10k.zsh $HOME/.p10k.zsh

# configure git-lfs
RUN sudo git lfs install --system