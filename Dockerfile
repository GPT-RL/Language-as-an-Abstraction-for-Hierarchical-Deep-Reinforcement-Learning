# inspired by https://sourcery.ai/blog/python-docker/ 
FROM nvidia/cudagl:11.2.2-devel-ubuntu20.04

# Setup locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Use EGL (CUDA-accelerated) for mujoco
ENV MUJOCO_GL=egl

# no .pyc files
ENV PYTHONDONTWRITEBYTECODE 1  

# traceback on segfau8t
ENV PYTHONFAULTHANDLER 1

# use ipdb for breakpoints
ENV PYTHONBREAKPOINT=ipdb.set_trace

# common dependencies
RUN apt-get update -q \
 && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -yq \
      # primary interpreter
      python3.9 \

      # required by transformers package
      python3.9-distutils \

      # required for poetry
      curl \

      # git-state
      git \

      # for opencv-python
      libgl1-mesa-glx \
      libglib2.0-0 \

      # for EGL
      libglew2.1 \

 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.mujoco \
    && curl https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -o mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco \
    && rm mujoco.tar.gz

WORKDIR "/project"
COPY pyproject.toml poetry.lock .
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3.9 - \
 && ln -s /usr/bin/python3.9 /usr/bin/python \
 && $HOME/.poetry/bin/poetry install

# append poetry env to PATH 
ENV VIRTUAL_ENV=/root/.cache/pypoetry/virtualenvs/hal-6gE1vKXj-py3.9/
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY . .

ENTRYPOINT ["python"]
