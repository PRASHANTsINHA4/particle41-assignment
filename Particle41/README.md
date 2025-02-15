![image](https://github.com/user-attachments/assets/ec58af28-0818-44c2-af76-c38f422d7bf3)Task 1 - Minimalist Application Development / Docker / Kubernetes
# SimpleTimeService

SimpleTimeService is a lightweight microservice that provides the current timestamp and the visitor's IP address in JSON format.

## Features
- Returns the current timestamp
- Returns the visitor's IP address
- Lightweight and containerized
- Runs as a non-root user for security

## JSON Response Format
```json
{
  "timestamp": "<current date and time>",
  "ip": "<visitor's IP address>"
}
```

## Technologies Used
- Programming Language: Python
- Web Framework: [Framework based on the chosen language]
- Docker for containerization

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed on your system

## Building the Docker Image
To build the Docker image, run:
```sh
docker build -t simpletimeservice .
```

## Running the Container
To run the container:
```sh
docker run -p 5000:5000 simpletimeservice
```
The service will be accessible at `http://localhost:5000/`

## Pulling the Image from a Public Registry
If the image has been pushed to a public registry like DockerHub, you can pull and run it directly:
```sh
docker pull prassinha13/particle41-webapp:latest
```
```sh
docker run -it -p 5000:5000 --name webapp-test prassinha13/particle41-webapp
```

check the container 0r application ruuning or not 
![image](https://github.com/user-attachments/assets/c542efc9-3cbf-409c-8bc6-72a3899e7f04)

#use curl command to know the applicationis working or not
root@MSI:~/Particle41# curl http://127.0.0.1:5000

#Output
{"ip":"172.17.0.1","timestamp":"2025-02-15 06:28:59.993944"}


## Deploying to a Cloud Provider
The service can be deployed on AWS ECS, AWS Lambda with API Gateway, GCP Cloud Run, or Kubernetes using Terraform.

## Repository Structure
```
/
├── src/                  # Application source code
├── Dockerfile            # Docker build configuration
├── README.md             # Documentation
├── .dockerignore         # Files to ignore when building Docker image
└── .gitignore            # Files to ignore in Git repository
```

## Security Considerations
- Runs as a non-root user in the container
- Avoids unnecessary dependencies to keep the image minimal



