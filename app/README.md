local testing 

Running app 
```bash
$ python3 -m venv venv 
$ pip install -r requirements.txt 
$ python3 app.py
```

Testing Set key-value
```bash
$ curl -X POST -H "Content-Type: application/json" -d '{"key": "example_key", "value": "example_value"}' http://127.0.0.1:8088/set

{
  "message": "Key-value pair is set successfully",
  "status": "success"
}
```

Testing GET value from key
```bash
curl -X GET "http://127.0.0.1:8088/get/example_key"

{
  "key": "example_key",
  "value": "example_value"  
}
```