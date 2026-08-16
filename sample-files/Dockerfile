# Dockerfile sample: multi-stage build, ARG and ENV, heredoc RUN.

# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=22
ARG ALPINE_VERSION=3.20

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS base

LABEL org.opencontainers.image.title="Themes of Shibbir" \
      org.opencontainers.image.source="https://github.com/shibbir/themes-of-shibbir" \
      org.opencontainers.image.licenses="MIT"

ENV NODE_ENV=production \
    TZ=Asia/Dhaka \
    PATH="/app/node_modules/.bin:${PATH}"

WORKDIR /app

RUN apk add --no-cache \
        git \
        tini \
    && addgroup -S app \
    && adduser -S -G app app

FROM base AS deps

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

FROM base AS build

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN <<'SHELL'
set -eux
npx @vscode/vsce package --out /app/theme.vsix
ls -lh /app/theme.vsix
SHELL

FROM base AS runtime

COPY --from=build --chown=app:app /app/theme.vsix ./theme.vsix
COPY --from=deps --chown=app:app /app/node_modules ./node_modules

USER app
EXPOSE 3000/tcp

VOLUME ["/app/data"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --spider http://localhost:3000/health || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]
