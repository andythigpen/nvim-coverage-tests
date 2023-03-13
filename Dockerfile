ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV PIPENV_VENV_IN_PROJECT=True
ENV SHELL=/bin/bash

RUN apt-get update && apt-get install -y curl git lcov \
    python luarocks build-essential libreadline-dev unzip libxml2-dev \
    && rm -rf /var/lib/apt/lists/*
RUN curl -L -o nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz && \
    tar xzvf nvim-linux64.tar.gz -C /usr/local --strip-components=1 && \
    rm -f nvim-linux64.tar.gz
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
        /root/.local/share/nvim/site/pack/packer/start/packer.nvim

ADD config/ /root/.config/nvim

RUN /usr/local/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
