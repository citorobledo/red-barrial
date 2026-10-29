# Red barrial · Banco de alimentos

Aplicación web local para registrar donaciones y entregas con trazabilidad por lote.

## Inicio rápido
```bash
cp .env.example .env        # completar los valores "cambiar-esto"
docker compose up -d --build
```
- Aplicación: http://localhost:8000
- Keycloak (admin): http://localhost:8080
- Padrón simulado (Swagger UI): http://localhost:8001/docs

## Uso desde otras PCs del depósito
Definir `PUBLIC_HOST` en `.env` con la IP o nombre de la PC servidor y recrear los contenedores.
`PUBLIC_HOST` determina el emisor (iss) de los tokens y las URLs de redirección del realm.

## Respaldo y restauración
```bash
scripts/backup.sh
scripts/restore.sh backups/AAAAMMDD-HHMMSS
```
Programar el respaldo diario con cron del host. Keycloak se detiene unos segundos durante el respaldo.

## Estructura
- `app/` aplicación Django (monolito modular). `src/apps/` replica los componentes del C4.
- `padron-mock/` simula el padrón provincial (latencia y fallas configurables).
- `keycloak/realm/` realm importado al iniciar (roles y cliente OIDC).
- `scripts/` respaldo y restauración.
- `docs/adr/` decisiones de arquitectura.

## Pendiente
Generar el proyecto Django en `app/src/`, diseñar la base, completar los ADRs y agregar C4 y NFRs a `docs/`.
