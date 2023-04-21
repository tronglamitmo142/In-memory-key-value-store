from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

store = {}

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/get/<key>', methods=['GET'])

def get_key(key):
    if key in store:
        return jsonify({"key": key, "value": store[key]})
    else:
        return jsonify({
            "status": "error",
            "message": "Key not found"
        }), 404 

@app.route('/set', methods=['POST'])
def set_key():
    data = request.get_json()
    key = data.get('key')
    value = data.get('value')

    if key is not None and value is not None:
        store[key] = value 
        return jsonify({
            "status": "success",
            "message": "Key-value pair is set successfully"
        })
    else: 
        return jsonify({
            "status": "error",
            "message": "Invalid key pair"
        }), 400

if __name__ == '__main__':
    app.run(debug=True)