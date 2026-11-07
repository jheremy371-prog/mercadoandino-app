# Mercado Andino

Aplicación Node.js con Express preparada para desplegarse en una instancia Amazon EC2 mediante AWS CodeDeploy. Incluye un endpoint de salud y un endpoint para generar URL prefirmadas de carga a Amazon S3.

## Tecnologías

- Node.js y Express
- Amazon S3 mediante AWS SDK for JavaScript v3
- Amazon EC2
- AWS CodeDeploy

## Estructura

```text
mercadoandino-app/
├── server.js
├── package.json
├── appspec.yml
├── .gitignore
├── .env.example
├── README.md
└── scripts/
    ├── install.sh
    ├── start.sh
    ├── stop.sh
    └── validate.sh
```

## Requisitos

- Node.js 18 o superior y npm.
- Una instancia EC2 Linux con AWS CodeDeploy Agent instalado.
- Un bucket de Amazon S3.
- Un rol IAM asociado a EC2 con permiso `s3:PutObject` sobre el bucket.
- Security Group que permita el tráfico HTTP al puerto configurado.

## Instalación local

```bash
npm install
```

Copia `.env.example` a `.env` y configura `PORT`, `AWS_REGION` y `BUCKET_NAME`. Para desarrollo, carga las variables de entorno antes de iniciar la aplicación.

```bash
npm start
```

Prueba la aplicación en `http://localhost:3000` si configuraste `PORT=3000`.

## Endpoints

- `GET /` muestra el estado básico de la aplicación.
- `GET /health` devuelve el estado de salud en formato JSON.
- `GET /api/upload-url?name=foto.jpg&type=image/jpeg` genera una URL prefirmada de S3 válida durante 300 segundos.

La ruta de carga entrega una URL prefirmada; el cliente debe realizar el `PUT` del archivo a esa URL y enviar el mismo `Content-Type`.

## Despliegue con CodeDeploy

CodeDeploy copia el contenido del repositorio a `/home/ec2-user/app` y ejecuta los scripts definidos en `appspec.yml`.

Antes del despliegue:

1. Instala Node.js 18 o superior en EC2.
2. Instala y configura CodeDeploy Agent.
3. Asocia a la instancia un rol IAM con permisos mínimos necesarios para escribir en el bucket.
4. Configura `BUCKET_NAME` y `AWS_REGION` en el entorno del proceso de la instancia. El script `start.sh` permite establecerlos como variables de entorno.
5. Comprueba que el puerto de la aplicación esté permitido por el Security Group.

Los scripts se ejecutan como `root` mediante CodeDeploy. La aplicación se inicia con `nohup` y escribe sus registros en `/var/log/mercadoandino.log`.

## Seguridad

- No guardes claves AWS, contraseñas ni archivos `.env` en GitHub.
- Usa un rol IAM de instancia EC2 en lugar de claves de acceso fijas.
- Limita los permisos IAM al bucket y prefijo necesarios.
- Las URL prefirmadas son temporales: compártelas únicamente con usuarios autorizados.
# mercadoandino-app
