sudo apt update
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  grep \
  vim \
  unzip \
  zip \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  python3 python3-pip python3-venv
  python3 -m pip install --upgrade pip setuptools wheel

curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts

sudo apt install -y docker.io
sudo usermod -aG docker $USER

docker --version

sudo apt install -y zsh
chsh -s $(which zsh)