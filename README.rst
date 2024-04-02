#################
Sample Web Server
#################


This is a Flask-based web server example, with an endpoint available for 
testing WebSocket with `Socket.IO<https://socket.io/>`.

The container image includes a uWSGI as frontend server.


Endpoints
=========

- ``/``: Redirects to ``/static/index.html``.
- ``/static/index.html``: A basic Socket.IO application.
- ``/socket.io``: The endpoint for Socket.IO (WebSocket).

Usage
=====

Docker
------

Note: There is a known issue in Docker that gives extremely high open files
count, some cases can have "unlimited". See unbit/uwsgi#2299, cri-o/cri-o#7703
and moby/moby#38814 for more detail on ulimit settings for containers.

The example below provides a workaround for this problem.

```sh
docker run -d -p 0.0.0.0:8080:8080 --ulimit nofile=4096:4096 \
    ghcr.io/jacky9813/sample_server
```


Run directly
------------

```sh
git clone https://github.com/jacky9813/sample_server
cd sample_server
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
flask --app sample_server.app run -h 127.0.0.1 -p 8080
```
