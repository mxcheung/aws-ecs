from flask import Flask, send_from_directory, jsonify

app = Flask(__name__)

# Health check (for ALB or monitoring)
@app.route('/actuator/health')
def health():
    return jsonify(status="UP"), 200

# Favicon handler (to avoid 404)
@app.route('/favicon.ico')
def favicon():
    return send_from_directory('static', 'favicon.ico')

# Serve wordpress logo (for legacy health checks)
@app.route('/wp-admin/images/wordpress-logo.svg')
def wordpress_logo():
    return send_from_directory('static/wp-admin/images', 'wordpress-logo.svg', mimetype='image/svg+xml')
    

# Default route
@app.route('/')
def home():
    return "Hello Code Build from Flask on ECS!", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
