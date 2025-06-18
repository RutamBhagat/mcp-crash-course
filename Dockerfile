# Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Pin uv to a specific version for reproducibility (best practice)
COPY --from=ghcr.io/astral-sh/uv:0.7.13 /uv /uvx /bin/

# Set environment variables for best practices
ENV UV_LINK_MODE=copy
ENV UV_COMPILE_BYTECODE=1

# Set the working directory in the container
WORKDIR /app

# Copy project definition (pyproject.toml) and lock file (if available)
# Assumes pyproject.toml exists in your project root (shellserver).
# If you generate and use a lock file (uv.lock), uncomment the second COPY line for reproducible builds.
COPY pyproject.toml ./
COPY uv.lock ./

# Install dependencies using uv sync with --locked for reproducibility
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

# Copy the application code into the container
COPY server.py .
# If you decided to vendor the 'mcp' package (copying it into shellserver), uncomment the next line:
# COPY ./mcp ./mcp

# Install the project itself using uv sync
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# Note: Ensure .venv is listed in your .dockerignore to avoid copying local virtual environments.

# Define the command to run the application using 'uv run'
CMD ["uv", "run", "server.py"]
