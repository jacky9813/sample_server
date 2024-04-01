import tomllib

import flask
import flask_socketio

app = flask.Flask(__name__)
app.config.from_file(
    "config.toml",
    load=tomllib.load,
    text=False
)
socketio = flask_socketio.SocketIO(app)


@app.get("/")
def get_root():
    return flask.redirect(
        flask.url_for("static", filename="index.html")
    )


class ExampleSocketIONamespace(flask_socketio.Namespace):
    def on_connect(self):
        remote_addr = flask.request.remote_addr
        flask.current_app.logger.info(
            "New Socket.IO user: %s", remote_addr
        )
        flask_socketio.send(f'Hello, {remote_addr}')

    def on_disconnect(self):
        remote_addr = flask.request.remote_addr
        flask.current_app.logger.info(
            "Socket.IO user disconnected: %s", remote_addr
        )
    
    def on_hello(self, data=None):
        if not data:
            data = "stranger"
        flask.current_app.logger.info(
            "%s sends hello event", data
        )
        flask.session["user"] = data
        flask_socketio.emit("message", f'Hello, {data}')
        return f'Hello, {data}'
    
    def on_leave(self, data=None):
        flask_socketio.send(f'Goodbye, {flask.session.get("user", "stranger")}')
        flask_socketio.disconnect()


socketio.on_namespace(
    ExampleSocketIONamespace("/socket")
)


if __name__ == "__main__":
    socketio.run()
