from utils.utils import lat_km_to_deg, long_km_to_deg
from utils.db import DB_Utils
import requests
import uuid
import json
from random import randrange

LOCAL_URL = 'http://localhost:8080'
ROC_COORDS = [43.1029381, -77.57511]
SEA_COORDS = [47.6062, 122.3321]
REAL_ID = '89f958d8-e523-11eb-8f21-acde48001122'
db = DB_Utils()


def main():
    # create_location()
    rate_location(REAL_ID, 2)
    # get_locations(ROC_COORDS)
    # get_locations(SEA_COORDS)
    # create_test_locations(ROC_COORDS, 10)


def rate_location(location_id, rating):
    response = requests.post(
        f'{LOCAL_URL}/rate_location?location_id={location_id}&rating={rating}'
    )
    print(response.content)


def get_locations(coords):
    response = requests.get(
        f'{LOCAL_URL}/get_locations?coords={coords[0]},{coords[1]}'
        '&radius=5'
    )
    print(response.content)


def create_location():
    response = requests.post(
        f'{LOCAL_URL}/create_location?'
        f'coords={randrange(-89, 90)},{randrange(-179, 180)}&'
        f'title=test_title_{str(uuid.uuid1())}'
    )
    print(response.content)


def create_test_locations(center_coords, radius):
    """
    Creates a few local locations, spaced by ~1km in a grid
    """
    location_stmts = []
    for i in range(-radius, radius):
        for j in range(-radius, radius):

            lat = center_coords[0] + lat_km_to_deg(i)
            long = center_coords[1] + long_km_to_deg(center_coords, j)
            id = uuid.uuid1()
            location_data = {
                'type': 'FeatureCollection',
                'features': [
                    {
                        'type': 'Feature',
                        'properties': {
                            'relative_location': f'test_location_{id}',
                            'description': 'test_location',
                            'type': 'WaterFountain',
                            'title': f'test_location_{id}',
                            'rating': '0',
                            'num_ratings': '0'
                        },
                        'geometry': {
                            'type': 'Point',
                            'coordinate': [
                                lat,
                                long
                            ]
                        }
                    }
                ]
            }
            location_stmts.append(
                f"('{str(id)}', {long}, {lat}, "
                f"SYSTOOLS.JSON2BSON('{json.dumps(location_data)}'))"
            )

    insert_stmt = (
        'INSERT INTO locations '
        '(location_id, longitude, latitude, location_data) '
        f"VALUES {','.join(location_stmts)}"
    )
    print(insert_stmt[:200])
    db.run_raw_sql(insert_stmt, False)
    

if __name__ == '__main__':
    main()
