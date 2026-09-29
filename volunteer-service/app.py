import os
import sys
import uuid
import time
import logging
import boto3
from botocore.exceptions import ClientError
from flask import Flask, request, jsonify
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
log = logging.getLogger(__name__)

load_dotenv()

app = Flask(__name__)

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
DYNAMODB_TABLE = os.getenv("AWS_DYNAMODB_TABLE")
DYNAMODB_ENDPOINT = os.getenv("DYNAMODB_ENDPOINT")  # ex: http://dynamodb-local:8000 (só em dev local)

if not DYNAMODB_TABLE:
    log.critical("Erro: AWS_DYNAMODB_TABLE não definida.")
    sys.exit(1)

try:
    if DYNAMODB_ENDPOINT:
        # Modo desenvolvimento local: aponta pro DynamoDB Local em vez da AWS real
        log.info(f"Usando DynamoDB Local em {DYNAMODB_ENDPOINT}")
        dynamodb = boto3.resource(
            "dynamodb",
            region_name=AWS_REGION,
            endpoint_url=DYNAMODB_ENDPOINT,
            aws_access_key_id="local",
            aws_secret_access_key="local",
        )
    else:
        # Modo produção: usa as credenciais reais da AWS
        dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)

    table = dynamodb.Table(DYNAMODB_TABLE)

    # Se estivermos em modo local, a tabela não existe ainda — criamos automaticamente
    if DYNAMODB_ENDPOINT:
        try:
            table.load()
            log.info(f"Tabela '{DYNAMODB_TABLE}' já existe no DynamoDB Local.")
        except ClientError:
            log.info(f"Criando tabela '{DYNAMODB_TABLE}' no DynamoDB Local...")
            table = dynamodb.create_table(
                TableName=DYNAMODB_TABLE,
                KeySchema=[{'AttributeName': 'volunteer_id', 'KeyType': 'HASH'}],
                AttributeDefinitions=[{'AttributeName': 'volunteer_id', 'AttributeType': 'S'}],
                BillingMode='PAY_PER_REQUEST',
            )
            table.wait_until_exists()

    log.info(f"Conectado à tabela DynamoDB: {DYNAMODB_TABLE}")
except Exception as e:
    log.critical(f"Falha ao conectar no DynamoDB: {e}")
    sys.exit(1)

@app.route('/health')
def health():
    return jsonify({"status": "ok", "service": "volunteer-service"})

@app.route('/volunteers', methods=['POST'])
def register_volunteer():
    data = request.get_json()
    if not data or not all(k in data for k in ('name', 'email', 'ngo_id')):
        return jsonify({"error": "Campos obrigatórios ausentes"}), 400
    
    volunteer_id = str(uuid.uuid4())
    item = {
        'volunteer_id': volunteer_id,
        'name': data['name'],
        'email': data['email'],
        'ngo_id': int(data['ngo_id']),
        'registered_at': str(int(time.time()))
    }
    
    try:
        table.put_item(Item=item)
        return jsonify(item), 201
    except Exception as e:
        log.error(f"Erro ao salvar voluntário no DynamoDB: {e}")
        return jsonify({"error": "Erro interno ao processar dados"}), 500

@app.route('/volunteers/<int:ngo_id>', methods=['GET'])
def get_volunteers_by_ngo(ngo_id):
    try:
        # Nota para avaliação dos alunos: Operação Scan simplificada para fins de desenvolvimento.
        # Em cenários complexos de produção, índices globais secundários (GSI) seriam exigidos.
        response = table.scan(
            FilterExpression=boto3.dynamodb.conditions.Attr('ngo_id').eq(ngo_id)
        )
        return jsonify(response.get('Items', [])), 200
    except Exception as e:
        log.error(f"Erro ao buscar dados no DynamoDB: {e}")
        return jsonify({"error": "Erro interno"}), 500

if __name__ == '__main__':
    port = int(os.getenv("PORT", 8083))
    app.run(host='0.0.0.0', port=port)