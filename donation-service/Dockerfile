# --- Estágio 1: build (compila o binário Go) ---
FROM golang:1.25 AS builder

WORKDIR /app

# copia todo o código de uma vez (não temos go.sum ainda pra separar o cache)
COPY . .

# remove uma linha problemática do go.mod (pgx/v4/stdlib listado incorretamente)
RUN sed -i '/jackc\/pgx\/v4\/stdlib/d' go.mod

# resolve as dependências e gera o go.sum automaticamente
RUN go mod tidy

# compila um binário estático, sem dependências externas do SO
RUN CGO_ENABLED=0 GOOS=linux go build -o donation-service .

# --- Estágio 2: imagem final (mínima, só o binário) ---
FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=builder /app/donation-service .

EXPOSE 8082

USER nonroot:nonroot

ENTRYPOINT ["./donation-service"]