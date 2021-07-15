from flask.wrappers import Response
from utils.db import DB_Utils
from flask import Flask, request
import endpoint_apis.location as loc_utils

from os import getenv

DEFAULT_RADIUS = 10     # 10 km

app = Flask(__name__)


@app.route('/create_user', methods=['POST'])
def create_user():
    return "NOT IMPLEMENTED YET"


@app.route('/get_user', methods=['GET'])
def get_user():
    return db_utils.run_raw_sql('SELECT * FROM USERS')


@app.route('/get_locations', methods=['GET'])
def get_locations():
    # TODO can store this information in a cache
    coordinates = request.args.get('coords').split(',')
    radius = request.args.get('radius')

    # TODO make this a function
    if not coordinates:
        return Response('The argument "coords" is required', status=400)
    try:
        lat = float(coordinates[0])
        long = float(coordinates[1])
        coordinates = [lat, long]
    except ValueError:
        return Response(
            'The argument "coords" is invalid. It must be two floats as '
            '`[lat],[long]`',
            status=400
        )

    if radius:
        try:
            radius = int(radius)
        except ValueError:
            radius = None

    return loc_utils.get_locations(db_utils, coordinates, radius)


@app.route('/get_location_info', methods=['GET'])
def get_location_info():
    location_id = request.args.get('location_id')

    if not location_id:
        return Response('The argument "location_id" is required', status=400)

    msg, status = loc_utils.get_location(db_utils, location_id)
    return Response(msg, status=status)


@app.route('/create_location', methods=['POST'])
def create_location():
    coordinates = request.args.get('coords').split(',')
    relative_loc = request.args.get('rel_loc')
    description = request.args.get('description')
    loc_type = request.args.get('loc_type')
    title = request.args.get('title')

    if not coordinates:
        return Response('The argument "coords" is required', status=400)
    if not title:
        return Response('The argument "title" is required', status=400)

    try:
        lat = float(coordinates[0])
        long = float(coordinates[1])
        coordinates = [lat, long]
    except ValueError:
        return Response(
            'The argument "coords" is invalid. It must be two floats as '
            '`[lat],[long]`',
            status=400
        )

    id = loc_utils.create_location(
        db_utils, coordinates, relative_loc, description, loc_type, title
    )
    return Response(id, status=200)   # TODO shouldn't always return 200


@app.route('/rate_location', methods=['POST'])
def rate_location():
    location_id = request.args.get('location_id')
    rating = request.args.get('rating')

    if not location_id:
        return Response('The argument "location_id" is required', status=400)
    if not rating:
        return Response('The argument "rating" is required', status=400)

    value_error = False
    try:
        rating = int(rating)
    except ValueError:
        value_error = True
    if value_error or rating < 1 or rating > 5:
        return Response(
            'The argument "ratings" is invalid. It must be an integer, where '
            '1 <= [rating] <= 5'
        )

    msg, status = loc_utils.rate_location(db_utils, location_id, rating)
    return Response(msg, status=status)


port = getenv('PORT', '8080')
db_utils = DB_Utils()
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(port))
