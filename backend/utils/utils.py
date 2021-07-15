from math import cos


def clamp(value, min_value, max_value):
    return max(min_value, min(max_value, value))


def approx_coord_range(coords, distance_km):
    # TODO include coord wrapping in here (-90 to 90, -180 to 180)
    # approx 110.574 km / degree
    lat_change = lat_km_to_deg(distance_km)
    # approx 111.32 * cos(lat) / degree
    long_change = long_km_to_deg(coords, distance_km)

    min_lat = coords[0] - lat_change
    max_lat = coords[0] + lat_change

    min_long = coords[1] - long_change
    max_long = coords[1] + long_change
    return min_lat, max_lat, min_long, max_long


def lat_km_to_deg(distance_km):
    return distance_km / 110.574


def long_km_to_deg(coords, distance_km):
    return distance_km / (111.32 * cos(coords[0]))
