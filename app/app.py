"""
Because we use flask as a backend service, we need to import:
    - Flask: to create an app object
    - request: to access the request data 
    - jsontify: 
    - render_template: to render template in /templates
"""
from flask import Flask, request, jsonify, render_template

# Initilize the flask app object
app = Flask(__name__)

# Because the service is in-memory key-value store, so we use dictionary class in Python to store the key-value pair
store = {}


@app.route("/")
def home():
    """
    When end user go to the address of application, they will redirect into this address.
    This route is using index.html for UI.
    The index.html provide the UI for interacting with:
        - /get<key>: for getting the value of the key
        - /set: for setting the key-value pair
    """
    return render_template("index.html")


@app.route("/get/<key>", methods=["GET"])
def get_key(key):
    """
    This function aims to handler the GET key request from end user
    The logic:
        - When the GET key request is sent, it will if the key exits in store or not:
            - if it has, it returns the associated key-value pair
            - If not, it returns the error status
    """
    if key in store:
        return jsonify({"key": key, "value": store[key]})
    else:
        return jsonify({"status": "error", "message": "Key not found"}), 404


@app.route("/set", methods=["POST"])
def set_key():
    """
    This function aims to handler the POST key request from end user
    The logic:
        - When receive the POST request, it will check the validation of them:
            - If it's not valid, return error status
            - If it's valid, update the new key-pair into store dictionary.
    """
    data = request.get_json()
    key = data.get("key")
    value = data.get("value")

    if key is not None and value is not None:
        store[key] = value
        return jsonify(
            {"status": "success", "message": "Key-value pair is set successfully"}
        )
    else:
        return jsonify({"status": "error", "message": "Invalid key pair"}), 400


if __name__ == "__main__":
    app.run(port=8088, debug=True)
