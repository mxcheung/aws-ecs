from flask import Flask, send_from_directory

app = Flask(__name__)

@app.route('/wp-admin/images/wordpress-logo.svg')
def serve_logo():
    return send_from_directory('static/wp-admin/images', 'wordpress-logo.svg')

@app.route('/')
def home():
    return "Hello from ECS!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
