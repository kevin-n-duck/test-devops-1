# Build stage
FROM public.ecr.aws/docker/library/node:20-bookworm-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

# Runtime stage - using distroless
FROM gcr.io/distroless/nodejs20-debian13

WORKDIR /app

# Copy node_modules and app from builder
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json .

EXPOSE 3000

ENV NODE_ENV=production

CMD ["src/app.js"]

#trigger