✅ 1. 기본 구조 (uv 방식)
프로젝트 구조:
ai_study/
 ├─ app/
 │   ├─ main.py
 │   └─ pyproject.toml
 ├─ Dockerfile
 └─ k8s.yaml


 ✅ 2. uv 설치 (한 번만)
WSL에서:
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

확인:
uv --version


✅ 3. pyproject.toml 생성
app/pyproject.toml:
```
[project]
name = "gemini-api"
version = "0.1.0"
description = "Gemini API FastAPI Service"
requires-python = ">=3.11"

dependencies = [
  "fastapi>=0.110",
  "uvicorn[standard]>=0.29",
  "google-genai>=0.3",
]

[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"
```


✅ 4. 로컬 개발 (uv 방식. 5번으로 대체 가능이고 로컬 개발 용이다)
```
cd app

# 가상환경 자동 생성 + 의존성 설치
uv sync

# 실행
uv run uvicorn api_gemini:app --reload
```
이러면:
.venv 및 uv.lock 자동 생성
패키지 자동 설치
별도 activate 필요 없음


✅ 5. Dockerfile (uv + pyproject 대응)
기존 Dockerfile 대신 이걸 쓰는 게 깔끔함.
```
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
COPY app/main.py ./

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```
👉 이 방식이 Docker 레이어 캐시도 잘 먹고, 빌드도 빠름.


✅ 6. 이미지 재빌드 → kind 반영
```
docker build -t gemini-api:dev .
kind load docker-image gemini-api:dev --name dev

kubectl rollout restart deploy/gemini-api
kubectl rollout status deploy/gemini-api
```


✅ 7. 로컬 + 컨테이너 + K8s 통합 워크플로우

이제 네 개발 루틴은 이렇게 가면 됨:

🔹 로컬 개발
cd app
uv sync
uv run uvicorn api_gemini:app --reload
🔹 컨테이너 테스트
docker build -t gemini-api:dev .
docker run -p 8000:8000 --env-file .env gemini-api:dev
🔹 K8s 반영
kind load docker-image gemini-api:dev --name dev
kubectl rollout restart deploy/gemini-api


✅ 8. uv 쓰는 게 왜 좋냐? (현실적인 이유)
항목	    pip+venv	    uv
속도	    느림	        매우 빠름
venv 관리	수동	        자동
lockfile	없음/불편	    uv.lock
Docker	    복잡	       깔끔
재현성	    낮음	        높음

uv는 Rust로 만들어져서 pip보다 체감 속도 차이가 큼.

🎯 결론
지금 네 스택(WSL + Docker + K8s + LLM API)에는
👉 uv + pyproject.toml이 베스트 조합이다.