from flask import Flask, jsonify
import os


def create_app():
    app = Flask(__name__)

    @app.route("/")
    def health():
        return jsonify({
            "status": "ok",
            "message": "Flask application is running successfully How are you doing now"
        })

    @app.route("/hello")
    def hello():
        return jsonify({
            "message": "Hello World from Flask running inside Docker, What about the world is that safe"
        })

    return app


if __name__ == "__main__":
    app = create_app()

    port = int(os.environ.get("PORT", 5000))

    app.run(
        host="0.0.0.0",
        port=port
    )
