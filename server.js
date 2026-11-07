"use strict";

const express = require("express");
const os = require("os");
const crypto = require("crypto");
const path = require("path");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const app = express();
const PORT = Number(process.env.PORT || 80);
const REGION = process.env.AWS_REGION || "us-east-1";
const BUCKET = process.env.BUCKET_NAME || process.env.BUCKET;

const s3 = new S3Client({ region: REGION });

app.disable("x-powered-by");
app.use(express.json({ limit: "1mb" }));

app.get("/", (_req, res) => {
  res.status(200).send(
    `<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Mercado Andino</title></head>` +
    `<body><h1>Mercado Andino v1</h1><p>Aplicación en ejecución.</p>` +
    `<small>Instancia: ${os.hostname()}</small></body></html>`
  );
});

app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
    application: "mercadoandino-app",
    instance: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

app.get("/api/upload-url", async (req, res) => {
  try {
    if (!BUCKET) {
      return res.status(500).json({ error: "Falta configurar BUCKET_NAME en el servidor." });
    }

    const originalName = String(req.query.name || "archivo").trim();
    const contentType = String(req.query.type || "application/octet-stream").trim();

    if (!originalName || originalName.length > 180 || /[\/\\]/.test(originalName)) {
      return res.status(400).json({ error: "Nombre de archivo no válido." });
    }

    if (!/^[\w.+-]+\/[\w.+-]+$/.test(contentType)) {
      return res.status(400).json({ error: "Tipo de contenido no válido." });
    }

    const extension = path.extname(originalName).replace(/[^.\w-]/g, "");
    const key = `uploads/${Date.now()}-${crypto.randomUUID()}${extension}`;

    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      ContentType: contentType
    });

    const url = await getSignedUrl(s3, command, { expiresIn: 300 });
    return res.json({ url, key, expiresIn: 300 });
  } catch (error) {
    console.error("Error al generar URL de carga:", error);
    return res.status(500).json({ error: "No se pudo generar la URL de carga." });
  }
});

app.use((_req, res) => {
  res.status(404).json({ error: "Ruta no encontrada." });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Mercado Andino escuchando en el puerto ${PORT}`);
});

process.on("unhandledRejection", (reason) => {
  console.error("Promesa rechazada sin gestionar:", reason);
});
