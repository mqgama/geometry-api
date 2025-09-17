# Docker Setup - Geometry API

Este projeto inclui configuração Docker completa para desenvolvimento e produção.

## Arquivos Docker

- `Dockerfile` - Imagem da aplicação Rails otimizada para desenvolvimento e produção
- `docker-compose.yml` - Orquestração dos serviços (Rails + PostgreSQL)

## Como usar

### Desenvolvimento

1. **Configure as variáveis de ambiente:**
   ```bash
   # Copie sua master key do Rails
   export RAILS_MASTER_KEY=$(cat config/master.key)
   ```

2. **Inicie os serviços:**
   ```bash
   docker-compose up
   ```

3. **Acesse a aplicação:**
   - API: http://localhost:3000
   - PostgreSQL: localhost:5432

### Comandos úteis

```bash
# Parar os serviços
docker-compose down

# Rebuild da imagem
docker-compose build

# Acessar container da aplicação
docker-compose exec geometry-api bash

# Acessar PostgreSQL
docker-compose exec postgres psql -U postgres -d geometry_api_development

# Ver logs
docker-compose logs -f geometry-api
```

### Produção

```bash
# Build da imagem
docker build -t geometry-api .

# Executar container
docker run -d \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=your_master_key \
  -e DATABASE_URL=postgresql://user:pass@host:5432/db \
  --name geometry-api \
  geometry-api
```

## Volumes

- `postgres_data` - Dados persistentes do PostgreSQL
- `bundle_cache` - Cache das gems para builds mais rápidos
- `.` - Código fonte montado para desenvolvimento

## Banco de Dados

- **Desenvolvimento**: `geometry_api_development`
- **Usuário**: `postgres`
- **Senha**: `password`
- **Porta**: `5432`

Os dados do PostgreSQL são persistidos no volume `postgres_data`.
