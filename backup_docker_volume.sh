#!/bin/bash

# Nome do volume que será feito o backup
VOLUME_NAME="meu_volume"

# Caminho temporário para armazenar o backup
BACKUP_DIR="/tmp/docker_backup"

# Nome do arquivo de backup com data e hora
BACKUP_FILE="${VOLUME_NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"

# Destino remoto via SCP
REMOTE_USER="backup"
REMOTE_HOST="192.168.0.100"
REMOTE_PATH="/home/backup"

# Verifica se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "Docker não está instalado. Abortando..."
  exit 1
fi

echo "Docker está instalado."

# Cria diretório de backup temporário
mkdir -p "$BACKUP_DIR"

# Faz o backup do volume usando um container Alpine
docker run --rm \
  -v ${VOLUME_NAME}:/volume \
  -v ${BACKUP_DIR}:/backup \
  alpine \
  tar czf /backup/${BACKUP_FILE} -C /volume .

echo "Backup criado em ${BACKUP_DIR}/${BACKUP_FILE}"

# Envia o backup via SCP para o servidor remoto
scp "${BACKUP_DIR}/${BACKUP_FILE}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

if [ $? -eq 0 ]; then
  echo "Backup enviado com sucesso para ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
else
  echo "Falha ao enviar o backup via SCP."
fi

# Remove o arquivo temporário
rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
