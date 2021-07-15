from utils.db import DB_Utils
from endpoint_apis.location import create_location
import json

db = DB_Utils()

json_file = json.load(open(
    './datasets/ny_drinking_fountains/ny_drinking_fountains.json'
))

for i, row in enumerate(json_file['data']):
    coords = row[9].replace('POINT ', '')[1:-1].split(' ')[::-1]
    coords = [float(p) for p in coords]
    rel_location = row[15].replace('\'', '')
    if i == 1:
        print(coords)
    create_location(
        db, coords, None, None, 'WaterFountain',
        f'{rel_location} Water Fountain'
    )
    if i % 100 == 0:
        print(i)
