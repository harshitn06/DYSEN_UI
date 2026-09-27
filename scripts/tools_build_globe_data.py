import json
import math
import os
from pathlib import Path

SRC = Path("data/earth/countries_render.json")
OUT = Path("data/earth/countries_qml_balanced.json")


# =========================================================
# DOUGLAS-PEUCKER
# =========================================================

def perpendicular_distance(point, start, end):
    x, y = point
    x1, y1 = start
    x2, y2 = end

    dx = x2 - x1
    dy = y2 - y1

    if dx == 0 and dy == 0:
        return math.hypot(x - x1, y - y1)

    t = (
        (x - x1) * dx +
        (y - y1) * dy
    ) / (dx * dx + dy * dy)

    t = max(0.0, min(1.0, t))

    px = x1 + t * dx
    py = y1 + t * dy

    return math.hypot(x - px, y - py)


def simplify(points, tolerance):
    if len(points) <= 3:
        return points

    start = points[0]
    end = points[-1]

    max_distance = 0
    index = 0

    for i in range(1, len(points) - 1):
        distance = perpendicular_distance(
            points[i],
            start,
            end
        )

        if distance > max_distance:
            index = i
            max_distance = distance

    if max_distance > tolerance:

        left = simplify(
            points[:index + 1],
            tolerance
        )

        right = simplify(
            points[index:],
            tolerance
        )

        return left[:-1] + right

    return [start, end]


# =========================================================
# RING CLEANUP
# =========================================================

def clean_ring(ring):

    points = []

    for point in ring:

        if len(point) < 2:
            continue

        points.append([
            float(point[0]),
            float(point[1])
        ])

    if len(points) < 3:
        return []

    # Closed polygon handling
    closed = points[0] == points[-1]

    if closed:
        work = points[:-1]
    else:
        work = points

    # Balanced tolerance.
    # Lower = more detail.
    # Higher = more aggressive simplification.
    simplified = simplify(
        work,
        0.030
    )

    # Restore closure
    if simplified[0] != simplified[-1]:
        simplified.append(simplified[0])

    return [
        [
            round(p[0], 3),
            round(p[1], 3)
        ]
        for p in simplified
    ]


def clean_polygon(poly):

    result = []

    for ring in poly:

        if len(ring) < 3:
            continue

        cleaned = clean_ring(ring)

        if len(cleaned) >= 4:
            result.append(cleaned)

    return result


# =========================================================
# BUILD
# =========================================================

with SRC.open("r", encoding="utf-8") as f:
    data = json.load(f)


features = []

for feature in data["features"]:

    polygons = []

    if feature["type"] == "Polygon":

        polygon = clean_polygon(
            feature["coordinates"]
        )

        if polygon:
            polygons.append(polygon)

    elif feature["type"] == "MultiPolygon":

        for polygon_data in feature["coordinates"]:

            polygon = clean_polygon(
                polygon_data
            )

            if polygon:
                polygons.append(polygon)

    if polygons:

        features.append({
            "n": feature["name"],
            "i": feature["iso"],
            "c": feature["continent"],
            "p": polygons
        })


output = {
    "v": 3,
    "features": features
}


with OUT.open("w", encoding="utf-8") as f:

    json.dump(
        output,
        f,
        separators=(",", ":"),
        ensure_ascii=False
    )


# =========================================================
# STATS
# =========================================================

points = 0
polygons = 0
rings = 0

for feature in features:

    for polygon in feature["p"]:

        polygons += 1

        for ring in polygon:

            rings += 1
            points += len(ring)


size_mb = OUT.stat().st_size / 1024 / 1024


print()
print("========== BALANCED EARTH DATA ==========")
print("Features :", len(features))
print("Polygons :", polygons)
print("Rings    :", rings)
print("Points   :", points)
print("File     :", round(size_mb, 2), "MB")
print("=========================================")
