# 현재 kubectl이 어디로 해석되는지 확인
# kubectl 설치했는데 PATH가 꼬였거나, 설치가 실제로 안됐걷나, hash/alias/hash cache가 남아있는 케이스
# 아래 순서대로 실행할 것

# 1) 현재 kubectl이 어디로 해석되는지 확인
#    → 여기서 /usr/local/bin/kubectl이 보여야 정상.
type -a kubectl
command -v kubectl
which kubectl

# 2) bash가 예전 경로를 “기억”하고 있을 수 있음 (hash 캐시 제거)
hash -r
# 그 다음 다시
command -v kubectl

# 3) /usr/local/bin/kubectl이 실제로 존재하는지 확인
#    → 정상이라면: file 결과에 x86-64가 떠야 함
#    → 만약 “없다”면, 3단계 스크립트에서 설치가 안 된 거라 다시 설치하면 됨(아래 5번).
ls -l /usr/local/bin/kubectl
file /usr/local/bin/kubectl

# 4) PATH 우선순위 확인 (왜 ~/.local/bin을 계속 보려 했는지)
# 보통 ~/.local/bin이 앞쪽이면 우선으로 잡힐 수 있음.
# 근데 지금은 그 파일이 없으니, 정상이라면 다음 후보(/usr/local/bin)를 찾아야 하는데 계속 “~/.local/bin…”만 말하는 건 hash 캐시 가능성이 큼 → 위에서 hash -r이 해결.
echo "$PATH" | tr ':' '\n' | nl -ba | head -n 30
# 추가로 alias 확인
alias kubectl 2>/dev/null || true

# 5) kubectl을 x86_64로 다시 “정상 설치”하고 확인
# 아래는 x86_64 고정 설치(내 환경이 x86_64라 확정이니까)
#    → command -v kubectl이 /usr/local/bin/kubectl로 나와야 끝. 
cd ~
KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
hash -r
command -v kubectl
kubectl version --client

# 6) 이제 kind 클러스터 확인
# kubectl이 살아나면:
kubectl config get-contexts
kubectl get nodes
kubectl cluster-info --context kind-dev