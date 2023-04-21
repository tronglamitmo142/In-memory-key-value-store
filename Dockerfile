# Using base image for running application 
FROM python:3.9-slim-buster
# Creating working directory for the application 
WORKDIR /app
# Copy and the requirements.txt file inside the app 
COPY ./app/requirements.txt /app

RUN pip install -r requirements.txt
# Copy the app's components into working directory 
COPY ./app/ .
# Specify the port is used by app, but it's only maintainance instruction. It doesn't expose this port when building image. 
EXPOSE 8088 
# Set environment variable 
ENV FLASK_APP=app.py
# Run the app. "0.0.0.0" ensure the server accept request from all hosts.  
CMD ["flask", "run", "--host", "0.0.0.0", "-p", "8088"]
