#!/bin/bash

# =========================================================
# INSTALADOR AUTO-EJECUTABLE BOT VPN SUPERC4MPEON
# Descarga desde Dropbox y ejecuta automáticamente
# Con gestión completa de servidores en panel admin
# ============================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Banner de bienvenida
clear
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════╗   
║         BOT TELEGRAM VPN - INSTALADOR DEFINITIVO ║
║                  v2.0 - Con Panel Admin Full              ║
╚═════════════════════════════════════╝
EOF
echo -e "${NC}"

# Funciones auxiliares
mostrar_error() {
    echo -e "${RED}❌ $1${NC}"
}

mostrar_exito() {
    echo -e "${GREEN}✅ $1${NC}"
}

mostrar_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

mostrar_advertencia() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

mostrar_titulo() {
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

validar_input() {
    local input=$1
    local mensaje=$2
    if [ -z "$input" ]; then
        mostrar_error "$mensaje no puede estar vacío"
        return 1
    fi
    return 0
}

validar_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        mostrar_error "Formato de IP inválido"
        return 1
    fi
}

validar_numero() {
    local num=$1
    if [[ $num =~ ^[0-9]+$ ]]; then
        return 0
    else
        mostrar_error "Debe ser un número"
        return 1
    fi
}

# Verificar permisos de root
if [ "$EUID" -ne 0 ]; then 
    mostrar_error "Este script debe ejecutarse como root"
    echo "Ejecuta: sudo bash $0"
    exit 1
fi

# Detectar sistema operativo
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    mostrar_error "No se pudo detectar el sistema operativo"
    exit 1
fi

mostrar_info "Sistema operativo detectado: $OS"
sleep 1

# ======= CONFIGURACIÓN INICIAL ==========
mostrar_titulo "📋 CONFIGURACIÓN DEL BOT"

while true; do
    read -p "🔑 Token de Telegram Bot: " TELEGRAM_TOKEN
    if validar_input "$TELEGRAM_TOKEN" "Token de Telegram"; then
        break
    fi
done

while true; do
    read -p "👤 Tu ID de Telegram (admin): " ADMIN_ID
    if validar_input "$ADMIN_ID" "ID de administrador" && validar_numero "$ADMIN_ID"; then
        break
    fi
done

read -p "💳 Token MercadoPago (opcional, Enter para omitir): " MERCADOPAGO_TOKEN

# Precios
mostrar_titulo "💰 CONFIGURACIÓN DE PRECIOS"

while true; do
    read -p "💎 Precio 30 días (ARS): " PRECIO_30_DIAS
    if validar_input "$PRECIO_30_DIAS" "Precio 30 días" && validar_numero "$PRECIO_30_DIAS"; then
        break
    fi
done

while true; do
    read -p "🔶 Precio 15 días (ARS): " PRECIO_15_DIAS
    if validar_input "$PRECIO_15_DIAS" "Precio 15 días" && validar_numero "$PRECIO_15_DIAS"; then
        break
    fi
done

while true; do
    read -p "🔷 Precio 7 días (ARS): " PRECIO_7_DIAS
    if validar_input "$PRECIO_7_DIAS" "Precio 7 días" && validar_numero "$PRECIO_7_DIAS"; then
        break
    fi
done

# Configuración de servidores
mostrar_titulo "🖥️  CONFIGURACIÓN DE SERVIDORES"

SERVERS_CONFIG=""
SERVER_COUNT=0

mostrar_info "Puedes configurar hasta 5 servidores ahora"
mostrar_info "También podrás agregar/eliminar servidores desde el panel admin después"
echo ""

for i in {1..5}; do
    echo ""
    mostrar_advertencia "Configurando Servidor $i"
    
    read -p "¿Configurar Servidor $i? (s/n): " CONFIGURAR_SERVER
    if [[ $CONFIGURAR_SERVER != "s" && $CONFIGURAR_SERVER != "S" ]]; then
        continue
    fi
    
    while true; do
        read -p "🏷️  Nombre del servidor: " SERVER_NAME
        if validar_input "$SERVER_NAME" "Nombre del servidor"; then
            break
        fi
    done
    
    while true; do
        read -p "🌐 IP del servidor: " SERVER_IP
        if validar_input "$SERVER_IP" "IP del servidor" && validar_ip "$SERVER_IP"; then
            break
        fi
    done
    
    read -p "👤 Usuario SSH [root]: " SERVER_USER
    SERVER_USER=${SERVER_USER:-root}
    
    while true; do
        read -s -p "🔒 Contraseña SSH: " SERVER_PASS
        echo
        if validar_input "$SERVER_PASS" "Contraseña SSH"; then
            break
        fi
    done
    
    read -p "🚪 Puerto SSH [22]: " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-22}
    
    if ! validar_numero "$SERVER_PORT"; then
        SERVER_PORT=22
    fi
    
    # Agregar servidor a la configuración
    SERVER_JSON="        {
            \"id\": $SERVER_COUNT,
            \"name\": \"$SERVER_NAME\",
            \"host\": \"$SERVER_IP\",
            \"port\": $SERVER_PORT,
            \"username\": \"$SERVER_USER\", 
            \"password\": \"$SERVER_PASS\",
            \"enabled\": true
        }"
    
    if [ -z "$SERVERS_CONFIG" ]; then
        SERVERS_CONFIG="$SERVER_JSON"
    else
        SERVERS_CONFIG="$SERVERS_CONFIG,$SERVER_JSON"
    fi
    
    SERVER_COUNT=$((SERVER_COUNT + 1))
    mostrar_exito "Servidor $SERVER_NAME agregado correctamente"
done

if [ $SERVER_COUNT -eq 0 ]; then
    mostrar_error "Debes configurar al menos un servidor"
    exit 1
fi

# Configuración de soporte
mostrar_titulo "📞 CONFIGURACIÓN DE SOPORTE"
read -p "👤 Usuario de soporte en Telegram [@superc4mpeon]: " SOPORTE_USER
SOPORTE_USER=${SOPORTE_USER:-@superc4mpeon}

# Instalar dependencias
mostrar_titulo "📦 INSTALANDO DEPENDENCIAS DEL SISTEMA"
mostrar_info "Actualizando repositorios..."
apt update  > /dev/null 2>&1

mostrar_info "Instalando paquetes base..."
apt install -y python3 python3-pip python3-venv git sqlite3 curl wget > /dev/null 2>&1

if ! command -v python3 &> /dev/null; then
    mostrar_error "Python3 no se instaló correctamente"
    exit 1
fi

mostrar_exito "Dependencias del sistema instaladas"

# Crear entorno virtual
mostrar_titulo "🐍 CONFIGURANDO ENTORNO PYTHON"
mostrar_info "Creando entorno virtual..."
python3 -m venv /root/bot_venv

if [ ! -d "/root/bot_venv" ]; then
    mostrar_error "No se pudo crear el entorno virtual"
    exit 1
fi

source /root/bot_venv/bin/activate
mostrar_exito "Entorno virtual creado"

# Instalar dependencias de Python
mostrar_info "Instalando librerías Python..."
pip install --upgrade pip > /dev/null 2>&1
pip install "python-telegram-bot[job-queue]" requests python-dotenv mercadopago paramiko qrcode[pil] pillow > /dev/null 2>&1

mostrar_exito "Librerías Python instaladas"

# Crear archivos de configuración
mostrar_titulo "📝 CREANDO ARCHIVOS DE CONFIGURACIÓN"

cat > /root/config_servers.json <<CONFIGJSON
{
    "TELEGRAM_TOKEN": "$TELEGRAM_TOKEN",
    "ADMINS": [$ADMIN_ID],
    "SOPORTE_USER": "$SOPORTE_USER",
    "DB_FILE": "/root/bot_sshplus.db",
    "PRECIO_30_DIAS": $PRECIO_30_DIAS,
    "PRECIO_15_DIAS": $PRECIO_15_DIAS,
    "PRECIO_7_DIAS": $PRECIO_7_DIAS,
    "MERCADOPAGO_ACCESS_TOKEN": "$MERCADOPAGO_TOKEN",
    "SERVERS": [
$SERVERS_CONFIG
    ]
}
CONFIGJSON

cat > /root/.env_bot_superc4mpeon <<ENVFILE
TELEGRAM_TOKEN=$TELEGRAM_TOKEN
MERCADOPAGO_ACCESS_TOKEN=$MERCADOPAGO_TOKEN
ENVFILE

mostrar_exito "Archivos de configuración creados"

# Buscar APK
APK_FILE=$(find /root -name "*.apk" -type f 2>/dev/null | head -n1)
if [ -n "$APK_FILE" ]; then
    mostrar_exito "APK encontrado: $(basename "$APK_FILE")"
else
    mostrar_advertencia "No se encontró archivo APK en /root"
fi

# Crear el bot con TODAS las funcionalidades
mostrar_titulo "🤖 CREANDO BOT COMPLETO"

cat > /root/bot_definitivo.py <<'PYTHONBOT'
import logging
import sqlite3
import random
import os
import json
import asyncio
import io
from datetime import datetime, timedelta
import paramiko
import requests
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes, MessageHandler, filters, ConversationHandler
from telegram.error import BadRequest
import mercadopago
import qrcode
import signal
import sys

