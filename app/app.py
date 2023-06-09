"""
Because we use flask as a backend service, we need to import:
    - Flask: to create an app object
    - request: to access the request data 
    - jsontify: 
    - render_template: to render template in /templates
We also use boto3 for communicating with aws resource
"""
import time 
import boto3
from boto3.dynamodb.conditions import Key
from flask import Flask, request, jsonify, render_template

# Initilize the flask app object
app = Flask(__name__)

table = boto3.resource('dynamodb', region_name='us-west-2').Table('key-value-database')


# Because the service is in-memory key-value store, so we use dictionary class in Python to store the key-value pair
store = {}
key_order = []

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
        - When the GET key request is sent, it will check if the key exits in store or not:
            - if it has, it returns the associated key-value pair
            - If not, it continue to check key-pair in database:
                - If has, return key-value and update key-value pair in dict for future usage 
                - If not, return error 
            - In both case, finally, the key-value pair is updated in database. 
    """
    value = store.get(key)
        
    try: 
        if key in store:
            return jsonify({'key': key, 'value': value})
    finally:
        response = table.get_item(
            Key={
                'key': key
            }
        )
        if 'Item' in response:
            value = response['Item']['value']
            store[key] = value
            return jsonify({'key': key, 'value': value})
        else:
            return jsonify({"status": "error", "message": "Key not found"}), 404


@app.route("/set", methods=["POST"])
def set_key():
    """
    This function aims to handler the POST key request from end user
    The logic:
        - When receive the POST request, it will check the validation of them:
            - If it's not valid, return error status
            - If it's valid, update the new key-pair into store dictionary and database.
    """
    data = request.get_json()
    key = data.get("key", "")
    value = data.get("value", "")

    if key != "" and value != "":
        store[key] = value
        item = {
            "key": key,
            "value": value
        }
        response = table.put_item(Item=item)
        return jsonify({"status": "success", "message": "Key-value pair is set successfully"})
    else:
        return jsonify({"status": "failed", "message": "Key and value must be not empty"}), 400


def reset_in_memory_store(store):
    while True:
        store.clear()
        time.sleep(300)


if __name__ == "__main__":

    app.run(port=8088, debug=True)
    
    # Every 5 minutes, the store will be clear to make sure consistency 
    reset_in_memory_store(store=store)
         

