# Geometry API

Uma API RESTful para gerenciamento de frames e círculos geométricos com autenticação JWT.

## 🚀 Características

- **Autenticação JWT** com tokens seguros
- **API RESTful** com versionamento (`/api/v1`)
- **Documentação Swagger** completa e interativa
- **Validações geométricas** avançadas (colisões, limites)
- **Testes abrangentes** com 98.94% de cobertura
- **Docker** para desenvolvimento e produção
- **PostgreSQL** como banco de dados

## 📋 Pré-requisitos

- Docker e Docker Compose
- Ruby 3.3+
- PostgreSQL (via Docker)

## 🛠️ Instalação e Configuração

### 1. Clone o repositório
```bash
git clone <repository-url>
cd geometry-api
```

### 2. Configure as variáveis de ambiente
```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite as variáveis conforme necessário
nano .env
```

### 3. Inicie os serviços
```bash
# Inicie o banco de dados e a aplicação
docker compose up -d

# Aguarde a inicialização completa
docker compose logs -f geometry-api
```

### 4. Execute as migrações
```bash
docker compose exec geometry-api bundle exec rails db:migrate
```

## 🧪 Executando os Testes

```bash
# Execute todos os testes
docker compose exec geometry-api bundle exec rspec

# Execute com cobertura
docker compose exec geometry-api bundle exec rspec --format progress

# Execute testes específicos
docker compose exec geometry-api bundle exec rspec spec/requests/api/v1/
```

## 📚 Documentação da API

A documentação Swagger está disponível em:
- **Interface Web**: http://localhost:3000/api-docs/index.html
- **Arquivo YAML**: http://localhost:3000/api-docs/v1/swagger.yaml

## 🔐 Autenticação

A API utiliza JWT (JSON Web Tokens) para autenticação:

### 1. Registro de Usuário
```bash
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "João Silva",
      "email": "joao@example.com",
      "password": "senha123",
      "password_confirmation": "senha123"
    }
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:3000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "joao@example.com",
      "password": "senha123"
    }
  }'
```

### 3. Usar o Token
```bash
curl -X GET http://localhost:3000/api/v1/sessions/current \
  -H "Authorization: Bearer SEU_JWT_TOKEN"
```

## 🎯 Endpoints da API

### Usuários
- `POST /api/v1/users` - Criar usuário

### Autenticação
- `POST /api/v1/sessions` - Login
- `GET /api/v1/sessions/current` - Usuário atual
- `DELETE /api/v1/sessions` - Logout

### Frames
- `POST /api/v1/frames` - Criar frame
- `GET /api/v1/frames/{id}` - Obter frame
- `DELETE /api/v1/frames/{id}` - Remover frame

### Círculos
- `GET /api/v1/circles` - Listar círculos (com filtros)
- `POST /api/v1/frames/{frame_id}/circles` - Criar círculo
- `PUT /api/v1/circles/{id}` - Atualizar círculo
- `DELETE /api/v1/circles/{id}` - Remover círculo

## 🔍 Filtros de Busca

### Círculos com filtros
```bash
# Por frame
GET /api/v1/circles?frame_id=1

# Por raio
GET /api/v1/circles?center_x=100&center_y=100&radius=50

# Combinados
GET /api/v1/circles?frame_id=1&center_x=100&center_y=100&radius=50
```

## 🏗️ Arquitetura

### Estrutura do Projeto
```
app/
├── controllers/
│   ├── api/v1/          # Controllers versionados
│   └── concerns/        # Concerns compartilhados
├── models/              # Modelos ActiveRecord
├── services/            # Lógica de negócio
├── serializers/         # Serialização JSON API
└── validators/          # Validadores customizados

spec/
├── requests/            # Testes de integração
├── models/              # Testes de modelo
├── services/            # Testes de serviço
└── factories/           # Dados de teste
```

### Padrões Utilizados
- **Service Objects** para lógica complexa
- **Custom Validators** para regras de negócio
- **JSON API Serializer** para responses padronizados
- **FactoryBot** para dados de teste
- **RSpec** para testes

## 🛡️ Validações Geométricas

### Frames
- Não podem colidir ou encostar em outros frames
- Coordenadas devem ser válidas
- Dimensões devem ser positivas

### Círculos
- Devem estar dentro dos limites do frame
- Não podem colidir com outros círculos
- Diâmetro deve ser positivo

## 🚀 Deploy

### Produção com Docker
```bash
# Build da imagem
docker build -t geometry-api .

# Execute com variáveis de produção
docker run -d \
  -e RAILS_ENV=production \
  -e DATABASE_URL=postgresql://user:pass@host:port/db \
  -p 3000:3000 \
  geometry-api
```

### Variáveis de Ambiente
```bash
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@host:port/database
RAILS_MASTER_KEY=your_master_key
```

## 🔧 Desenvolvimento

### Comandos Úteis
```bash
# Console Rails
docker compose exec geometry-api bundle exec rails console

# Logs da aplicação
docker compose logs -f geometry-api

# Reiniciar serviços
docker compose restart geometry-api

# Executar migrações
docker compose exec geometry-api bundle exec rails db:migrate

# Seed do banco
docker compose exec geometry-api bundle exec rails db:seed
```

### Qualidade de Código
```bash
# RuboCop (linting)
docker compose exec geometry-api bundle exec rubocop

# Brakeman (segurança)
docker compose exec geometry-api bundle exec brakeman

# Testes com cobertura
docker compose exec geometry-api bundle exec rspec
```

## 📊 Métricas

- **Cobertura de Testes**: 98.94%
- **Total de Testes**: 191 examples
- **Endpoints Documentados**: 11
- **Segurança**: 0 vulnerabilidades (Brakeman)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

Para dúvidas ou problemas:
- Abra uma [issue](https://github.com/seu-usuario/geometry-api/issues)
- Consulte a [documentação Swagger](http://localhost:3000/api-docs/index.html)
- Verifique os [logs](http://localhost:3000/logs) da aplicação