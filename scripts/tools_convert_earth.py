import json
from pathlib import Path

SRC = Path("data/earth/countries.geojson")
OUT = Path("data/earth/countries_render.json")

with SRC.open("r", encoding="utf-8") as f:
    geo = json.load(f)

countries = []

for feature in geo["features"]:
    props = feature.get("properties", {})
    geom = feature.get("geometry")

    if not geom:
        continue

    geometry = geom.get("coordinates", [])
    geom_type = geom.get("type")

    countries.append({
        "name": props.get("NAME") or props.get("ADMIN") or "UNKNOWN",
        "iso": props.get("ISO_A3") or "",
        "continent": props.get("CONTINENT") or "",
        "type": geom_type,
        "coordinates": geometry
    })

output = {
    "version": 1,
    "source": "Natural Earth 10m",
    "features": countries
}

with OUT.open("w", encoding="utf-8") as f:
    json.dump(
        output,
        f,
        separators=(",", ":"),
        ensure_ascii=False
    )

print(f"Converted {len(countries)} countries/features")
print(f"Output: {OUT}")
