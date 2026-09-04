# ---------- Stage 1: Build ----------
FROM node:16-slim AS build

WORKDIR /app

# Copy package files first (better layer caching)
COPY package*.json ./
RUN npm ci

# Copy rest of the app and build
COPY . .
RUN npm run build

# ---------- Stage 2: Production ----------
FROM node:16-slim

WORKDIR /app

# Copy only what's needed to run the app
COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev

COPY --from=build /app/build ./build

EXPOSE 3000

CMD ["npx", "serve", "-s", "build", "-l", "3000"]
