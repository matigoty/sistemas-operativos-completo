#!/bin/bash
# Script de backup para base de datos MariaDB

# Nombre de la base de datos
DB_NAME="matias_fernandez"

# Usuario y contraseña
DB_USER="admin"
DB_PASS="4321"

# Fecha actual
FECHA=$(date +%F_%H-%M)

# Directorio donde se guardan los backups
BACKUP_DIR="/backups"

# Archivo final del backup
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${FECHA}.sql"

# Ejecutar backup
mysqldump -u "$DB_USER" -p"$DB_PASS" --single-transaction "$DB_NAME" > "$BACKUP_FILE"

# Verificar estado del backup
if [ $? -eq 0 ]; then
    echo "$(date) Backup de DB completado: $BACKUP_FILE" >> /var/log/backup_db.log
else
    echo "$(date) ERROR: Backup de DB FALLÓ" >> /var/log/backup_db.log
fi

exit 0
