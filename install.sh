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
    curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
    
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


# NGINX SELECTION MENU
# =====================
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${BLUE}   NGINX DEPLOYMENT STRATEGY                    ${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
echo "How do you want to install Nginx?"
echo "  1) Local System (Native package via dnf)"
echo "  2) Docker Container (Isolated)"
echo ""
read -p "Select an option [1 or 2]: " NGINX_CHOICE

case $NGINX_CHOICE in
    1)
        log "Installing Nginx on Local System..."
        dnf install -y nginx
        systemctl enable --now nginx
        
        # Copiar config si existe
        if [ -f "$WORKSPACE/$REPO_NAME/nginx" ]; then
             cp "$WORKSPACE/$REPO_NAME/nginx/*" /etc/nginx/conf.d/
             log "Config copied to /etc/nginx/conf.d/"
        fi
        success "Nginx (Local) installed and running."
        ;;
        
    2)
        log "Deploying Nginx via Docker..."
        
        # Verificar que Docker esté instalado primero
        if ! command -v docker &> /dev/null; then
            error "Docker is not installed! Cannot deploy container."
        fi

        # Crear un contenedor simple de Nginx
        docker run -d \
            --name nginx-main \
            -p 80:80 \
            --restart always \
            nginx:alpine
            
        success "Nginx (Docker) container started on port 80."

	docker cp "$WORKSPACE/$REPO_NAME/nginx/*" nginx-main:/etc/nginx/
	
	success "Nginx config apply to container."

        ;;

        
    *)
        log "Invalid option selected. Skipping Nginx installation."
        ;;
esac

# Apply config
# ============
#log "Applying configurations from repo..."

# If exist, do it
#if [ -f "$WORKSPACE/$REPO_NAME/nginx" ]; then
#    # Nginx ya se instaló en el paso de Tools
#    cp "$WORKSPACE/$REPO_NAME/nginx/*" /etc/nginx/conf.d/
#    systemctl enable nginx
#    success "Configuration of nginx applied"
#fi

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
