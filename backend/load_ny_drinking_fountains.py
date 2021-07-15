import uuid
from utils.db import DB_Utils
from endpoint_apis.location import create_location
import json

db = DB_Utils()

json_file = json.load(open(
    './datasets/ny_drinking_fountains/ny_drinking_fountains.json'
))

location_stmts = []
for i, row in enumerate(json_file['data']):
    if i > 15:
        break
    coords = str(row[9]).replace('POINT ', '')[1:-1].split(' ')
    coords = [float(p) for p in coords]
    coords = coords[::-1]
    rel_location = row[15].replace('\'', '')
    if i % 10 == 0:
        print(coords)
    create_location(
        db, coords, 'tmp', 'tmp', 'WaterFountain',
        f'{rel_location} Water Fountain'
    )
