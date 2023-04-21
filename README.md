# In-memory-key-value-store
In-memory key-value store application, included DevOps implementation 

To-do list: 
- [x] Create an in-memory key-value store HTTP API Service which implements:
  - [x] /get/<key> -> Return value of the key 
  - [x] /set -> Post call which sets the key/value pair 
- [x] Create Dockerfile for this application 
- [ ] Write CI/CD pipeline to deploy the Docker image to Docker repository (dockerhub)
- [ ] Deploy this image into a Kubernetes cluster, using Jenkins 
- [ ] Write the Service, Ingress for K8s resources 
- [ ] Optimizing the solution 

## 1. Setup DevOps Environment 
![](./images/key-value-api.drawio%20(1).png)

## 2. Development requirement features of the application 

First of all, We have to analyze the task for a clear implementation.

**Task**: The **in-memory** **key-value** store **API** will allow client to store and retrieve key-value pairs. The API support 2 operations:
- /set: Post call which sets the key/value pair
- /get/<key>: Retrieve the value of the key  

```Note: Because this is in-memory store, so all data are not store permently.``` 

So, the behavior API Endpoints will have:
1. Set a key-value pair
- URL: `/set`
- Method: `POST`
- Request Body: 
    ```json 
    {
    "key": "key_1",
    "value": "value_1"
    }
    ```
- Success Response:
  - Code: `200 OK`
    ```json
    {
        "status": "success",
        "message": "key-value pair is set successfully"
    }
    ```
2. Get the value of the key
- URL : `/get/<key>`
- Method: `GET`
- URL Parameters: `key` - string 
- Success Response: 
  - Code: `200 OK`
  - Content: 
    ```json
    {
        "key": "key_1",
        "value" "value_1"
    }
    ```
- Error Response:
  - Code: `404 Not Found`
  - Content:
    ```json
    {
        "status": "error",
        "message": "Key not found"
    }
    ```
Implementation the API service with Python, Flask framework.

Reason choosing Flask:
- Simple framework, easy to learn and implementation. 

The application code is here: [app](./app/app.py)

3. Writing Dockerfile
The Dockerfile is here: [Dockerfile](./Dockerfile)

Verify: Using [verify-api script](./utils/verify-api.sh)
```bash
# Build docker images and docker container from that image

$ docker build -t flask-app .

# Verify the script

$ cd utils
$ chmod +x verify-api.sh
$ ./verify-api.sh
```
![](./images/Screenshot%202023-04-21%20at%2015.39.20.png)

