# syntax=docker/dockerfile:1

FROM python:3.7-slim-buster
WORKDIR /app

RUN apt-get update
RUN apt install build-essential -y

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
CMD ["python3", 'backend.py']