FROM docker-registry.tools.wmflabs.org/toolforge-python39-sssd-base:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install libopenblas-base libgomp1 libatomic1 python3-venv -y

RUN useradd -ms /bin/bash larynx

USER larynx
RUN mkdir -p /home/larynx/app
WORKDIR /home/larynx/app

# Create virtual environment
RUN python3.9 -m venv venv && venv/bin/pip3 install --upgrade pip && \
    venv/bin/pip3 install --upgrade wheel setuptools

# Copy requirements, and install
COPY requirements.txt requirements.txt
RUN venv/bin/pip3 install -r requirements.txt

# Copy source code
COPY larynx/ /home/larynx/app/larynx/

# Copy voices and vocoders
COPY local/ /home/larynx/app/local/

# Copy package setup
COPY setup.py setup.py

RUN venv/bin/pip3 install .

EXPOSE 5002

ENV PYTHONPATH=/home/larynx/app

ENTRYPOINT ["/home/larynx/app/venv/bin/python3", "-m", "larynx.server"]