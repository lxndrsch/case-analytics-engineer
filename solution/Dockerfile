FROM ghcr.io/dbt-labs/dbt-snowflake:1.6.4 as builder
ENV PYTHONPATH=${PYTHONPATH}:${PWD}

RUN apt-get update -yqq && apt-get install -y

WORKDIR /app
COPY . /app
RUN pip3 install poetry
RUN poetry install