# Estados para conversaciones
ESPERANDO_SERVER_NOMBRE, ESPERANDO_SERVER_IP, ESPERANDO_SERVER_USER, ESPERANDO_SERVER_PASS, ESPERANDO_SERVER_PORT = range(5)

# Configuración
try:
    with open('/root/config_servers.json', 'r') as f:
        CONFIG = json.load(f)
    print("✅ Configuración cargada correctamente")
except Exception as e:
    print(f"❌ Error cargando configuración: {e}")
    exit(1)

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

def signal_handler(signum, frame):
    logger.info("🔒 Cerrando bot limpiamente...")
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)

# ========== FUNCIONES AUXILIARES ==========
def generar_contraseña_segura():
    caracteres_seguros = "abcdeghkmnpqrstuvxyz23456789"
    longitud = random.randint(4, 8)
    contraseña = [
        random.choice("ABCDEFGHKMNPQRSTUVXYZ"),
        random.choice("23456789"),
    ]
    for _ in range(longitud - 2):
        contraseña.append(random.choice(caracteres_seguros))
    random.shuffle(contraseña)
    return ''.join(contraseña)

def guardar_config():
    """Guarda la configuración actualizada en el archivo JSON"""
    try:
        with open('/root/config_servers.json', 'w') as f:
            json.dump(CONFIG, f, indent=4)
        return True
    except Exception as e:
        logger.error(f"❌ Error guardando config: {e}")
        return False

def get_next_server_id():
    """Obtiene el siguiente ID disponible para servidor"""
    if not CONFIG['SERVERS']:
        return 0
    return max(srv['id'] for srv in CONFIG['SERVERS']) + 1

# ========== BASE DE DATOS ==========
def init_db():
    try:
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                telegram_id INTEGER,
                username TEXT,
                ssh_user TEXT UNIQUE,
                ssh_pass TEXT,
                server_id INTEGER,
                dias INTEGER,
                tipo TEXT,
                expires_at DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                telegram_id INTEGER,
                server_id INTEGER,
                external_reference TEXT UNIQUE,
                status TEXT,
                amount REAL,
                dias INTEGER,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_limits (
                telegram_id INTEGER PRIMARY KEY,
                last_test_date TEXT,
                test_count INTEGER DEFAULT 0
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("✅ Base de datos inicializada")
        return True
    except Exception as e:
        logger.error(f"❌ Error inicializando BD: {e}")
        return False

# ========== SSH ==========
def test_conexion_ssh(server_id):
    try:
        server = None
        for srv in CONFIG['SERVERS']:
            if srv['id'] == server_id and srv.get('enabled', True):
                server = srv
                break
        
        if not server:
            return False
            
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            server['host'],
            port=server['port'],
            username=server['username'],
            password=server['password'],
            timeout=10
        )
        ssh.close()
        return True
    except Exception as e:
        logger.error(f"❌ Error SSH server {server_id}: {e}")
        return False

def crear_usuario_vps(server_id, usuario, senha, dias, tipo):
    try:
        server = None
        for srv in CONFIG['SERVERS']:
            if srv['id'] == server_id and srv.get('enabled', True):
                server = srv
                break
        
        if not server:
            return False
            
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            server['host'],
            port=server['port'],
            username=server['username'],
            password=server['password']
        )
        
        if tipo == "test":
            expires_minutes = 1500
            comando = f"useradd -M -N -s /bin/false {usuario} && echo '{usuario}:{senha}' | chpasswd && usermod -e $(date -d '{expires_minutes} minutes' +%Y-%m-%d) {usuario}"
        else:
            expires_days = dias
            comando = f"useradd -M -N -s /bin/false {usuario} && echo '{usuario}:{senha}' | chpasswd && usermod -e $(date -d '{expires_days} days' +%Y-%m-%d) {usuario}"
        
        stdin, stdout, stderr = ssh.exec_command(comando)
        exit_status = stdout.channel.recv_exit_status()
        ssh.close()
        
        if exit_status == 0:
            logger.info(f"✅ Usuario {usuario} creado - Tipo: {tipo} - Duración: {dias if tipo == 'premium' else '6 horas'}")
            return True
        else:
            error_msg = stderr.read().decode()
            logger.error(f"❌ Error creando usuario: {error_msg}")
            return False
            
    except Exception as e:
        logger.error(f"❌ Error SSH: {e}")
        return False

# ========== AUXILIARES ==========
def is_admin(user_id):
    return user_id in CONFIG['ADMINS']

def get_servers_activos():
    return [srv for srv in CONFIG['SERVERS'] if srv.get('enabled', True)]

async def safe_answer_callback(query):
    try:
        await query.answer()
        return True
    except BadRequest as e:
        if "query is too old" in str(e).lower():
            return False
        raise e

# ========== MERCADOPAGO ==========
async def generar_pago_mercadopago(server_id, user_id, server_name, dias, precio):
    try:
        if not CONFIG.get('MERCADOPAGO_ACCESS_TOKEN'):
            return {'success': False, 'error': 'Token de MercadoPago no configurado'}
            
        sdk = mercadopago.SDK(CONFIG['MERCADOPAGO_ACCESS_TOKEN'])
        external_ref = f"premium_{server_id}_{user_id}_{dias}dias_{random.randint(100,999)}"
        
        preference_data = {
            "items": [{
                "title": f"VPS PREMIUM {dias} DÍAS - {server_name}",
                "quantity": 1,
                "currency_id": "ARS",
                "unit_price": precio
            }],
            "external_reference": external_ref,
            "back_urls": {
                "success": f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}",
                "failure": f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}",
                "pending": f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}"
            },
            "auto_return": "approved"
        }
        
        preference = sdk.preference().create(preference_data)
        
        if preference["status"] in [200, 201]:
            conn = sqlite3.connect(CONFIG['DB_FILE'])
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO payments (telegram_id, server_id, external_reference, status, amount, dias)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (user_id, server_id, external_ref, 'pending', precio, dias))
            conn.commit()
            conn.close()
            
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_L, box_size=10, border=4)
            qr.add_data(preference["response"]["init_point"])
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            img_bytes = io.BytesIO()
            img.save(img_bytes, format='PNG')
            img_bytes.seek(0)
            
            return {
                'success': True,
                'init_point': preference["response"]["init_point"],
                'external_reference': external_ref,
                'qr_image': img_bytes
            }
        else:
            return {'success': False, 'error': 'Error creando preferencia'}
            
    except Exception as e:
        logger.error(f"❌ Error MercadoPago: {e}")
        return {'success': False, 'error': str(e)}

