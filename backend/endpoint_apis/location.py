from utils.utils import clamp, approx_coord_range
import json
from uuid import uuid1

DEFAULT_RADIUS = 5
MAX_RADIUS = 50


def create_location(
    db_utils, coordinates, relative_loc, description, loc_type, title
):
    relative_loc = relative_loc or 'rel_loc'
    description = description or 'desc'
    loc_type = loc_type or 'loc_type'
    lat = coordinates[0]
    long = coordinates[1]
    id = uuid1()

    location_data = {
        'type': 'Feature',
        'properties': {
            'relative_location': relative_loc,
            'description': description,
            'type': loc_type,
            'title': title,
            'rating': '0',
            'num_ratings': '0',
            'LOCATION_ID': str(id)
        },
        'geometry': {
            'type': 'Point',
            'coordinates': [
                long,
                lat
            ]
        }
    }

    insert_stmt = (
        'INSERT INTO locations '
        '(location_id, longitude, latitude, location_data) '
        f"VALUES ('{str(id)}', {long}, {lat}, "
        f"SYSTOOLS.JSON2BSON('{json.dumps(location_data)}'))"
    )
    # print(insert_stmt)
    db_utils.run_raw_sql(insert_stmt, False)
    return str(id)


def get_locations(db_utils, coordinates, radius):
    """
    Fetches a list of locations which are within the specified range
    """
    # TODO include coord wrapping
    radius = clamp(radius or DEFAULT_RADIUS, 1, MAX_RADIUS)
    min_lat, max_lat, min_long, max_long = approx_coord_range(
        coordinates, radius
    )

    select_stmt = (
        'SELECT '
        'SYSTOOLS.BSON2JSON(location_data) as location_data '
        'FROM locations '
        'WHERE '
        f'latitude >= {min_lat} AND latitude <= {max_lat} AND '
        f'longitude >= {min_long} AND longitude <= {max_long}'
    )

    feat_collection = {
        "type": "FeatureCollection",
        "features": []
    }
    for row in db_utils.run_raw_sql(select_stmt):
        feat_collection['features'].append(json.loads(row['LOCATION_DATA']))
    return feat_collection


def get_location(db_utils, location_id):
    """
    Gets the 'location_data' given a 'location_id'
    """
    row = _get_location(db_utils, location_id)

    if not row:
        return (
            f'The location_id "{location_id}" specified does not exist',
            400
        )

    # TODO: Check if this is redundant.
    #   Leaving it to ensure that the json is properly formatted
    return (json.dumps(json.loads(row['LOCATION_DATA'])), 200)


def rate_location(db_utils, location_id, rating):
    """
    Adds a rating for a location
    """
    row = _get_location(db_utils, location_id)

    if not row:
        return (
            f'The location_id "{location_id}" specified does not exist',
            400
        )

    location_data = json.loads(row['LOCATION_DATA'])

    """
    Method 1: Modifying the location_data directly
    """
    # Calculating new average from running average data
    properties = location_data['properties']
    num_ratings = int(properties['num_ratings'])
    new_rating = (
        int(properties['rating']) * num_ratings + rating
    ) / (num_ratings + 1)
    properties['rating'] = new_rating
    properties['num_ratings'] = num_ratings + 1
    location_data['properties'] = properties

    update_stmt = (
        'UPDATE locations SET location_data = '
        f"SYSTOOLS.JSON2BSON('{json.dumps(location_data)}') "
        f"WHERE location_id = '{location_id}'"
    )
    db_utils.run_raw_sql(update_stmt, False)

    """
    Method 2: Storing ratings in second DB
    NOTE: Not used at the moment. Can be wired in at a later time.
    """

    insert_stmt = (
        'INSERT INTO location_ratings (rating_id, rating, location_id) '
        f"VALUES ('{uuid1()}', {rating}, '{location_id}')"
    )
    db_utils.run_raw_sql(insert_stmt, False)

    return (str(new_rating), 200)


def _get_location(db_utils, location_id):
    """
    Gets all attributes associated with a locaiton_id
    """
    # Selecting each values so that it is obvious how the data is stored.
    select_stmt = (
        'SELECT '
        'location_id as location_id, '
        'longitude as longitude, '
        'latitude as latitude, '
        'SYSTOOLS.BSON2JSON(location_data) as location_data '
        'FROM locations '
        f"WHERE location_id = '{location_id}'"
    )
    # Not the best way to handle this but it will suffice
    try:
        rows = db_utils.run_raw_sql(select_stmt)
    except Exception:
        return None
    if rows:
        return rows[0]
    else:
        return None
