FROM nvidia/cuda:10.1-runtime-ubuntu18.04

ENV GOOGLE_APPLICATION_CREDENTIALS "./token.json"

RUN apt-get update && apt-get install -y \
    python3.7 \
    python3-pip \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libcudnn7 \
    ffmpeg

ENV APP_HOME /app
WORKDIR $APP_HOME

# Install production dependencies.
COPY requirements.txt .

RUN pip3 install --upgrade pip setuptools

RUN pip3 install -r requirements.txt

# Copy local code to the container image.
COPY . ./

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind 0.0.0.0:80 --workers 1 --threads 8 --timeout 0 app:app