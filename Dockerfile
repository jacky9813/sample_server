ARG UWSGI_VERSION=2.0.24
ARG UWSGI_TAR_SHA256SUM=6be644f8c36379a97ca1c71c03c146af109983a58eacefbcfdaaff3c62d7edf8
ARG UWSGI_USER=uwsgi
ARG UWSGI_GROUP=uwsgi

FROM python:3.12-alpine AS python_base_image

# ========================================

FROM python_base_image AS wheel_builder
RUN apk add musl-dev ncurses-dev bzip2-dev gdbm-dev libnsl-dev xz-dev \
    openssl3-dev tk-dev libuuid readline-dev sqlite-dev libffi-dev gcc make \
    automake wget tar gzip && \
    pip3 install build 

# ========================================

FROM wheel_builder AS uwsgi_builder
ARG UWSGI_VERSION
ARG UWSGI_TAR_SHA256SUM
ADD https://github.com/unbit/uwsgi/archive/refs/tags/${UWSGI_VERSION}.tar.gz /
RUN echo "${UWSGI_TAR_SHA256SUM}  ${UWSGI_VERSION}.tar.gz" | sha256sum -c && tar xf ${UWSGI_VERSION}.tar.gz
WORKDIR "/uwsgi-${UWSGI_VERSION}"
RUN python uwsgiconfig.py --build default

# ========================================

FROM python_base_image
ARG UWSGI_VERSION
ARG UWSGI_USER
ARG UWSGI_GROUP
ARG ALERT_ROUTER_VERSION
RUN mkdir -p /app /app/sample_server && \
    pip install gevent && \
    addgroup -S ${UWSGI_GROUP} && \
    adduser -G ${UWSGI_GROUP} -S -D -H -h /app -s /sbin/nologin ${UWSGI_USER}
WORKDIR /app
COPY ./pyproject.toml ./README.rst /app/
COPY ./sample_server /app/sample_server
RUN tree && pip install -e .

# Copy uwsgi executable
COPY --from=uwsgi_builder /uwsgi-${UWSGI_VERSION}/uwsgi /uwsgi

USER ${UWSGI_USER}
EXPOSE 8080
LABEL description=""
LABEL "path.config"="/app/sample_server/server.toml"
ENTRYPOINT [ "/uwsgi", "-w", "sample_server:app" ]
CMD ["--http", "0.0.0.0:8080", "--gevent", "128", "--http-websockets", "--master"]
