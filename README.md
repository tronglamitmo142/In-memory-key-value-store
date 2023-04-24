# In-memory-key-value-store
In-memory key-value store application, included DevOps implementation 

**The application available in here: [Key-Value-App](http://a8bf9139152c74934bd64581c346bedc-2125809990.us-west-2.elb.amazonaws.com/).**  

**Workflow of CI/CD:** Everytime when developer commit into github repository, the jenkins server auto trigger the pipeline job, using Jenkinsfile in repository. The job is executed in Jenkins Agent, the step includes:
-  Build and push docker image, that associated with the commit 
-  Deloy the images into a kubernetes cluster in AWS environment.  

**To-do list:** 
- [x] Create an in-memory key-value store HTTP API Service which implements:
  - [x] /get/<key> -> Return value of the key 
  - [x] /set -> Post call which sets the key/value pair 
- [x] Create Dockerfile for this application 
- [x] Write CI/CD pipeline to deploy the Docker image to Docker repository (dockerhub)
- [x] Deploy this image into a Kubernetes cluster, using Jenkins 
- [x] Write the Service, Ingress for K8s resources 

## 1. Development requirement features of the application 

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
1. Get the value of the key
   
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


The application code in here: [app](./app/app.py)

Result  
Simple App UI  
![](./images/Screenshot%202023-04-23%20at%2021.22.52.png)  
POST Method   
![](.images/../images/Screenshot%202023-04-23%20at%2021.24.13.png)  
Get Method  
![](./images/Screenshot%202023-04-23%20at%2021.24.32.png)
## 2. Writing Dockerfile
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

## 3. DevOps Evaluation (Kubernetes)

### 3.1. Analysis and design CI/CD infrastructure

![](./image/../images/key-value-api.drawio.png)

We will build kubernetes cluster from docker images, we have to find solution for define specific version of images, and also for optimizing the build time. We used `tag`, the content of tag will be the hash of the commit in Github repository. 

For example: the image `image1:98f6b2d787dd72d4c0f4e3844ee0f94eafd0d171` is the Docker image version corresponding the commit with hash :`98f6b2d787dd72d4c0f4e3844ee0f94eafd0d171`  

## 3.2. Provision jenkins server in AWS with terraform 

Reason to choose `terraform`: Convinient for managing infrastructure.   

The IaC resource is showed here: [IaC for Jenkins Server](./terraform/jenkins_server/)  

We also created a agent server for executing the stages in pipeline. In this server, we install docker using: [install-docker script](./utils/install-docker.sh)

Setup global credentials for accessing to github repository and dockerhub 
![](./images/Screenshot%202023-04-23%20at%2007.40.48.png)

Setup webhook for automation integrating jenkins
![](./images/Screenshot%202023-04-23%20at%2015.16.23.png)

Creating AWS EKS Cluster, using [eksctl](https://github.com/weaveworks/eksctl)

Create cluster with 3 node, named: `key-value`
```bash 
eksctl create cluster --name key-value --nodegroup-name linux-nodes --node-type t2.large --nodes 3
```
Create ingress-controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/cloud/deploy.yaml
```

## 3.3. Write the Service, Ingress for the K8s resource.
Create [deployment and service](./kubernetes/deployment.yaml) and [ingress object](./kubernetes/ingress.yaml)  

### Note issue: 
- Isssue about changing ip jenkins: 
  -> for Cost Optimizing, I stoped ec2 machine in the night. And in the morning, my public IP of Jenkins was changed. But connection file of Jenkins server is still used the old ip and the agent can't communicate with Jenkins server.  
   => Need to associate DNS or elastic IP for Jenkins server in future.   
- Issue about kubectl  
  -> Kubectl version higher 1.24 can't communicate with my cluster provided by eksctl  
  => downgrade the kubectl in 1.23.7   
- Issue can't scheduling pod   
  -> In specfic instance in AWS only allow a fixed number of pod that can be scheduled. I used t2.micro for worker node and only can shedule 2 pod each nodes, it's not comfotable  
   => I need to use another instance type. 
- Issue 404 Not found in ingress controller endpoint
  -> I already setup configuration of ingress controller but when i accessed into endpoint, I found 404 error: Nginx not found.   
  I checked log of the `ingress-nginx-controller` pod and it showed: `I0423 11:44:27.168510       7 store.go:429] "Ignoring ingress because of error while validating ingress class" ingress="default/key-value-ingress-test" error="ingress does not contain a valid IngressClass"`.  
   After couples of minutes to research, I found the problem is missing ingress class in ingress object.   
  So I need to add this line to ingress.yaml
  ```yaml 
      annotations:
    kubernetes.io/ingress.class: "nginx"
  ```
  And it worked fine. 

## 4. Futher Implementation 
In this step, We tried to implementation our CI/CD process much more security and easy monitor by administration. The steps includes:
- Adding scanning step into CI/CD pipeline 
- Creating notification channel in telegram to receive any event 

