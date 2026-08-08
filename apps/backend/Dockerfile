# --- Stage 1: Builder ---
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

# Install build dependencies
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1
ENV UV_NO_CACHE=1

# Copy dependencies and install them
COPY pyproject.toml .
RUN uv sync --no-dev

# --- Stage 2: Final runtime ---
FROM python:3.12-slim-bookworm

WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=builder /app/.venv /app/.venv

# Copy the application code
COPY . .

# Set the PATH to include the virtual environment
ENV PATH="/app/.venv/bin:$PATH"

# Set non-root user and change ownership of the application directory
RUN useradd -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uv", "run", "main:app", "--host", "0.0.0.0", "--port", "8000"]