# ========== HANDLERS PRINCIPALES ==========
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    logger.info(f"👤 Usuario {user_id} inició el bot")
    
    keyboard = [
        [InlineKeyboardButton("🎁 DEMO GRATIS", callback_data='test_gratis')],
        [InlineKeyboardButton("💎 COMPRAR PREMIUM", callback_data='comprar_premium')],
        [InlineKeyboardButton("📱 MIS CUENTAS", callback_data='mis_cuentas')],
        [InlineKeyboardButton("📲 DESCARGAR APP", callback_data='descargar_app')],
        [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")]
    ]
    
    if is_admin(user_id):
        keyboard.append([InlineKeyboardButton("⚙️ ADMIN", callback_data='admin_panel')])
    
    await update.message.reply_text(
        "🤖 *BOT VPN SUPERC4MPEON*\n\nElegir una opción:",
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode='Markdown'
    )

async def menu_principal(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    user_id = query.from_user.id
    
    keyboard = [
        [InlineKeyboardButton("🎁 DEMO GRATIS", callback_data='test_gratis')],
        [InlineKeyboardButton("💎 COMPRAR PREMIUM", callback_data='comprar_premium')],
        [InlineKeyboardButton("📱 MIS CUENTAS", callback_data='mis_cuentas')],
        [InlineKeyboardButton("📲 DESCARGAR APP", callback_data='descargar_app')],
        [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")]
    ]
    
    if is_admin(user_id):
        keyboard.append([InlineKeyboardButton("⚙️ ADMIN", callback_data='admin_panel')])
    
    await query.edit_message_text(
        "🤖 *BOT VPN SUPERC4MPEON*\n\nElegir una opción:",
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode='Markdown'
    )

async def test_gratis(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    user_id = query.from_user.id
    
    if not is_admin(user_id):
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        hoy = datetime.now().date().isoformat()
        
        cursor.execute('SELECT last_test_date, test_count FROM user_limits WHERE telegram_id = ?', (user_id,))
        result = cursor.fetchone()
        
        if result:
            last_date, test_count = result
            if last_date == hoy and test_count >= 1:
                conn.close()
                mensaje = "❌ Ya usaste tu DEMO gratuito hoy. Vuelve mañana."
                keyboard = [
                    [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                    [InlineKeyboardButton("🔙 VOLVER", callback_data='menu_principal')]
                ]
                await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')
                return
        conn.close()
    
    keyboard = []
    servers_activos = get_servers_activos()
    
    for server in servers_activos:
        status = "✅" if test_conexion_ssh(server['id']) else "❌"
        keyboard.append([InlineKeyboardButton(f"🖥️ {server['name']} {status}", callback_data=f'test_server_{server["id"]}')])
    
    keyboard.append([InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")])
    keyboard.append([InlineKeyboardButton("🔙 VOLVER", callback_data='menu_principal')])
    
    await query.edit_message_text(
        "🎁 DEMO GRATIS (6 horas)\nSelecciona servidor:", 
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def create_test_user(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    try:
        await query.answer("🔄 Creando usuario...")
    except BadRequest as e:
        if "query is too old" in str(e).lower():
            return
        raise e
    
    try:
        if not query.data.startswith('test_server_'):
            return
            
        parts = query.data.split('_')
        if len(parts) != 3:
            return
            
        server_id = int(parts[2])
        user_id = query.from_user.id
        
        if not test_conexion_ssh(server_id):
            mensaje_error = "❌ Servidor no disponible. Intenta otro."
            keyboard = [
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔙 VOLVER", callback_data='test_gratis')]
            ]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            return
        
        usuario = f"test{random.randint(10,999)}"
        senha = generar_contraseña_segura()
        
        success = crear_usuario_vps(server_id, usuario, senha, 0, "test")
        
        if success:
            conn = sqlite3.connect(CONFIG['DB_FILE'])
            cursor = conn.cursor()
            
            expires_at_db = datetime.now() + timedelta(hours=3)
            
            cursor.execute('''
                INSERT INTO users (telegram_id, username, ssh_user, ssh_pass, server_id, dias, expires_at, tipo) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (user_id, f"user_{user_id}", usuario, senha, server_id, 0, expires_at_db, "test"))
            
            if not is_admin(user_id):
                hoy = datetime.now().date().isoformat()
                cursor.execute('''
                    INSERT OR REPLACE INTO user_limits (telegram_id, last_test_date, test_count) 
                    VALUES (?, ?, 1)
                ''', (user_id, hoy))
            
            conn.commit()
            conn.close()
            
            server_name = f"Server {server_id}"
            for srv in CONFIG['SERVERS']:
                if srv['id'] == server_id:
                    server_name = srv['name']
                    break
            
            mensaje = f"""✅ USUARIO DEMO CREADO

🖥️ Servidor: {server_name} \n
👤APP  Usuario: `{usuario}` \n
🔑 APP Contraseña: `{senha}`  \n
⏰ Expira: 6 horas
📅 Creado: {datetime.now().strftime('%H:%M %d/%m')}
⏳ Vence: {expires_at_db.strftime('%H:%M %d/%m')}

¡Listo! 🎉"""
            
            keyboard = [
                [InlineKeyboardButton("💎 COMPRAR PREMIUM", callback_data='comprar_premium')],
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🏠 MENÚ", callback_data='menu_principal')]
            ]
            await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')
        else:
            mensaje_error = "❌ Error creando usuario. Intenta otro servidor."
            keyboard = [
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔙 VOLVER", callback_data='test_gratis')]
            ]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            
    except Exception as e:
        logger.error(f"❌ Error en create_test_user: {e}")
        mensaje_error = f"❌ Error. Contacta a {CONFIG.get('SOPORTE_USER', '@superc4mpeon')}"
        keyboard = [
            [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
            [InlineKeyboardButton("🔙 VOLVER", callback_data='test_gratis')]
        ]
        await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))

async def comprar_premium(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    keyboard = [
        [InlineKeyboardButton("💎 30 DIAS", callback_data='premium_30_dias')],
        [InlineKeyboardButton("🔶 15 DIAS", callback_data='premium_15_dias')],
        [InlineKeyboardButton("🔷 7 DIAS", callback_data='premium_7_dias')],
        [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
        [InlineKeyboardButton("🔙 VOLVER", callback_data='menu_principal')]
    ]
    
    mensaje = f"""💎 COMPRAR PREMIUM

Selecciona la duración:

💎 *30 DIAS*
💰 Precio: ${CONFIG['PRECIO_30_DIAS']} ARS
✅ Acceso completo
✅ Un dispositivo

🔶 *15 DÍAS*  
💰 Precio: ${CONFIG['PRECIO_15_DIAS']} ARS
✅ Acceso completo
✅ Un Dispositivo

🔷 *7 DÍAS*
💰 Precio: ${CONFIG['PRECIO_7_DIAS']} ARS
✅ Acceso completo
✅ un dispositivo

Selecciona una opción:"""
    
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')

async def premium_seleccion_duracion(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    duracion_map = {
        'premium_30_dias': {'dias': 30, 'precio': CONFIG['PRECIO_30_DIAS'], 'emoji': '💎'},
        'premium_15_dias': {'dias': 15, 'precio': CONFIG['PRECIO_15_DIAS'], 'emoji': '🔶'},
        'premium_7_dias': {'dias': 7, 'precio': CONFIG['PRECIO_7_DIAS'], 'emoji': '🔷'}
    }
    
    callback_data = query.data
    if callback_data not in duracion_map:
        return
    
    duracion_info = duracion_map[callback_data]
    context.user_data['selected_duracion'] = duracion_info
    
    keyboard = []
    servers_activos = get_servers_activos()
    
    for server in servers_activos:
        status = "✅" if test_conexion_ssh(server['id']) else "❌"
        keyboard.append([InlineKeyboardButton(f"🖥️ {server['name']} {status}", callback_data=f'premium_server_{server["id"]}')])
    
    keyboard.append([InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")])
    keyboard.append([InlineKeyboardButton("🔙 VOLVER", callback_data='comprar_premium')])
    
    mensaje = f"""{duracion_info['emoji']} PREMIUM {duracion_info['dias']} DÍAS

💰 Precio: ${duracion_info['precio']} ARS
⏰ Duración: {duracion_info['dias']} días
✅ Acceso completo
✅ Un Dispositivo
✅ Activación automática

Selecciona servidor:"""
    
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))

async def premium_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    try:
        await query.answer("💳 Generando pago y QR...")
    except BadRequest as e:
        if "query is too old" in str(e).lower():
            return
        raise e
    
    try:
        if not query.data.startswith('premium_server_'):
            return
            
        parts = query.data.split('_')
        if len(parts) != 3:
            return
            
        server_id = int(parts[2])
        user_id = query.from_user.id
        
        duracion_info = context.user_data.get('selected_duracion')
        if not duracion_info:
            await query.edit_message_text("❌ Error: No se seleccionó duración")
            return
        
        dias = duracion_info['dias']
        precio = duracion_info['precio']
        emoji = duracion_info['emoji']
        
        server_name = f"Server {server_id}"
        for srv in CONFIG['SERVERS']:
            if srv['id'] == server_id:
                server_name = srv['name']
                break
        
        if not test_conexion_ssh(server_id):
            error_msg = "❌ Servidor no disponible."
            keyboard = [
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔙 VOLVER", callback_data='comprar_premium')]
            ]
            await query.edit_message_text(error_msg, reply_markup=InlineKeyboardMarkup(keyboard))
            return
        
        await query.edit_message_text("🔄 Generando pago y QR...")
        
        pago_result = await generar_pago_mercadopago(server_id, user_id, server_name, dias, precio)
        
        if pago_result['success']:
            link_pago = pago_result['init_point']
            
            mensaje_link = f"""{emoji} PAGO PREMIUM {dias} DÍAS - {server_name}

💰 Precio: ${precio} ARS
⏰ Duración: {dias} días
🖥️ Servidor: {server_name}

🔗 LINK DE PAGO:
{link_pago}

🔄 Verificación automática cada 2 minutos
✅ Credenciales automáticas al aprobarse

💬 Problemas: {CONFIG.get('SOPORTE_USER', '@superc4mpeon')}"""
            
            keyboard = [
                [InlineKeyboardButton("🔗 PAGAR AHORA", url=link_pago)],
                [InlineKeyboardButton("💬 SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🏠 MENÚ", callback_data='menu_principal')]
            ]
            
            await query.edit_message_text(mensaje_link, reply_markup=InlineKeyboardMarkup(keyboard))
            
            if pago_result.get('qr_image'):
                try:
                    await context.bot.send_photo(
                        chat_id=user_id,
                        photo=pago_result['qr_image'],
                        caption="📱 Escanea el QR con MercadoPago"
                    )
                except Exception as e:
                    logger.error(f"❌ Error enviando QR: {e}")
            
        else:
            error_msg = f"❌ Error: {pago_result.get('error', 'Error generando pago')}"
            keyboard = [
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔙 VOLVER", callback_data='comprar_premium')]
            ]
            await query.edit_message_text(error_msg, reply_markup=InlineKeyboardMarkup(keyboard))
            
    except Exception as e:
        logger.error(f"❌ Error en premium_server: {e}")
        error_msg = "❌ Error generando pago."
        keyboard = [
            [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
            [InlineKeyboardButton("🔙 VOLVER", callback_data='comprar_premium')]
        ]
        await query.edit_message_text(error_msg, reply_markup=InlineKeyboardMarkup(keyboard))

async def mis_cuentas(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    user_id = query.from_user.id
    
    try:
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT ssh_user, ssh_pass, tipo, server_id, expires_at, dias 
            FROM users 
            WHERE telegram_id = ? 
            ORDER BY created_at DESC
        ''', (user_id,))
        
        cuentas = cursor.fetchall()
        conn.close()
        
        if not cuentas:
            mensaje = "📭 No tienes cuentas activas.\n\n¡Crea tu primera cuenta con DEMO GRATIS! 🎁"
            keyboard = [
                [InlineKeyboardButton("🎁 DEMO GRATIS", callback_data='test_gratis')],
                [InlineKeyboardButton("💎 COMPRAR PREMIUM", callback_data='comprar_premium')],
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔙 MENÚ", callback_data='menu_principal')]
            ]
        else:
            mensaje = "📱 *TUS CUENTAS ACTIVAS*\n\n"
            
            for i, (ssh_user, ssh_pass, tipo, server_id, expires_at, dias_usuario) in enumerate(cuentas, 1):
                server_name = f"Server {server_id}"
                for srv in CONFIG['SERVERS']:
                    if srv['id'] == server_id:
                        server_name = srv['name']
                        break
                
                if tipo == "premium":
                    tipo_emoji = "💎"
                    tipo_texto = f"PREMIUM {dias_usuario} DÍAS"
                else:
                    tipo_emoji = "🎁"
                    tipo_texto = "TEST"
                
                estado = "✅ ACTIVA"
                tiempo_restante = ""
                
                if expires_at:
                    try:
                        if '.' in str(expires_at):
                            expires_clean = expires_at.split('.')[0]
                        else:
                            expires_clean = expires_at
                            
                        fecha_expiracion = datetime.strptime(expires_clean, '%Y-%m-%d %H:%M:%S')
                        ahora = datetime.now()
                        
                        if ahora > fecha_expiracion:
                            estado = "❌ EXPIRADA"
                        else:
                            diferencia = fecha_expiracion - ahora
                            dias = diferencia.days
                            horas = diferencia.seconds // 3600
                            minutos = (diferencia.seconds % 3600) // 60
                            
                            if dias > 0:
                                tiempo_restante = f" ({dias}d {horas}h)"
                            elif horas > 0:
                                tiempo_restante = f" ({horas}h {minutos}m)"
                            else:
                                tiempo_restante = f" ({minutos}m)"
                    except Exception as e:
                        estado = "⚠️ ERROR"
                
                mensaje += f"{tipo_emoji} *Cuenta {i}:* {tipo_texto}\n"
                mensaje += f"🖥️ *Servidor:* {server_name}\n"
                mensaje += f"👤 *App_Usuario:* `{ssh_user}`\n"
                mensaje += f"🔑 *App_Contraseña:* `{ssh_pass}`\n"
                mensaje += f"⏰ *Estado:* {estado}{tiempo_restante}\n"
                
                if expires_at:
                    try:
                        fecha_limpia = expires_at.split('.')[0] if '.' in str(expires_at) else expires_at
                        fecha_formateada = datetime.strptime(fecha_limpia, '%Y-%m-%d %H:%M:%S').strftime('%d/%m/%Y %H:%M')
                        mensaje += f"📅 *Expira:* {fecha_formateada}\n"
                    except:
                        mensaje += f"📅 *Expira:* {expires_at}\n"
                
                mensaje += "━━━━━━━━━━━━━━━━━━━━\n\n"
            
            mensaje += "\n💡 *Consejo:* Copia y guarda tus credenciales en un lugar seguro."
            
            keyboard = [
                [InlineKeyboardButton("🎁 NUEVO DEMO", callback_data='test_gratis')],
                [InlineKeyboardButton("💎 COMPRAR PREMIUM", callback_data='comprar_premium')],
                [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
                [InlineKeyboardButton("🔄 ACTUALIZAR", callback_data='mis_cuentas')],
                [InlineKeyboardButton("🔙 MENÚ", callback_data='menu_principal')]
            ]
        
        await query.edit_message_text(
            mensaje,
            reply_markup=InlineKeyboardMarkup(keyboard),
            parse_mode='Markdown'
        )
        
    except Exception as e:
        logger.error(f"❌ Error en mis_cuentas: {e}")
        mensaje_error = "❌ Error al cargar tus cuentas. Intenta nuevamente."
        keyboard = [
            [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
            [InlineKeyboardButton("🔙 VOLVER", callback_data='menu_principal')]
        ]
        await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))

async def descargar_app(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    apk_files = [f for f in os.listdir('/root') if f.lower().endswith('.apk')]
    
    if apk_files:
        apk_path = f"/root/{apk_files[0]}"
        try:
            with open(apk_path, 'rb') as apk_file:
                await context.bot.send_document(
                    chat_id=query.from_user.id, 
                    document=apk_file, 
                    filename=apk_files[0],
                    caption=f'📱 {apk_files[0]} - Descarga e instala'
                )
            mensaje = f"✅ {apk_files[0]} enviado a tu chat privado!"
        except Exception as e:
            mensaje = f"❌ Error enviando APK: {e}"
    else:
        mensaje = f"❌ No se encontró archivo APK. Contacta a {CONFIG.get('SOPORTE_USER', '@superc4mpeon')}"
    
    keyboard = [
        [InlineKeyboardButton("📞 CONTACTAR SOPORTE", url=f"https://t.me/{CONFIG.get('SOPORTE_USER', 'superc4mpeon').replace('@', '')}")],
        [InlineKeyboardButton("🔙 VOLVER", callback_data='menu_principal')]
    ]
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))

# ========== TAREAS AUTOMÁTICAS ==========
async def verificar_pagos_automaticamente(context: ContextTypes.DEFAULT_TYPE):
    try:
        logger.info("🔄 Verificando pagos pendientes...")
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute('SELECT telegram_id, server_id, external_reference, dias FROM payments WHERE status = "pending"')
        pagos_pendientes = cursor.fetchall()
        
        for telegram_id, server_id, external_ref, dias_pago in pagos_pendientes:
            try:
                if not CONFIG.get('MERCADOPAGO_ACCESS_TOKEN'):
                    continue
                    
                url = f"https://api.mercadopago.com/v1/payments/search?external_reference={external_ref}"
                headers = {"Authorization": f"Bearer {CONFIG['MERCADOPAGO_ACCESS_TOKEN']}"}
                
                response = requests.get(url, headers=headers, timeout=15)
                if response.status_code == 200:
                    data = response.json()
                    
                    if data['results']:
                        pago = data['results'][0]
                        status = pago['status']
                        
                        if status == 'approved':
                            usuario = f"premium{random.randint(100, 9999)}"
                            senha = generar_contraseña_segura()
                            
                            success = crear_usuario_vps(server_id, usuario, senha, dias_pago, "premium")
                            
                            if success:
                                expires_at = datetime.now() + timedelta(days=dias_pago)
                                cursor.execute('''
                                    INSERT INTO users (telegram_id, username, ssh_user, ssh_pass, server_id, dias, expires_at, tipo) 
                                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                                ''', (telegram_id, f"premium_user_{telegram_id}", usuario, senha, server_id, dias_pago, expires_at, "premium"))
                                
                                cursor.execute('UPDATE payments SET status = ? WHERE external_reference = ?', ('approved', external_ref))
                                conn.commit()
                                
                                server_name = f"Server {server_id}"
                                for srv in CONFIG['SERVERS']:
                                    if srv['id'] == server_id:
                                        server_name = srv['name']
                                        break
                                
                                mensaje = f"""🎉 PAGO APROBADO - USUARIO PREMIUM CREADO

✅ Tu pago ha sido verificado
🖥️ Servidor: {server_name} \n
👤 APP Usuario:   `{usuario}` \n
🔑 APP Contraseña:   `{senha}`\n
⏰ Duración: {dias_pago} días \n
📅 Expira: {expires_at.strftime('%d/%m/%Y')}

¡DisfrutE! 🚀"""
                                
                                try:
                                    await context.bot.send_message(
                                        chat_id=telegram_id,
                                        text=mensaje,
                                        parse_mode='Markdown'
                                    )
                                except Exception as e:
                                    logger.error(f"❌ Error enviando mensaje: {e}")
            except Exception as e:
                logger.error(f"❌ Error procesando pago {external_ref}: {e}")
                continue
        
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Error en verificación de pagos: {e}")

async def limpiar_usuarios_test_expirados(context: ContextTypes.DEFAULT_TYPE):
    try:
        logger.info("🧹 Limpiando usuarios test expirados...")
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute("DELETE FROM users WHERE tipo = 'test' AND expires_at < datetime('now')")
        eliminados = cursor.rowcount
        
        if eliminados > 0:
            logger.info(f"✅ Usuarios test eliminados: {eliminados}")
        
        conn.commit()
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Error limpiando usuarios: {e}")

# ========== PANEL ADMIN ==========
async def admin_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ No tienes permisos.")
        return
    
    keyboard = [
        [InlineKeyboardButton("📊 ESTADISTICAS", callback_data='admin_stats')],
        [InlineKeyboardButton("👥 LISTAR USUARIOS", callback_data='admin_list_users')],
        [InlineKeyboardButton("🖥️ GESTIONAR SERVIDORES", callback_data='admin_servers')],
        [InlineKeyboardButton("👤 CREAR USUARIO", callback_data='admin_create_user')],
        [InlineKeyboardButton("🔙 MENÚ", callback_data='menu_principal')]
    ]
    
    await update.message.reply_text("⚙️ PANEL ADMIN", reply_markup=InlineKeyboardMarkup(keyboard))

async def admin_panel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    if not is_admin(query.from_user.id):
        await query.edit_message_text("❌ No tienes permisos.")
        return
    
    keyboard = [
        [InlineKeyboardButton("📊 ESTADISTICAS", callback_data='admin_stats')],
        [InlineKeyboardButton("👥 LISTAR USUARIOS", callback_data='admin_list_users')],
        [InlineKeyboardButton("🖥️ GESTIONAR SERVIDORES", callback_data='admin_servers')],
        [InlineKeyboardButton("👤 CREAR USUARIO", callback_data='admin_create_user')],
        [InlineKeyboardButton("🔙 MENÚ", callback_data='menu_principal')]
    ]
    
    await query.edit_message_text("⚙️ PANEL ADMIN", reply_markup=InlineKeyboardMarkup(keyboard))

async def admin_stats(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    try:
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute('SELECT COUNT(*) FROM users')
        total = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM users WHERE tipo = "premium"')
        premium = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM users WHERE tipo = "test"')
        tests = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM payments WHERE status = "approved"')
        pagos = cursor.fetchone()[0]
        
        cursor.execute('SELECT SUM(amount) FROM payments WHERE status = "approved"')
        ganancias = cursor.fetchone()[0] or 0
        
        cursor.execute('SELECT COUNT(*) FROM payments WHERE status = "pending"')
        pendientes = cursor.fetchone()[0]
        
        conn.close()
        
        mensaje = f"""📊 ESTADISTICAS

👥 Total usuarios: {total}
💎 Premium: {premium}
🎁 Tests: {tests}
✅ Pagos aprobados: {pagos}
⏳ Pagos pendientes: {pendientes}
💰 Ganancias Aprox: ${ganancias:.2f} ARS

🖥️ Servidores activos: {len(get_servers_activos())}"""
        
        keyboard = [[InlineKeyboardButton("🔙 ADMIN", callback_data='admin_panel')]]
        await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))
        
    except Exception as e:
        logger.error(f"❌ Error en admin_stats: {e}")

async def admin_list_users(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    try:
        conn = sqlite3.connect(CONFIG['DB_FILE'])
        cursor = conn.cursor()
        
        cursor.execute("SELECT ssh_user, ssh_pass, tipo, server_id, expires_at, dias FROM users ORDER BY created_at DESC LIMIT 40")
        users = cursor.fetchall()
        conn.close()
        
        if not users:
            mensaje = "📭 No hay usuarios."
        else:
            mensaje = "👥 ÚLTIMOS 40 USUARIOS:\n\n"
            for ssh_user, ssh_pass, tipo, server_id, expires_at, dias in users:
                tipo_emoji = "💎" if tipo == "premium" else "🎁"
                tipo_texto = f"{tipo_emoji} {tipo.upper()}" + (f" {dias}D" if tipo == "premium" else "")
                
                server_name = f"Server {server_id}"
                for srv in CONFIG['SERVERS']:
                    if srv['id'] == server_id:
                        server_name = srv['name']
                        break
                
                estado = "✅ ACTIVO"
                if expires_at:
                    try:
                        if '.' in str(expires_at):
                            expires_clean = expires_at.split('.')[0]
                        else:
                            expires_clean = expires_at
                            
                        expirado = datetime.now() > datetime.strptime(expires_clean, '%Y-%m-%d %H:%M:%S')
                        if expirado:
                            estado = "❌ EXPIRADO"
                    except:
                        estado = "⚠️ ERROR"
                
                mensaje += f"{tipo_texto} | {ssh_user} | {ssh_pass}  | {estado}\n"
    
        keyboard = [[InlineKeyboardButton("🔙 ADMIN", callback_data='admin_panel')]]
        await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))
        
    except Exception as e:
        logger.error(f"❌ Error en admin_list_users: {e}")

# ========== GESTIÓN DE SERVIDORES ==========
async def admin_servers(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    if not is_admin(query.from_user.id):
        await query.edit_message_text("❌ No tienes permisos.")
        return
    
    keyboard = [
        [InlineKeyboardButton("➕ AGREGAR SERVIDOR", callback_data='admin_add_server')],
        [InlineKeyboardButton("🗑️ ELIMINAR SERVIDOR", callback_data='admin_delete_server')],
        [InlineKeyboardButton("📊 VER ESTADO", callback_data='admin_servers_status')],
        [InlineKeyboardButton("🔄 HABILITAR/DESHABILITAR", callback_data='admin_toggle_server')],
        [InlineKeyboardButton("🔙 ADMIN", callback_data='admin_panel')]
    ]
    
    await query.edit_message_text(
        "🖥️ GESTIÓN DE SERVIDORES\n\nSelecciona una opción:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def admin_servers_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    servidores_info = ""
    
    for server in CONFIG['SERVERS']:
        enabled_status = "🟢" if server.get('enabled', True) else "🔴"
        status = "✅ EN LÍNEA" if test_conexion_ssh(server['id']) else "❌ FUERA DE LÍNEA"
        servidores_info += f"{enabled_status} {server['name']} - {status}\n"
        servidores_info += f"📍 {server['host']}:{server['port']}\n"
        servidores_info += f"👤 {server['username']} | ID: {server['id']}\n\n"
    
    mensaje = f"""🖥️ ESTADO DE SERVIDORES

{servidores_info if servidores_info else '❌ No hay servidores configurados'}

🟢 = Habilitado | 🔴 = Deshabilitado"""
    
    keyboard = [[InlineKeyboardButton("🔙 GESTIÓN SERVIDORES", callback_data='admin_servers')]]
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))

# ========== AGREGAR SERVIDOR ==========
async def admin_add_server_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    context.user_data['adding_server'] = {}
    context.user_data['server_step'] = 'nombre'
    
    await query.edit_message_text(
        "➕ AGREGAR NUEVO SERVIDOR\n\n📝 Escribe el *nombre* del servidor:\n\n(Envía /cancelar para cancelar)",
        parse_mode='Markdown'
    )
    return ESPERANDO_SERVER_NOMBRE

async def recibir_server_nombre(update: Update, context: ContextTypes.DEFAULT_TYPE):
    nombre = update.message.text.strip()
    context.user_data['adding_server']['name'] = nombre
    context.user_data['server_step'] = 'ip'
    
    await update.message.reply_text(
        f"✅ Nombre: *{nombre}*\n\n🌐 Ahora escribe la *IP* del servidor:\n\n(Envía /cancelar para cancelar)",
        parse_mode='Markdown'
    )
    return ESPERANDO_SERVER_IP

async def recibir_server_ip(update: Update, context: ContextTypes.DEFAULT_TYPE):
    ip = update.message.text.strip()
    
    # Validar formato IP
    import re
    if not re.match(r'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$', ip):
        await update.message.reply_text("❌ IP inválida. Escribe una IP válida (ej: 192.168.1.1):")
        return ESPERANDO_SERVER_IP
    
    context.user_data['adding_server']['host'] = ip
    context.user_data['server_step'] = 'user'
    
    await update.message.reply_text(
        f"✅ IP: *{ip}*\n\n👤 Ahora escribe el *usuario SSH* [root]:\n\n(Envía /cancelar para cancelar)",
        parse_mode='Markdown'
    )
    return ESPERANDO_SERVER_USER

async def recibir_server_user(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.message.text.strip() or 'root'
    context.user_data['adding_server']['username'] = user
    context.user_data['server_step'] = 'pass'
    
    await update.message.reply_text(
        f"✅ Usuario: *{user}*\n\n🔒 Ahora escribe la *contraseña SSH*:\n\n(Envía /cancelar para cancelar)",
        parse_mode='Markdown'
    )
    return ESPERANDO_SERVER_PASS

async def recibir_server_pass(update: Update, context: ContextTypes.DEFAULT_TYPE):
    password = update.message.text.strip()
    context.user_data['adding_server']['password'] = password
    context.user_data['server_step'] = 'port'
    
    await update.message.reply_text(
        "✅ Contraseña guardada\n\n🚪 Ahora escribe el *puerto SSH* [22]:\n\n(Envía /cancelar para cancelar)",
        parse_mode='Markdown'
    )
    return ESPERANDO_SERVER_PORT

async def recibir_server_port(update: Update, context: ContextTypes.DEFAULT_TYPE):
    port = update.message.text.strip() or '22'
    
    # Validar que sea número
    if not port.isdigit():
        await update.message.reply_text("❌ Puerto inválido. Escribe un número (ej: 22):")
        return ESPERANDO_SERVER_PORT
    
    port = int(port)
    
    # Crear el nuevo servidor
    new_server = {
        'id': get_next_server_id(),
        'name': context.user_data['adding_server']['name'],
        'host': context.user_data['adding_server']['host'],
        'port': port,
        'username': context.user_data['adding_server']['username'],
        'password': context.user_data['adding_server']['password'],
        'enabled': True
    }
    
    # Probar conexión
    await update.message.reply_text("🔄 Probando conexión SSH...")
    
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            new_server['host'],
            port=new_server['port'],
            username=new_server['username'],
            password=new_server['password'],
            timeout=10
        )
        ssh.close()
        conexion_ok = True
    except Exception as e:
        conexion_ok = False
        error_msg = str(e)
    
    if conexion_ok:
        # Agregar a la configuración
        CONFIG['SERVERS'].append(new_server)
        guardar_config()
        
        mensaje = f"""✅ SERVIDOR AGREGADO EXITOSAMENTE

🖥️ Nombre: {new_server['name']}
🌐 IP VPS: {new_server['host']}
🚪 Puerto VPS: {new_server['port']}
👤 Usuario: {new_server['username']}
🆔 ID Alias: {new_server['id']}
✅ Conexión: OK

El servidor ya está disponible para crear usuarios."""
    else:
        mensaje = f"""⚠️ SERVIDOR AGREGADO CON ADVERTENCIA

🖥️ Nombre: {new_server['name']}
🌐 IP: {new_server['host']}
❌ Conexión: FALLÓ

Error: {error_msg}

El servidor se agregó pero NO está accesible.
Verifica las credenciales o el servidor."""
        
        # Agregarlo de todos modos
        CONFIG['SERVERS'].append(new_server)
        guardar_config()
    
    keyboard = [
        [InlineKeyboardButton("➕ AGREGAR OTRO", callback_data='admin_add_server')],
        [InlineKeyboardButton("📊 VER ESTADO", callback_data='admin_servers_status')],
        [InlineKeyboardButton("🔙 GESTIÓN SERVIDORES", callback_data='admin_servers')]
    ]
    
    await update.message.reply_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))
    
    # Limpiar datos temporales
    context.user_data.clear()
    return ConversationHandler.END

async def cancelar_servidor(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data.clear()
    await update.message.reply_text("❌ Operación cancelada.")
    
    keyboard = [[InlineKeyboardButton("🔙 GESTIÓN SERVIDORES", callback_data='admin_servers')]]
    await update.message.reply_text("Volviendo al menú...", reply_markup=InlineKeyboardMarkup(keyboard))
    return ConversationHandler.END

# ========== ELIMINAR SERVIDOR ==========
async def admin_delete_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    if not CONFIG['SERVERS']:
        await query.edit_message_text(
            "❌ No hay servidores para eliminar.",
            reply_markup=InlineKeyboardMarkup([[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_servers')]])
        )
        return
    
    keyboard = []
    for server in CONFIG['SERVERS']:
        keyboard.append([InlineKeyboardButton(
            f"🗑️ {server['name']} (ID: {server['id']})",
            callback_data=f'delete_srv_{server["id"]}'
        )])
    
    keyboard.append([InlineKeyboardButton("🔙 VOLVER", callback_data='admin_servers')])
    
    await query.edit_message_text(
        "🗑️ ELIMINAR SERVIDOR\n\nSelecciona el servidor a eliminar:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def confirmar_delete_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    server_id = int(query.data.split('_')[2])
    
    # Buscar servidor
    server_to_delete = None
    for srv in CONFIG['SERVERS']:
        if srv['id'] == server_id:
            server_to_delete = srv
            break
    
    if not server_to_delete:
        await query.edit_message_text("❌ Servidor no encontrado.")
        return
    
    keyboard = [
        [InlineKeyboardButton("✅ SÍ, ELIMINAR", callback_data=f'confirm_delete_{server_id}')],
        [InlineKeyboardButton("❌ NO, CANCELAR", callback_data='admin_delete_server')]
    ]
    
    await query.edit_message_text(
        f"⚠️ ¿CONFIRMAS ELIMINAR?\n\n🖥️ Servidor: {server_to_delete['name']}\n🌐 IP: {server_to_delete['host']}\n🆔 ID: {server_to_delete['id']}\n\n❌ Esta acción NO se puede deshacer.",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def ejecutar_delete_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    server_id = int(query.data.split('_')[2])
    
    # Eliminar servidor
    server_eliminado = None
    CONFIG['SERVERS'] = [srv for srv in CONFIG['SERVERS'] if srv['id'] != server_id]
    
    # Buscar el eliminado para mostrar info
    for srv in CONFIG['SERVERS']:
        if srv['id'] == server_id:
            server_eliminado = srv
            break
    
    if guardar_config():
        mensaje = f"✅ SERVIDOR ELIMINADO\n\n🖥️ ID: {server_id}\n\nEl servidor ha sido eliminado de la configuración."
    else:
        mensaje = "❌ Error al guardar la configuración."
    
    keyboard = [
        [InlineKeyboardButton("📊 VER SERVIDORES", callback_data='admin_servers_status')],
        [InlineKeyboardButton("🔙 GESTIÓN SERVIDORES", callback_data='admin_servers')]
    ]
    
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))

# ========== HABILITAR/DESHABILITAR SERVIDOR ==========
async def admin_toggle_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    if not CONFIG['SERVERS']:
        await query.edit_message_text(
            "❌ No hay servidores configurados.",
            reply_markup=InlineKeyboardMarkup([[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_servers')]])
        )
        return
    
    keyboard = []
    for server in CONFIG['SERVERS']:
        estado_emoji = "🟢" if server.get('enabled', True) else "🔴"
        accion = "Deshabilitar" if server.get('enabled', True) else "Habilitar"
        keyboard.append([InlineKeyboardButton(
            f"{estado_emoji} {server['name']} - {accion}",
            callback_data=f'toggle_srv_{server["id"]}'
        )])
    
    keyboard.append([InlineKeyboardButton("🔙 VOLVER", callback_data='admin_servers')])
    
    await query.edit_message_text(
        "🔄 HABILITAR/DESHABILITAR SERVIDOR\n\n🟢 = Habilitado | 🔴 = Deshabilitado\n\nSelecciona un servidor:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def ejecutar_toggle_server(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    server_id = int(query.data.split('_')[2])
    
    # Buscar y cambiar estado
    for srv in CONFIG['SERVERS']:
        if srv['id'] == server_id:
            srv['enabled'] = not srv.get('enabled', True)
            nuevo_estado = "🟢 HABILITADO" if srv['enabled'] else "🔴 DESHABILITADO"
            server_name = srv['name']
            break
    
    if guardar_config():
        mensaje = f"✅ ESTADO CAMBIADO\n\n🖥️ Servidor: {server_name}\n{nuevo_estado}"
    else:
        mensaje = "❌ Error al guardar cambios."
    
    keyboard = [
        [InlineKeyboardButton("🔄 CAMBIAR OTRO", callback_data='admin_toggle_server')],
        [InlineKeyboardButton("📊 VER ESTADO", callback_data='admin_servers_status')],
        [InlineKeyboardButton("🔙 GESTIÓN SERVIDORES", callback_data='admin_servers')]
    ]
    
    await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard))

# ========== CREAR USUARIO ADMIN ==========
async def admin_create_user(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    keyboard = [
        [InlineKeyboardButton("💎 30 DIAS", callback_data='admin_create_30_dias')],
        [InlineKeyboardButton("🔶 15 DIAS", callback_data='admin_create_15_dias')],
        [InlineKeyboardButton("🔷 7 DIAS", callback_data='admin_create_7_dias')],
        [InlineKeyboardButton("🎁 TEST", callback_data='admin_create_test')],
        [InlineKeyboardButton("🔙 ADMIN", callback_data='admin_panel')]
    ]
    
    await query.edit_message_text(
        "👤 CREAR USUARIO ADMIN\n\nSelecciona la duración:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def admin_create_seleccion_duracion(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    if not await safe_answer_callback(query):
        return
    
    duracion_map = {
        'admin_create_30_dias': {'dias': 30, 'tipo': 'premium', 'emoji': '💎'},
        'admin_create_15_dias': {'dias': 15, 'tipo': 'premium', 'emoji': '🔶'},
        'admin_create_7_dias': {'dias': 7, 'tipo': 'premium', 'emoji': '🔷'},
        'admin_create_test': {'dias': 0, 'tipo': 'test', 'emoji': '🎁'}
    }
    
    callback_data = query.data
    if callback_data not in duracion_map:
        return
    
    duracion_info = duracion_map[callback_data]
    context.user_data['admin_selected_duracion'] = duracion_info
    
    keyboard = []
    servers_activos = get_servers_activos()
    
    for server in servers_activos:
        status = "✅" if test_conexion_ssh(server['id']) else "❌"
        keyboard.append([InlineKeyboardButton(f"🖥️ {server['name']} {status}", callback_data=f'admin_create_on_server_{server["id"]}')])
    
    keyboard.append([InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')])
    
    tipo_texto = f"{duracion_info['emoji']} {duracion_info['tipo'].upper()}"
    if duracion_info['tipo'] == 'premium':
        tipo_texto += f" {duracion_info['dias']} DÍAS"
    else:
        tipo_texto += " (6 horas)"
    
    await query.edit_message_text(
        f"👤 CREAR USUARIO {tipo_texto}\n\nSelecciona el servidor:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def admin_create_user_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    try:
        await query.answer("🔄 Creando usuario...")
    except BadRequest as e:
        if "query is too old" in str(e).lower():
            return
        raise e
    
    try:
        if not query.data.startswith('admin_create_on_server_'):
            return
            
        parts = query.data.split('_')
        if len(parts) != 5:
            return
            
        server_id = int(parts[4])
        user_id = query.from_user.id
        
        duracion_info = context.user_data.get('admin_selected_duracion')
        if not duracion_info:
            mensaje_error = "❌ Error: No se seleccionó duración"
            keyboard = [[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')]]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            return
        
        dias = duracion_info['dias']
        tipo = duracion_info['tipo']
        emoji = duracion_info['emoji']
        
        server_existe = False
        server_name = f"Servidor {server_id}"
        for srv in CONFIG['SERVERS']:
            if srv['id'] == server_id and srv.get('enabled', True):
                server_existe = True
                server_name = srv['name']
                break
        
        if not server_existe:
            mensaje_error = f"❌ Servidor inválido: {server_id}"
            keyboard = [[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')]]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            return
        
        if not test_conexion_ssh(server_id):
            mensaje_error = f"❌ Servidor {server_name} no disponible"
            keyboard = [[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')]]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            return
        
        if tipo == "premium":
            usuario = f"VIP{random.randint(100,9999)}"
        else:
            usuario = f"prueba{random.randint(1000,9999)}"
            
        senha = generar_contraseña_segura()
        
        success = crear_usuario_vps(server_id, usuario, senha, dias, tipo)
        
        if success:
            conn = sqlite3.connect(CONFIG['DB_FILE'])
            cursor = conn.cursor()
            
            if tipo == "premium":
                expires_at = datetime.now() + timedelta(days=dias)
            else:
                expires_at = datetime.now() + timedelta(hours=3)
            
            cursor.execute('''
                INSERT INTO users (telegram_id, username, ssh_user, ssh_pass, server_id, dias, expires_at, tipo) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (user_id, "admin_created", usuario, senha, server_id, dias, expires_at, tipo))
            
            conn.commit()
            conn.close()
            
            tipo_texto = f"{tipo.upper()} {dias} DÍAS" if tipo == "premium" else "TEST (6 horas)"
            
            mensaje = f"""✅ USUARIO {tipo_texto} CREADO

🖥️ Servidor: {server_name}
👤 APP Usuario:   `{usuario}`\n
🔑 APP Contraseña:   `{senha}` \n
⏰ Duración: {dias if tipo == 'premium' else 3} {'días' if tipo == 'premium' else 'horas'}
📅 Expira: {expires_at.strftime('%d/%m/%Y %H:%M')}
🎯 Tipo: {tipo_texto} (Admin)"""

            keyboard = [
                [InlineKeyboardButton("👤 CREAR OTRO", callback_data='admin_create_user')],
                [InlineKeyboardButton("🔙 ADMIN", callback_data='admin_panel')]
            ]
            await query.edit_message_text(mensaje, reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')
        else:
            mensaje_error = f"❌ Error creando usuario en {server_name}"
            keyboard = [[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')]]
            await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))
            
    except Exception as e:
        logger.error(f"❌ Error en admin_create_user_handler: {e}")
        mensaje_error = f"❌ Error: {str(e)}"
        keyboard = [[InlineKeyboardButton("🔙 VOLVER", callback_data='admin_create_user')]]
        await query.edit_message_text(mensaje_error, reply_markup=InlineKeyboardMarkup(keyboard))

# ========== MAIN ==========
def main():
    logger.info("🚀 INICIANDO BOT DEFINITIVO CON GESTIÓN COMPLETA DE SERVIDORES...")
    
    if not init_db():
        logger.error("❌ No se pudo inicializar la base de datos")
        return
    
    servers_activos = get_servers_activos()
    logger.info(f"🔍 Verificando {len(servers_activos)} servidores activos...")
    
    for server in servers_activos:
        if test_conexion_ssh(server['id']):
            logger.info(f"✅ {server['name']} - CONECTADO")
        else:
            logger.warning(f"⚠️ {server['name']} - NO CONECTADO")
    
    try:
        application = Application.builder().token(CONFIG['TELEGRAM_TOKEN']).build()
        
        # Tareas programadas
        job_queue = application.job_queue
        job_queue.run_repeating(verificar_pagos_automaticamente, interval=120, first=10)
        job_queue.run_repeating(limpiar_usuarios_test_expirados, interval=3600, first=60)
        
        # ConversationHandler para agregar servidor
        conv_handler_add_server = ConversationHandler(
            entry_points=[CallbackQueryHandler(admin_add_server_start, pattern='^admin_add_server$')],
            states={
                ESPERANDO_SERVER_NOMBRE: [MessageHandler(filters.TEXT & ~filters.COMMAND, recibir_server_nombre)],
                ESPERANDO_SERVER_IP: [MessageHandler(filters.TEXT & ~filters.COMMAND, recibir_server_ip)],
                ESPERANDO_SERVER_USER: [MessageHandler(filters.TEXT & ~filters.COMMAND, recibir_server_user)],
                ESPERANDO_SERVER_PASS: [MessageHandler(filters.TEXT & ~filters.COMMAND, recibir_server_pass)],
                ESPERANDO_SERVER_PORT: [MessageHandler(filters.TEXT & ~filters.COMMAND, recibir_server_port)],
            },
            fallbacks=[CommandHandler('cancelar', cancelar_servidor)],
        )
        
        application.add_handler(conv_handler_add_server)
        
        # Comandos
        application.add_handler(CommandHandler("start", start))
        application.add_handler(CommandHandler("admin", admin_command))
        
        # Callbacks principales
        application.add_handler(CallbackQueryHandler(menu_principal, pattern='^menu_principal$'))
        application.add_handler(CallbackQueryHandler(test_gratis, pattern='^test_gratis$'))
        application.add_handler(CallbackQueryHandler(comprar_premium, pattern='^comprar_premium$'))
        application.add_handler(CallbackQueryHandler(mis_cuentas, pattern='^mis_cuentas$'))
        application.add_handler(CallbackQueryHandler(descargar_app, pattern='^descargar_app$'))
        
        # Admin
        application.add_handler(CallbackQueryHandler(admin_panel, pattern='^admin_panel$'))
        application.add_handler(CallbackQueryHandler(admin_stats, pattern='^admin_stats$'))
        application.add_handler(CallbackQueryHandler(admin_list_users, pattern='^admin_list_users$'))
        application.add_handler(CallbackQueryHandler(admin_servers, pattern='^admin_servers$'))
        application.add_handler(CallbackQueryHandler(admin_servers_status, pattern='^admin_servers_status$'))
        application.add_handler(CallbackQueryHandler(admin_create_user, pattern='^admin_create_user$'))
        
        # Gestión de servidores
        application.add_handler(CallbackQueryHandler(admin_delete_server, pattern='^admin_delete_server$'))
        application.add_handler(CallbackQueryHandler(confirmar_delete_server, pattern='^delete_srv_'))
        application.add_handler(CallbackQueryHandler(ejecutar_delete_server, pattern='^confirm_delete_'))
        application.add_handler(CallbackQueryHandler(admin_toggle_server, pattern='^admin_toggle_server$'))
        application.add_handler(CallbackQueryHandler(ejecutar_toggle_server, pattern='^toggle_srv_'))
        
        # Duraciones premium
        application.add_handler(CallbackQueryHandler(premium_seleccion_duracion, pattern='^premium_30_dias$'))
        application.add_handler(CallbackQueryHandler(premium_seleccion_duracion, pattern='^premium_15_dias$'))
        application.add_handler(CallbackQueryHandler(premium_seleccion_duracion, pattern='^premium_7_dias$'))
        
        # Admin crear usuario
        application.add_handler(CallbackQueryHandler(admin_create_seleccion_duracion, pattern='^admin_create_30_dias$'))
        application.add_handler(CallbackQueryHandler(admin_create_seleccion_duracion, pattern='^admin_create_15_dias$'))
        application.add_handler(CallbackQueryHandler(admin_create_seleccion_duracion, pattern='^admin_create_7_dias$'))
        application.add_handler(CallbackQueryHandler(admin_create_seleccion_duracion, pattern='^admin_create_test$'))
        
        # Con parámetros
        application.add_handler(CallbackQueryHandler(create_test_user, pattern='^test_server_'))
        application.add_handler(CallbackQueryHandler(premium_server, pattern='^premium_server_'))
        application.add_handler(CallbackQueryHandler(admin_create_user_handler, pattern='^admin_create_on_server_'))
        
        logger.info("🤖 BOT DEFINITIVO INICIADO - GESTIÓN COMPLETA DE SERVIDORES ACTIVA")
        logger.info("📋 Funcionalidades: TEST 3h | PREMIUM 30/15/7 días | Agregar/Eliminar/Habilitar Servidores")
        application.run_polling()
        
    except Exception as e:
        logger.error(f"❌ Error iniciando bot: {e}")

if __name__ == '__main__':
    main()
PYTHONBOT

chmod +x /root/bot_definitivo.py

mostrar_exito "Bot Python creado"

# Crear script de inicio automático
mostrar_titulo "🔄 CONFIGURANDO INICIO AUTOMÁTICO"

cat > /root/start_bot.sh <<'STARTSCRIPT'
#!/bin/bash
source /root/bot_venv/bin/activate
cd /root
nohup python3 /root/bot_definitivo.py > /root/bot.log 2>&1 &
echo $! > /root/bot.pid
echo "✅ Bot iniciado en segundo plano (PID: $(cat /root/bot.pid))"
STARTSCRIPT

chmod +x /root/start_bot.sh

# Crear script de detención
cat > /root/stop_bot.sh <<'STOPSCRIPT'
#!/bin/bash
if [ -f /root/bot.pid ]; then
    PID=$(cat /root/bot.pid)
    kill $PID 2>/dev/null
    rm /root/bot.pid
    echo "✅ Bot detenido (PID: $PID)"
else
    echo "❌ Bot no está corriendo"
fi
STOPSCRIPT

chmod +x /root/stop_bot.sh

# Crear servicio systemd para auto-inicio
cat > /etc/systemd/system/vpnbot.service <<SERVICEUNIT
[Unit]
Description=VPN Bot Telegram SuperC4mpeon
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/root
ExecStart=/root/start_bot.sh
ExecStop=/root/stop_bot.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEUNIT

systemctl daemon-reload
systemctl enable vpnbot.service

mostrar_exito "Servicio systemd creado y habilitado"

# Iniciar el bot
mostrar_titulo "🚀 INICIANDO BOT"
source /root/bot_venv/bin/activate
nohup python3 /root/bot_definitivo.py > /root/bot.log 2>&1 &
BOT_PID=$!
echo $BOT_PID > /root/bot.pid

sleep 3

# Verificar si está corriendo
if ps -p $BOT_PID > /dev/null; then
    mostrar_exito "Bot iniciado correctamente (PID: $BOT_PID)"
else
    mostrar_error "Error al iniciar el bot. Revisa /root/bot.log"
fi

# Resumen final
clear
echo -e "${CYAN}"
cat << "EOF"
╔═════════════════════════════════════════════╗
║                                                              ║
║                 ✅ INSTALACIÓN COMPLETADA ✅                 ║
║                                                              ║
╚══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
mostrar_titulo "📋 RESUMEN DE LA INSTALACIÓN"
echo ""
mostrar_exito "🤖 Bot VPN SuperC4mpeon instalado y corriendo"
mostrar_exito "💎 Planes: 30, 15 y 7 días + TEST gratis"
mostrar_exito "🖥️  Servidores configurados: $SERVER_COUNT"
mostrar_exito "⚙️  Panel Admin: COMPLETO con gestión de servidores"
mostrar_exito "🔄 Auto-inicio: HABILITADO (systemd)"
mostrar_exito "📱 MercadoPago: $([ -n "$MERCADOPAGO_TOKEN" ] && echo "CONFIGURADO" || echo "NO CONFIGURADO")"
echo ""

mostrar_titulo "🎯 FUNCIONALIDADES DEL PANEL ADMIN"
echo ""
echo "  ➕ Agregar servidores (con verificación SSH)"
echo "  🗑️  Eliminar servidores"
echo "  🔄 Habilitar/Deshabilitar servidores"
echo "  📊 Ver estado de servidores en tiempo real"
echo "  👤 Crear usuarios manualmente (30/15/7 días o TEST)"
echo "  📈 Ver estadisticas completas"
echo "  👥 Listar usuarios activos"
echo ""

mostrar_titulo "📞 COMANDOS DE TELEGRAM"
echo ""
echo "  /start - Menú principal del bot"
echo "  /admin - Panel de administración"
echo ""

mostrar_titulo "🛠️  COMANDOS DEL SISTEMA"
echo ""
echo "  bash /root/start_bot.sh   - Iniciar bot"
echo "  bash /root/stop_bot.sh    - Detener bot"
echo "  systemctl restart vpnbot  - Reiniciar bot (systemd)"
echo "  systemctl status vpnbot   - Ver estado del servicio"
echo "  tail -f /root/bot.log     - Ver logs en tiempo real"
echo "  nano /root/config_servers.json - Editar configuración"
echo ""

mostrar_titulo "📂 ARCHIVOS IMPORTANTES"
echo ""
echo "  📄 /root/bot_definitivo.py - Código del bot"
echo "  ⚙️  /root/config_servers.json - Configuración"
echo "  💾 /root/bot_sshplus.db - Base de datos"
echo "  📋 /root/bot.log - Registro de actividad"
echo "  🔧 /root/start_bot.sh - Script de inicio"
echo "  🛑 /root/stop_bot.sh - Script de detención"
echo ""

mostrar_titulo "💡 INFORMACIÓN ADICIONAL"
echo ""
echo "  👤 Admin ID: $ADMIN_ID"
echo "  📞 Soporte: $SOPORTE_USER"
echo "  💰 Precio 30 días: \$${PRECIO_30_DIAS} ARS"
echo "  💰 Precio 15 días: \$${PRECIO_15_DIAS} ARS"
echo "  💰 Precio 7 días: \$${PRECIO_7_DIAS} ARS"
echo ""

mostrar_titulo "🔐 SEGURIDAD"
echo ""
mostrar_advertencia "Las credenciales SSH están en /root/config_servers.json"
mostrar_advertencia "Protege este archivo: chmod 600 /root/config_servers.json"
mostrar_info "El bot se reinicia automáticamente si falla (systemd)"
echo ""

mostrar_titulo "📱 PRÓXIMOS PASOS"
echo ""
echo "  1️⃣  Abre Telegram y busca tu bot"
echo "  2️⃣  Envía /start para verificar que funciona"
echo "  3️⃣  Envía /admin para acceder al panel de administración"
echo "  4️⃣  Prueba agregar un servidor desde el panel admin"
echo "  5️⃣  Crea un usuario de prueba para verificar SSH"
echo ""

mostrar_titulo "🎉 ¡TODO LISTO!"
echo ""
mostrar_exito "El bot está corriendo en segundo plano"
mostrar_exito "PID: $(cat /root/bot.pid 2>/dev/null || echo "No disponible")"
mostrar_info "Si necesitas soporte: $SOPORTE_USER"
echo ""
echo -e "${CYAN}═════════════════════════════════════${NC}"
echo ""

# Crear archivo README
cat > /root/README_BOT.txt <<'README'
═══════════════════════════════════════════════
            BOT VPN SUPERC4MPEON - GUÍA RÁPIDA
════════════════════════════════════════════════

📋 COMANDOS PRINCIPALES:

  Iniciar bot:     bash /root/start_bot.sh
  Detener bot:     bash /root/stop_bot.sh
  Ver logs:        tail -f /root/bot.log
  Reiniciar:       systemctl restart vpnbot
  Estado:          systemctl status vpnbot

═════════════════════════════════════════════════

🖥️ GESTIÓN DE SERVIDORES (desde Telegram):

  1. Envía /admin al bot
  2. Selecciona "🖥️ GESTIONAR SERVIDORES"
  3. Opciones disponibles:
     - ➕ Agregar servidor (con verificación SSH)
     - 🗑️ Eliminar servidor
     - 📊 Ver estado de todos los servidores
     - 🔄 Habilitar/Deshabilitar servidores

════════════════════════════════════════════════

⚙️ EDITAR CONFIGURACIÓN MANUALMENTE:

  nano /root/config_servers.json

  Después de editar:
  systemctl restart vpnbot

══════════════════════════════════════════════════

🔧 SOLUCIÓN DE PROBLEMAS:

  Bot no responde:
    1. systemctl status vpnbot
    2. tail -100 /root/bot.log
    3. systemctl restart vpnbot

  Error de SSH al crear usuarios:
    1. Envía /admin
    2. Ve a "🖥️ GESTIONAR SERVIDORES"
    3. Selecciona "📊 VER ESTADO"
    4. Verifica conexión de servidores

  Cambiar precios:
    1. nano /root/config_servers.json
    2. Modifica PRECIO_30_DIAS, PRECIO_15_DIAS, PRECIO_7_DIAS
    3. systemctl restart vpnbot

═════════════════════════════════════════════════

📁 ESTRUCTURA DE ARCHIVOS:

  /root/bot_definitivo.py       - Código del bot
  /root/config_servers.json     - Configuración (IMPORTANTE)
  /root/bot_sshplus.db          - Base de datos SQLite
  /root/bot.log                 - Logs de actividad
  /root/bot_venv/               - Entorno virtual Python
  /root/start_bot.sh            - Script de inicio
  /root/stop_bot.sh             - Script de detención
  /root/.env_bot_superc4mpeon   - Variables de entorno

════════════════════════════════════════════════

💾 BACKUP RECOMENDADO:

  # Respaldar configuración y base de datos
  tar -czf ~/backup_bot_$(date +%Y%m%d).tar.gz \
    /root/config_servers.json \
    /root/bot_sshplus.db \
    /root/.env_bot_superc4mpeon

  # Restaurar
  tar -xzf ~/backup_bot_YYYYMMDD.tar.gz -C /
  systemctl restart vpnbot

════════════════════════════════════════════════

🔐 SEGURIDAD:

  1. Protege config_servers.json:
     chmod 600 /root/config_servers.json

  2. Cambia contraseñas SSH periódicamente

  3. Usa firewall (ufw) en los servidores VPN

  4. Monitorea logs regularmente:
     tail -f /root/bot.log

══════════════════════════════════════════════════

📊 MONITOREO:

  Ver estadisticas:
    Envía /admin → "📊 ESTADISTICAS"

  Ver usuarios activos:
    Envía /admin → "👥 LISTAR USUARIOS"

  Ver servidores:
    Envía /admin → "🖥️ GESTIONAR SERVIDORES" → "📊 VER ESTADO"

═══════════════════════════════════════════════

🆘 SOPORTE:

  Si necesitas ayuda, contacta: $SOPORTE_USER

═══════════════════════════════════════════════
README

mostrar_exito "Guía creada en: /root/README_BOT.txt"

# Permisos de seguridad
chmod 600 /root/config_servers.json
chmod 600 /root/.env_bot_superc4mpeon

mostrar_exito "Permisos de seguridad aplicados"

echo ""
echo -e "${GREEN}═══════════════════════════════${NC}"
echo -e "${GREEN}  🎊 ¡BOT INSTALADO Y FUNCIONANDO! 🎊${NC}"
echo -e "${GREEN}════════════════════════════════${NC}"
echo ""