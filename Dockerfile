# Bidrag.se — single production image: API + worker + built SPA.
# Multi-stage: deterministic install, build, minimal runtime.

FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
COPY packages/core/package.json packages/core/
COPY apps/api/package.json apps/api/
COPY apps/web/package.json apps/web/
RUN npm ci --no-audit --no-fund
COPY tsconfig.base.json ./
COPY packages/core packages/core
COPY apps/api apps/api
COPY apps/web apps/web
RUN npm run build -w packages/core \
 && npm run build -w apps/api \
 && npm run build -w apps/web

FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
RUN addgroup -S bidrag && adduser -S bidrag -G bidrag
COPY package.json package-lock.json ./
COPY packages/core/package.json packages/core/
COPY apps/api/package.json apps/api/
RUN npm ci --omit=dev --workspace packages/core --workspace apps/api --no-audit --no-fund \
 && npm cache clean --force
COPY --from=build /app/packages/core/dist packages/core/dist
COPY --from=build /app/apps/api/dist apps/api/dist
COPY --from=build /app/apps/api/drizzle apps/api/drizzle
COPY --from=build /app/apps/web/dist apps/web/dist
ENV WEB_DIST=/app/apps/web/dist
ENV UPLOAD_DIR=/data/uploads
RUN mkdir -p /data/uploads && chown -R bidrag:bidrag /data /app
USER bidrag
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s CMD wget -qO- http://localhost:3000/healthz || exit 1
CMD ["node", "apps/api/dist/index.js"]
