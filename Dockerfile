# inspired by https://sourcery.ai/blog/python-docker/ 
FROM nvidia/cuda:11.2.1-cudnn8-devel-ubuntu20.04 as base
ARG CUDA_SHORT=112

# Setup locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

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

      # for opencv-python
      libglew2.1 \

 && apt-get clean

WORKDIR "/project"
COPY pyproject.toml poetry.lock .
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3.9 - \
 && $HOME/.poetry/bin/poetry install

RUN mkdir -p /root/.mujoco \
    && curl https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -o mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco \
    && rm mujoco.tar.gz

ENV VIRTUAL_ENV=/root/.cache/pypoetry/virtualenvs/generalization-K3BlsyQa-py3.8/
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV MUJOCO_GL=egl
COPY . .

ENTRYPOINT ["python"]
