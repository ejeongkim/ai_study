FROM python:3.12-slim

# uv 설치
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# 의존성 파일 먼저 복사 (캐시 최적화)
COPY app/pyproject.toml ./

# 가상환경 생성 + 설치
RUN uv venv /opt/venv \
 && uv sync --venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# 소스 복사
COPY app/api_gemini.py ./

EXPOSE 8000

CMD ["uvicorn", ":app", "--host", "0.0.0.0", "--port", "8000"]