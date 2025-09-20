# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Geometry API',
        version: 'v1',
        description: 'API para gerenciamento de frames e círculos geométricos com autenticação JWT',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.example.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtido através do endpoint de login'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'João Silva' },
              email: { type: :string, example: 'joao@example.com' },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time }
            }
          },
          Frame: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              center_x: { type: :number, format: :float, example: 100.0 },
              center_y: { type: :number, format: :float, example: 100.0 },
              width: { type: :number, format: :float, example: 200.0 },
              height: { type: :number, format: :float, example: 150.0 },
              left: { type: :number, format: :float, example: 0.0 },
              right: { type: :number, format: :float, example: 200.0 },
              top: { type: :number, format: :float, example: 175.0 },
              bottom: { type: :number, format: :float, example: 25.0 },
              circles_count: { type: :integer, example: 3 },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time }
            }
          },
          Circle: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              center_x: { type: :number, format: :float, example: 100.0 },
              center_y: { type: :number, format: :float, example: 100.0 },
              diameter: { type: :number, format: :float, example: 50.0 },
              radius: { type: :number, format: :float, example: 25.0 },
              frame_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  message: { type: :string, example: 'Erro de validação' },
                  details: { type: :string, example: 'Detalhes do erro' },
                  timestamp: { type: :string, format: :date_time }
                }
              }
            }
          },
          Success: {
            type: :object,
            properties: {
              data: { type: :object },
              meta: {
                type: :object,
                properties: {
                  message: { type: :string, example: 'Operação realizada com sucesso' },
                  timestamp: { type: :string, format: :date_time }
                }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
