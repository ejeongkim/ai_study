# ai_study
다양한 ai 개발 도구 및 어시스턴트 연동 테스트 코드입니다.

---

# day1 26.02.20 # ai studio

# 최초 세팅 방법
0. setting.yml 앤서블 파일 실행
> ansible-playbook setting.yml

1. 아래 파일 3개 생성
> .env .envrc .env.example .gitignore

2. env 자동 로딩까지 하고 싶으면 direnv 설정
> sudo apt update && sudo apt install -y direnv && direnv allow

3. systemd 켜기 (wsl에서 docker 서비스 쓰려면 편함)
> bash 창에서 아래와 같이 입력
sudo tee /etc/wsl.conf > /dev/null <<'EOF'
[boot]
systemd=true
EOF

> windows powershell에서 아래 입력
wsl --shutdown

> 다시 wsl 들어가서 아래 명령어 입력시 systemd 가 나오면 OK
ps -p 1 -o comm=

4. Docker Engine 설치
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo ${UBUNTU_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

> 권한 (매번 sudo 치기 싫으면)
sudo usermod -aG docker $USER

> WSL 다시 들어간 뒤 
docker version
docker run --rm hello-world

5. 아키텍처에 맞는 kubectl 설치
**아키텍처 결정**
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) KARCH="amd64" ;;
  aarch64|arm64) KARCH="arm64" ;;
  *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

**최신 안정 버전(공식) 가져오기**
KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/${KARCH}/kubectl"
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/${KARCH}/kubectl.sha256"

**해시 검증**
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

**설치**
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

**확인**
kubectl version --client

**direnv**
- sudo apt install -y direnv && direnv allow 
- direnv status && direnv exprot bash | head
- .env 와 .envrc 를 바탕으로 실행

6. kind 로 k8s 클러스터 띄우기 (k8s 설치를 위한 도구)
> 설치
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

> 클러스터 생성
kind create cluster --name dev
kubectl cluster-info --context kind-dev


# k8s 관련 세팅
1. gemini 키를 k8s secret으로 넣기
> .env/direnv도 좋지만, K8s에 올릴 거면 Secret이 정석.
kubectl create secret generic gemini-secrets \
  --from-literal=GEMINI_API_KEY='YOUR_KEY_HERE(실제키)'

> 확인
kubectl get secret gemini-secrets

2. Python FastAPI로 “Gemini 호출 API” 만들기 (컨테이너화)
> 프로젝트 폴더 : midker -p ai_study && cd ai_study
> requirements.txt
cat > requirements.txt <<'EOF'
fastapi
uvicorn[standard]
google-genai
EOF

# Node trouble-shooting
- high severity vulnerabilities (보안취약성 경고)
> npm audit && npm audit fix
> 호환 꺠지지 않는 범위 내에서 자동 수정 
