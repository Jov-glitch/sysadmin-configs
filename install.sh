#!/bin/bash

# ================================================
# Script install
# JessVega Dev
# Target: Fedora Linux
# ================================================

# -- Config var
GIT_USER="Jov-glitch"
REPO_NAME="sysadmin-configs"
INSTALL_DOCKER=true

# colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# logs functions
# =============
log() {
    echo -e "${BLUE}[BOOTSTRAP]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# sudo check
# ==========
if [[ $EUID -ne 0 ]]; then
    error "No sudo in the command. Please run as root."
fi

# Update
# =====
log "Running dnf update..."

dnf update -y || error "Failed to update this system"
success "System Updated!"


# Programs
# ========
log "Installing tools... (git, nano, nginx)"
PACKAGES=(git nano nginx)

dnf install -y "${PACKAGES[@]}" || error "Failed to installing this tools"
success "Packages installed"


# Docker
# ======
if [ "$INSTALL_DOCKER" = true ]; then
    log "Configuring docker..."

    dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Faild to install Docker"
    systemctl enable --now docker

    # Agregar usuario al grupo docker
    REAL_USER=$(logname || echo $SUDO_USER)
    if [ ! -z "$REAL_USER" ]; then
        usermod -aG docker $REAL_USER
        success "User $REAL_USER added to docker group."
    fi

    success "Docker installed"
fi


# clone the repo
# ==============
log "Cloning github repo..."

# Crear carpeta de trabajo
REAL_USER=$(logname || echo $SUDO_USER)
WORKSPACE="/home/$REAL_USER/workspace"
mkdir -p "$WORKSPACE"
chown $REAL_USER:$REAL_USER "$WORKSPACE"

cd "$WORKSPACE"
if [ ! -d "$REPO_NAME" ]; then
    sudo -u $REAL_USER git clone https://github.com/$GIT_USER/$REPO_NAME.git
    success "Repo $REPO_NAME cloned."
else
    log "Repo exists, updating..."
    cd "$REPO_NAME" && sudo -u $REAL_USER git pull
fi

# Apply config
# ============
log "Applying configurations from repo..."

# Ejemplo: Copiar config de Nginx si existe en el repo
if [ -f "$WORKSPACE/$REPO_NAME/nginx/reverse-proxy.conf" ]; then
    # Nginx ya se instaló en el paso de Tools
    cp "$WORKSPACE/$REPO_NAME/nginx/reverse-proxy.conf" /etc/nginx/conf.d/
    systemctl enable nginx
    success "Configuration of nginx applied"
fi

# Clean and restart
# =================
log "Cleaning cache and packages..."
dnf clean all

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   		     Finish       	       ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo "Rebooting in 5 seconds..."
sleep 5
reboot
