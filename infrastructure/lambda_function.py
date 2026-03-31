import json
import boto3
import os
from datetime import datetime
from decimal import Decimal

DYNAMODB_TABLE = os.environ.get('TABLE_NAME', 'DentalPressureLogs')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(DYNAMODB_TABLE)

def lambda_handler(event, context):
    method = event.get('requestContext', {}).get('http', {}).get('method', 'POST')
    
    try:
        # --- CAS 1 : LECTURE (GET) ---
        if method == 'GET':
            response = table.scan(Limit=30)
            items = sorted(response['Items'], key=lambda x: x['Timestamp'])
            
            for item in items:
                item['PressureValue'] = float(item['PressureValue'])
                if 'ToothIndex' in item:
                    item['ToothIndex'] = int(item['ToothIndex'])
            
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'}, # Retrait du CORS ici
                'body': json.dumps(items)
            }

        # --- CAS 2 : ECRITURE (POST) ---
        raw_body = event.get('body', '{}')
        body = json.loads(raw_body) if isinstance(raw_body, str) else raw_body

        patient_id = body.get('PatientID', 'Inconnu')
        raw_pressure = body.get('PressureValue', 0)
        zone = body.get('Zone', 'Gauche')
        tooth_index = body.get('ToothIndex', 0)
        
        table.put_item(Item={
            'PatientID': patient_id,
            'Timestamp': datetime.now().isoformat(),
            'PressureValue': Decimal(str(raw_pressure)),
            'Zone': zone,
            'ToothIndex': tooth_index,
            'Status': 'Alerte' if float(raw_pressure) > 60 else 'Normal'
        })

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'}, # Retrait du CORS ici
            'body': json.dumps({'message': 'Succès', 'Zone': zone})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'}, # Retrait du CORS ici
            'body': json.dumps({'error': str(e)})
        }