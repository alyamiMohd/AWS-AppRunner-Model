# Use the official Python image as the base image
FROM python:3.10

# Set an environment variable to enable unbuffered mode (recommended for Python running in containers)
ENV PYTHONUNBUFFERED 1

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY ./requirements.txt /app/requirements.txt

# Install required system packages
RUN apt-get update && \
    apt-get install -y libgl1-mesa-glx libglib2.0-0

# Create a virtual environment and activate it
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install Python dependencies
COPY cython_constraint.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    PIP_CONSTRAINT=cython_constraint.txt pip install --no-cache-dir -r /app/requirements.txt

# Install Gunicorn
RUN pip install gunicorn

# Copy the rest of your application files into the container
COPY . /app/

# Set TensorFlow log level
ENV TF_CPP_MIN_LOG_LEVEL=2

# Expose the port that Gunicorn will listen on
EXPOSE 5000

# Specify the command to run your application with Gunicorn
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "view:app"]
