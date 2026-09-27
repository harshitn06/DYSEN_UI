import QtQuick
import QtQuick.Window

Item {
    id: globe

    property real globeRotation: 0
    property real pulse: 0

    property real globeScale: 0.46

    // Smooth zoom target.
    // Wheel updates this target; the animation timer
    // eases the actual globe scale toward it.
    property real zoomTarget: 0.46
    property bool satellitesEnabled: true

    // =========================================================
    // DYSEN GLOBE EXPLORER V1
    // =========================================================

    property bool exploreActive: false
    property Item explorerHost: null

    property Item originalParent: null
    property real originalZ: 0
    property real originalScale: 0.46

    property real globeTilt: 0

    property real rotationVelocity: 0
    property real tiltVelocity: 0

    property real lastPointerX: 0
    property real lastPointerY: 0
    property bool pointerDragging: false

    property int selectedCountryIndex: -1
    property var selectedCountry: null
    property string selectedCountryName: ""
    property string countryDetails: ""

    property real projectionCenterRatio:
        (
            globe.exploreActive &&
            globe.selectedCountryIndex >= 0
        )
        ? 0.38
        : 0.50

    signal explorerOpened()
    signal explorerClosed()
    signal countrySelected(string name)

    // =========================================================
    // REAL EARTH DATA
    // =========================================================

    property var earthData: null
    property bool earthLoaded: false
    property string earthDataUrl: Qt.resolvedUrl(
        "../data/earth/countries_qml_balanced.json"
    )

    // =========================================================
    // ANIMATION
    // =========================================================

    Timer {

        interval: 16

        running: true

        repeat: true

        onTriggered: {

            if (!globe.exploreActive) {

                globe.globeRotation +=
                    0.55

            } else {

                // Controlled inertial rotation.
                // Much shorter than the old momentum.
                globe.globeRotation +=
                    globe.rotationVelocity

                globe.globeTilt +=
                    globe.tiltVelocity

                globe.rotationVelocity *=
                    0.82

                globe.tiltVelocity *=
                    0.78

                globe.globeTilt =
                    Math.max(
                        -34,
                        Math.min(
                            34,
                            globe.globeTilt
                        )
                    )

                if (
                    Math.abs(
                        globe.rotationVelocity
                    ) < 0.0005
                )
                    globe.rotationVelocity = 0

                if (
                    Math.abs(
                        globe.tiltVelocity
                    ) < 0.0004
                )
                    globe.tiltVelocity = 0
            }

            // Smooth zoom interpolation.
            globe.globeScale +=
                (
                    globe.zoomTarget -
                    globe.globeScale
                ) * 0.16

            if (
                Math.abs(
                    globe.zoomTarget -
                    globe.globeScale
                ) < 0.00015
            ) {

                globe.globeScale =
                    globe.zoomTarget
            }

            if (
                globe.globeRotation >= 360
            )
                globe.globeRotation -= 360

            if (
                globe.globeRotation < 0
            )
                globe.globeRotation += 360

            globe.pulse +=
                0.020

            earth.requestPaint()

            satelliteCanvas.requestPaint()
        }
    }

    // =========================================================
    // LOAD REAL NATURAL EARTH DATA
    // =========================================================

    Component.onCompleted: {
        loadEarthData()
    }

    function loadEarthData() {

        var xhr = new XMLHttpRequest()

        xhr.open(
            "GET",
            globe.earthDataUrl,
            false
        )

        try {
            xhr.send()
        } catch (e) {
            console.log(
                "DYSEN EARTH: failed to load:",
                globe.earthDataUrl,
                e
            )
            return
        }

        if (xhr.status !== 0 && xhr.status !== 200) {
            console.log(
                "DYSEN EARTH: HTTP status:",
                xhr.status
            )
            return
        }

        try {
            globe.earthData = JSON.parse(xhr.responseText)
            globe.earthLoaded = true

            console.log(
                "DYSEN EARTH: loaded",
                globe.earthData.features.length,
                "features"
            )

            earth.requestPaint()

        } catch (e2) {

            console.log(
                "DYSEN EARTH: JSON parse failed:",
                e2
            )
        }
    }

    // =========================================================
    // PROJECTION
    // =========================================================

    function deg(v) {
        return v * Math.PI / 180
    }

    function project(lon, lat, cx, cy, radius) {

        var lambda =
            deg(lon + globe.globeRotation)

        var phi =
            deg(lat)

        var cosPhi = Math.cos(phi)

        var x3 =
            cosPhi *
            Math.sin(lambda)

        var y3 =
            Math.sin(phi)

        var z3 =
            cosPhi *
            Math.cos(lambda)

        // ---------------------------------------------------------
        // Explorer vertical tilt.
        // With globeTilt = 0 the original projection is preserved.
        // ---------------------------------------------------------

        var tilt =
            deg(globe.globeTilt)

        var cosTilt =
            Math.cos(tilt)

        var sinTilt =
            Math.sin(tilt)

        var rotatedY =
            y3 * cosTilt -
            z3 * sinTilt

        var rotatedZ =
            y3 * sinTilt +
            z3 * cosTilt

        // Back side
        if (rotatedZ <= -0.02)
            return null

        return {
            x: cx + radius * x3,
            y: cy - radius * rotatedY,
            z: rotatedZ
        }
    }

    // =========================================================
    // DRAW REAL COUNTRY RING
    //
    // A ring is an array of:
    // [longitude, latitude]
    //
    // We split it whenever geometry disappears behind
    // the horizon.
    // =========================================================

    function drawRing(
        ctx,
        ring,
        cx,
        cy,
        radius,
        fillLand,
        strokeLand
    ) {

        if (!ring || ring.length < 3)
            return

        var segments = []
        var current = []

        for (var i = 0; i < ring.length; i++) {

            var point = ring[i]

            if (!point || point.length < 2)
                continue

            var p = project(
                point[0],
                point[1],
                cx,
                cy,
                radius
            )

            if (p) {

                current.push(p)

            } else {

                if (current.length >= 2)
                    segments.push(current)

                current = []
            }
        }

        if (current.length >= 2)
            segments.push(current)

        for (
            var s = 0;
            s < segments.length;
            s++
        ) {

            var segment = segments[s]

            if (segment.length < 2)
                continue

            ctx.beginPath()

            ctx.moveTo(
                segment[0].x,
                segment[0].y
            )

            for (
                var j = 1;
                j < segment.length;
                j++
            ) {

                ctx.lineTo(
                    segment[j].x,
                    segment[j].y
                )
            }

            /*
             * Closing a visible section gives us a clean
             * geographic surface patch while the outer
             * globe clip prevents anything escaping.
             */
            ctx.closePath()

            if (fillLand) {

                ctx.fillStyle =
                    createLandGradient(
                        ctx,
                        cx,
                        cy,
                        radius
                    )

                ctx.fill()
            }

            if (strokeLand) {

                ctx.strokeStyle =
                    "rgba(145,220,195,.48)"

                ctx.lineWidth = .65

                ctx.stroke()
            }
        }
    }

    // =========================================================
    // LAND GRADIENT
    // =========================================================

    function createLandGradient(
        ctx,
        cx,
        cy,
        radius
    ) {

        var land =
            ctx.createLinearGradient(
                cx,
                cy - radius,
                cx,
                cy + radius
            )

        land.addColorStop(
            0,
            "rgba(112,166,136,.94)"
        )

        land.addColorStop(
            .42,
            "rgba(60,116,96,.91)"
        )

        land.addColorStop(
            1,
            "rgba(22,57,51,.86)"
        )

        return land
    }

    // =========================================================
    // COUNTRY METADATA HELPERS
    // =========================================================

    function countryValue(
        feature,
        keys,
        fallback
    ) {

        if (!feature)
            return fallback

        var source =
            feature.properties
            ? feature.properties
            : feature

        for (
            var i = 0;
            i < keys.length;
            i++
        ) {

            var key = keys[i]

            if (
                source[key] !== undefined &&
                source[key] !== null &&
                String(source[key]).length > 0
            ) {
                return source[key]
            }
        }

        return fallback
    }

    function countryNameFor(feature) {

        return String(
            countryValue(
                feature,
                [
                    "n",
                    "name",
                    "NAME",
                    "NAME_EN",
                    "ADMIN",
                    "admin",
                    "country"
                ],
                "UNKNOWN TERRITORY"
            )
        )
    }

    function buildCountryDetails(feature) {

        if (!feature)
            return ""

        var lines = []

        lines.push(
            "COUNTRY     : " +
            countryNameFor(feature)
        )

        lines.push(
            "ISO         : " +
            countryValue(
                feature,
                [
                    "iso",
                    "ISO_A3",
                    "ISO3",
                    "iso_a3",
                    "ADM0_A3"
                ],
                "—"
            )
        )

        lines.push(
            "CAPITAL     : " +
            countryValue(
                feature,
                [
                    "capital",
                    "CAPITAL",
                    "capital_city"
                ],
                "—"
            )
        )

        lines.push(
            "REGION      : " +
            countryValue(
                feature,
                [
                    "region",
                    "REGION",
                    "continent"
                ],
                "—"
            )
        )

        lines.push(
            "SUB-REGION  : " +
            countryValue(
                feature,
                [
                    "subregion",
                    "SUBREGION",
                    "sub_region"
                ],
                "—"
            )
        )

        lines.push(
            "POPULATION  : " +
            countryValue(
                feature,
                [
                    "population",
                    "POP_EST",
                    "pop_est",
                    "POPULATION"
                ],
                "—"
            )
        )

        lines.push(
            "AREA        : " +
            countryValue(
                feature,
                [
                    "area",
                    "AREA",
                    "AREA_KM2",
                    "area_km2"
                ],
                "—"
            )
        )

        lines.push(
            "CURRENCY    : " +
            countryValue(
                feature,
                [
                    "currency",
                    "CURRENCY",
                    "currency_name"
                ],
                "—"
            )
        )

        lines.push(
            "LANGUAGE    : " +
            countryValue(
                feature,
                [
                    "language",
                    "LANGUAGES",
                    "languages"
                ],
                "—"
            )
        )

        lines.push(
            "COORDINATES : " +
            countryValue(
                feature,
                [
                    "coordinates",
                    "COORDINATES",
                    "latlon"
                ],
                "—"
            )
        )

        return lines.join("\n")
    }

    // =========================================================
    // COUNTRY HIT TEST
    // =========================================================

    function projectHitPoint(
        lon,
        lat,
        cx,
        cy,
        radius
    ) {

        var lambda =
            deg(lon + globe.globeRotation)

        var phi =
            deg(lat)

        var cosPhi =
            Math.cos(phi)

        var x3 =
            cosPhi *
            Math.sin(lambda)

        var y3 =
            Math.sin(phi)

        var z3 =
            cosPhi *
            Math.cos(lambda)

        var tilt =
            deg(globe.globeTilt)

        var cosTilt =
            Math.cos(tilt)

        var sinTilt =
            Math.sin(tilt)

        var rotatedY =
            y3 * cosTilt -
            z3 * sinTilt

        var rotatedZ =
            y3 * sinTilt +
            z3 * cosTilt

        if (rotatedZ <= -0.02)
            return null

        return {
            x: cx + radius * x3,
            y: cy - radius * rotatedY
        }
    }

    function pointInRing(
        px,
        py,
        ring,
        cx,
        cy,
        radius
    ) {

        if (!ring || ring.length < 3)
            return false

        var inside = false
        var previous = null

        for (
            var i = 0;
            i < ring.length;
            i++
        ) {

            var raw = ring[i]

            if (!raw || raw.length < 2) {
                previous = null
                continue
            }

            var current =
                projectHitPoint(
                    raw[0],
                    raw[1],
                    cx,
                    cy,
                    radius
                )

            if (!current) {
                previous = null
                continue
            }

            if (!previous) {
                previous = current
                continue
            }

            var hit =
                (
                    (
                        current.y > py
                    ) !==
                    (
                        previous.y > py
                    )
                ) &&
                (
                    px <
                    (
                        previous.x - current.x
                    ) *
                    (
                        py - current.y
                    ) /
                    (
                        previous.y - current.y
                    ) +
                    current.x
                )

            if (hit)
                inside = !inside

            previous = current
        }

        return inside
    }

    function countryAt(xPos, yPos) {

        if (
            !globe.earthLoaded ||
            !globe.earthData ||
            !globe.earthData.features
        ) {
            return -1
        }

        var cx =
            width *
            globe.projectionCenterRatio

        var cy =
            height / 2

        var radius =
            Math.min(width, height) *
            globe.globeScale

        var dx =
            xPos - cx

        var dy =
            yPos - cy

        if (
            Math.sqrt(
                dx * dx +
                dy * dy
            ) > radius
        ) {
            return -1
        }

        var features =
            globe.earthData.features

        for (
            var f = 0;
            f < features.length;
            f++
        ) {

            var feature =
                features[f]

            if (!feature || !feature.p)
                continue

            for (
                var p = 0;
                p < feature.p.length;
                p++
            ) {

                var polygon =
                    feature.p[p]

                if (
                    polygon &&
                    polygon.length &&
                    pointInRing(
                        xPos,
                        yPos,
                        polygon[0],
                        cx,
                        cy,
                        radius
                    )
                ) {
                    return f
                }
            }
        }

        return -1
    }

    function selectCountryAt(
        xPos,
        yPos
    ) {

        var index =
            countryAt(
                xPos,
                yPos
            )

        if (index < 0)
            return

        var feature =
            globe.earthData.features[index]

        globe.selectedCountryIndex =
            index

        globe.selectedCountry =
            feature

        globe.selectedCountryName =
            countryNameFor(feature)

        globe.countryDetails =
            buildCountryDetails(feature)

        globe.countrySelected(
            globe.selectedCountryName
        )

        earth.requestPaint()
    }

    function drawSelectedRing(
        ctx,
        ring,
        cx,
        cy,
        radius,
        accent
    ) {

        if (!ring || ring.length < 3)
            return

        var current = []

        var rr =
            Math.round(
                accent.r * 255
            )

        var gg =
            Math.round(
                accent.g * 255
            )

        var bb =
            Math.round(
                accent.b * 255
            )

        function paintSegment(points) {

            if (points.length < 2)
                return

            ctx.beginPath()

            ctx.moveTo(
                points[0].x,
                points[0].y
            )

            for (
                var j = 1;
                j < points.length;
                j++
            ) {
                ctx.lineTo(
                    points[j].x,
                    points[j].y
                )
            }

            ctx.closePath()

            ctx.fillStyle =
                "rgba(" +
                rr + "," +
                gg + "," +
                bb +
                ",.18)"

            ctx.fill()

            ctx.strokeStyle =
                "rgba(" +
                rr + "," +
                gg + "," +
                bb +
                ",.95)"

            ctx.lineWidth = 1.8

            ctx.stroke()
        }

        for (
            var i = 0;
            i < ring.length;
            i++
        ) {

            var point =
                ring[i]

            if (!point || point.length < 2)
                continue

            var projected =
                project(
                    point[0],
                    point[1],
                    cx,
                    cy,
                    radius
                )

            if (!projected) {

                paintSegment(
                    current
                )

                current = []

                continue
            }

            current.push(
                projected
            )
        }

        paintSegment(current)
    }

    function drawSelectedCountry(
        ctx,
        cx,
        cy,
        radius
    ) {

        if (
            globe.selectedCountryIndex < 0 ||
            !globe.earthData ||
            !globe.earthData.features
        )
            return

        var feature =
            globe.earthData.features[
                globe.selectedCountryIndex
            ]

        if (!feature || !feature.p)
            return

        var accent =
            Window.window
            ? Window.window.dysenAccent
            : "#00F6FF"

        for (
            var p = 0;
            p < feature.p.length;
            p++
        ) {

            var polygon =
                feature.p[p]

            if (
                !polygon ||
                polygon.length === 0
            )
                continue

            drawSelectedRing(
                ctx,
                polygon[0],
                cx,
                cy,
                radius,
                accent
            )
        }
    }

    // =========================================================
    // COUNTRY RENDERER
    // =========================================================

    function drawCountries(
        ctx,
        cx,
        cy,
        radius
    ) {

        if (
            !globe.earthLoaded ||
            !globe.earthData ||
            !globe.earthData.features
        )
            return

        var features =
            globe.earthData.features

        for (
            var f = 0;
            f < features.length;
            f++
        ) {

            var feature = features[f]

            if (!feature || !feature.p)
                continue

            var polygons =
                feature.p

            for (
                var p = 0;
                p < polygons.length;
                p++
            ) {

                var polygon =
                    polygons[p]

                if (!polygon)
                    continue

                /*
                 * First ring is normally the exterior.
                 * Remaining rings represent holes.
                 */
                if (polygon.length > 0) {

                    drawRing(
                        ctx,
                        polygon[0],
                        cx,
                        cy,
                        radius,
                        true,
                        true
                    )

                    /*
                     * Draw interior rings using ocean colour.
                     * This keeps large lakes / holes visually clean.
                     */
                    for (
                        var h = 1;
                        h < polygon.length;
                        h++
                    ) {

                        drawRing(
                            ctx,
                            polygon[h],
                            cx,
                            cy,
                            radius,
                            false,
                            true
                        )
                    }
                }
            }
        }
    }

    // =========================================================
    // MAIN EARTH
    // =========================================================

    Canvas {
        id: earth

        anchors.fill: parent

        antialiasing: true

        onPaint: {

            var ctx = getContext("2d")
            ctx.reset()

            var cx = width * globe.projectionCenterRatio
            var cy = height / 2

            var radius =
                Math.min(width, height) *
                globe.globeScale

            // =================================================
            // SPACE
            // =================================================

            for (
                var star = 0;
                star < 65;
                star++
            ) {

                var sx =
                    (star * 137.37) % width

                var sy =
                    (star * 79.91) % height

                var alpha =
                    .12 +
                    .10 *
                    Math.sin(
                        globe.pulse + star
                    )

                ctx.fillStyle =
                    "rgba(150,225,240," +
                    alpha +
                    ")"

                ctx.beginPath()

                ctx.arc(
                    sx,
                    sy,
                    star % 7 === 0 ? 1 : .45,
                    0,
                    Math.PI * 2
                )

                ctx.fill()
            }

            // =================================================
            // ATMOSPHERE
            // =================================================

            var atmosphere =
                ctx.createRadialGradient(
                    cx - radius * .25,
                    cy - radius * .30,
                    radius * .30,
                    cx,
                    cy,
                    radius * 1.22
                )

            atmosphere.addColorStop(
                0,
                "rgba(35,125,150,0)"
            )

            atmosphere.addColorStop(
                .70,
                "rgba(50,180,205,.025)"
            )

            atmosphere.addColorStop(
                .90,
                "rgba(75,215,235,.14)"
            )

            atmosphere.addColorStop(
                1,
                "rgba(75,215,235,0)"
            )

            ctx.fillStyle = atmosphere

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius * 1.22,
                0,
                Math.PI * 2
            )

            ctx.fill()

            // =================================================
            // OCEAN
            // =================================================

            var ocean =
                ctx.createRadialGradient(
                    cx - radius * .35,
                    cy - radius * .40,
                    radius * .05,
                    cx,
                    cy,
                    radius
                )

            ocean.addColorStop(
                0,
                "#194a58"
            )

            ocean.addColorStop(
                .45,
                "#0d2b35"
            )

            ocean.addColorStop(
                .78,
                "#06171e"
            )

            ocean.addColorStop(
                1,
                "#02080c"
            )

            ctx.fillStyle = ocean

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius,
                0,
                Math.PI * 2
            )

            ctx.fill()

            // =================================================
            // EARTH CLIP
            // =================================================

            ctx.save()

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius - 1,
                0,
                Math.PI * 2
            )

            ctx.clip()

            // =================================================
            // LONGITUDE GRID
            // =================================================

            for (
                var longitude = -180;
                longitude <= 180;
                longitude += 20
            ) {

                ctx.beginPath()

                var started = false

                for (
                    var latitude = -90;
                    latitude <= 90;
                    latitude += 3
                ) {

                    var p =
                        project(
                            longitude,
                            latitude,
                            cx,
                            cy,
                            radius
                        )

                    if (!p) {

                        started = false
                        continue
                    }

                    if (!started) {

                        ctx.moveTo(
                            p.x,
                            p.y
                        )

                        started = true

                    } else {

                        ctx.lineTo(
                            p.x,
                            p.y
                        )
                    }
                }

                ctx.strokeStyle =
                    "rgba(95,190,210,.16)"

                ctx.lineWidth = .45

                ctx.stroke()
            }

            // =================================================
            // LATITUDE GRID
            // =================================================

            for (
                var latitude2 = -60;
                latitude2 <= 60;
                latitude2 += 20
            ) {

                ctx.beginPath()

                var started2 = false

                for (
                    var longitude2 = -180;
                    longitude2 <= 180;
                    longitude2 += 3
                ) {

                    var p2 =
                        project(
                            longitude2,
                            latitude2,
                            cx,
                            cy,
                            radius
                        )

                    if (!p2) {

                        started2 = false
                        continue
                    }

                    if (!started2) {

                        ctx.moveTo(
                            p2.x,
                            p2.y
                        )

                        started2 = true

                    } else {

                        ctx.lineTo(
                            p2.x,
                            p2.y
                        )
                    }
                }

                ctx.strokeStyle =
                    "rgba(95,190,210,.13)"

                ctx.lineWidth = .45

                ctx.stroke()
            }

            // =================================================
            // REAL COUNTRIES
            // =================================================

            drawCountries(
                ctx,
                cx,
                cy,
                radius
            )

            drawSelectedCountry(
                ctx,
                cx,
                cy,
                radius
            )

            // =================================================
            // CITY LIGHTS
            // =================================================

            var cities = [
                [-74,40],
                [-118,34],
                [-99,19],
                [-46,-23],
                [2,48],
                [13,52],
                [31,30],
                [37,55],
                [77,28],
                [103,1],
                [116,40],
                [139,35],
                [151,-33],
                [18,-34],
                [72,19]
            ]

            for (
                var city = 0;
                city < cities.length;
                city++
            ) {

                var cp =
                    project(
                        cities[city][0],
                        cities[city][1],
                        cx,
                        cy,
                        radius
                    )

                if (!cp)
                    continue

                ctx.fillStyle =
                    "rgba(255,220,125,.16)"

                ctx.beginPath()

                ctx.arc(
                    cp.x,
                    cp.y,
                    4,
                    0,
                    Math.PI * 2
                )

                ctx.fill()

                ctx.fillStyle =
                    "#e6d38b"

                ctx.beginPath()

                ctx.arc(
                    cp.x,
                    cp.y,
                    .8,
                    0,
                    Math.PI * 2
                )

                ctx.fill()
            }

            // =================================================
            // MOVING SCAN LINE
            // =================================================

            var scanLongitude =
                -180 +
                (globe.globeRotation * 1.8) % 360

            for (
                var scanLat = -75;
                scanLat <= 75;
                scanLat += 2
            ) {

                var scan =
                    project(
                        scanLongitude,
                        scanLat,
                        cx,
                        cy,
                        radius
                    )

                if (!scan)
                    continue

                ctx.fillStyle =
                    "rgba(120,240,250,.45)"

                ctx.beginPath()

                ctx.arc(
                    scan.x,
                    scan.y,
                    1,
                    0,
                    Math.PI * 2
                )

                ctx.fill()
            }

            // =================================================
            // NIGHT SIDE
            // =================================================

            var night =
                ctx.createRadialGradient(
                    cx + radius * .50,
                    cy,
                    radius * .15,
                    cx + radius * .65,
                    cy,
                    radius * 1.1
                )

            night.addColorStop(
                0,
                "rgba(0,0,0,0)"
            )

            night.addColorStop(
                .50,
                "rgba(0,0,0,.20)"
            )

            night.addColorStop(
                1,
                "rgba(0,0,0,.72)"
            )

            ctx.fillStyle = night

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius,
                0,
                Math.PI * 2
            )

            ctx.fill()

            ctx.restore()

            // =================================================
            // EARTH OUTLINE
            // =================================================

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius,
                0,
                Math.PI * 2
            )

            ctx.strokeStyle =
                "rgba(135,235,250,.65)"

            ctx.lineWidth = 1.15

            ctx.stroke()

            // =================================================
            // LIGHT RIM
            // =================================================

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius + 2,
                -2.5,
                -.45
            )

            ctx.strokeStyle =
                "rgba(160,240,250,.75)"

            ctx.lineWidth = 1.4

            ctx.stroke()

            // =================================================
            // EQUATOR HIGHLIGHT
            // =================================================

            ctx.beginPath()

            ctx.ellipse(
                cx,
                cy,
                radius,
                radius * .20,
                0,
                0,
                Math.PI * 2
            )

            ctx.strokeStyle =
                "rgba(105,215,230,.12)"

            ctx.lineWidth = .7

            ctx.stroke()
        }

        Component.onCompleted: {
            requestPaint()
        }
    }

    // =========================================================
    // EXPLORER MODE
    // =========================================================

    function enterExplorer() {

        console.log(
            "DYSEN GLOBE: enterExplorer() CALLED",
            "explorerHost=", globe.explorerHost
        )

        if (globe.exploreActive)
            return

        if (!globe.explorerHost) {
            console.log(
                "DYSEN GLOBE: explorerHost missing"
            )
            return
        }

        globe.originalParent =
            globe.parent

        globe.originalZ =
            globe.z

        globe.originalScale =
            globe.globeScale

        globe.exploreActive = true

        console.log(
            "DYSEN GLOBE: exploreActive = TRUE"
        )

        globe.selectedCountryIndex = -1
        globe.selectedCountry = null
        globe.selectedCountryName = ""
        globe.countryDetails = ""

        globe.rotationVelocity = 0
        globe.tiltVelocity = 0
        globe.globeTilt = 0

        globe.globeScale = 0.52

        globe.parent =
            globe.explorerHost

        globe.anchors.fill =
            globe.explorerHost

        globe.z = 500000

        globe.explorerOpened()

        earth.requestPaint()
        satelliteCanvas.requestPaint()
    }

    function exitExplorer() {

        if (!globe.exploreActive)
            return

        globe.exploreActive = false

        globe.selectedCountryIndex = -1
        globe.selectedCountry = null
        globe.selectedCountryName = ""
        globe.countryDetails = ""

        globe.rotationVelocity = 0
        globe.tiltVelocity = 0
        globe.globeTilt = 0

        globe.globeScale =
            globe.originalScale

        globe.zoomTarget =
            globe.originalScale

        globe.z =
            globe.originalZ

        if (globe.originalParent) {

            globe.parent =
                globe.originalParent

            globe.anchors.fill =
                globe.originalParent
        }

        globe.explorerClosed()

        earth.requestPaint()
        satelliteCanvas.requestPaint()
    }

    // =========================================================
    // EXPLORER INPUT
    // =========================================================

    // =========================================================
    // SATELLITE ORBITS + SATELLITES
    // =========================================================

    Canvas {
        id: satelliteCanvas

        anchors.fill: parent

        visible: globe.satellitesEnabled

        onPaint: {

            var ctx = getContext("2d")
            ctx.reset()

            var cx = width * globe.projectionCenterRatio
            var cy = height / 2

            var radius =
                Math.min(width, height) *
                globe.globeScale

            // =================================================
            // ORBIT 1
            // =================================================

            ctx.save()

            ctx.translate(cx, cy)
            ctx.rotate(-.22)

            ctx.beginPath()

            ctx.ellipse(
                -radius * 1.28,
                -radius * .28,
                radius * 2.56,
                radius * .56,
                0,
                0,
                Math.PI * 2
            )

            ctx.strokeStyle =
                "rgba(90,210,230,.28)"

            ctx.lineWidth = .7

            ctx.stroke()

            ctx.restore()

            // =================================================
            // ORBIT 2
            // =================================================

            ctx.save()

            ctx.translate(cx, cy)
            ctx.rotate(.65)

            ctx.beginPath()

            ctx.ellipse(
                -radius * 1.20,
                -radius * .20,
                radius * 2.40,
                radius * .40,
                0,
                0,
                Math.PI * 2
            )

            ctx.strokeStyle =
                "rgba(100,215,235,.16)"

            ctx.lineWidth = .6

            ctx.stroke()

            ctx.restore()

            // =================================================
            // SATELLITES
            // =================================================

            for (
                var s = 0;
                s < 5;
                s++
            ) {

                var angle =
                    globe.globeRotation *
                    Math.PI / 180 *
                    (.55 + s * .13) +
                    s * 1.25

                var orbit =
                    radius *
                    (1.05 + s * .055)

                var sx =
                    cx +
                    Math.cos(angle) *
                    orbit

                var sy =
                    cy +
                    Math.sin(angle) *
                    orbit *
                    .34

                ctx.fillStyle =
                    "rgba(110,235,250,.18)"

                ctx.beginPath()

                ctx.arc(
                    sx,
                    sy,
                    5,
                    0,
                    Math.PI * 2
                )

                ctx.fill()

                ctx.fillStyle =
                    "#b9f6fc"

                ctx.fillRect(
                    sx - 2,
                    sy - 2,
                    4,
                    4
                )

                ctx.strokeStyle =
                    "rgba(135,235,250,.85)"

                ctx.lineWidth = .8

                ctx.beginPath()

                ctx.moveTo(
                    sx - 8,
                    sy
                )

                ctx.lineTo(
                    sx - 3,
                    sy
                )

                ctx.moveTo(
                    sx + 3,
                    sy
                )

                ctx.lineTo(
                    sx + 8,
                    sy
                )

                ctx.stroke()
            }
        }

        Component.onCompleted: {
            requestPaint()
        }
    }

    // =========================================================
    // HUD
    // =========================================================

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        text: "EARTH / SATELLITE VIEW"

        color: Window.window ? Window.window.dysenAccent : "#3A7F88"

        font.family: "monospace"
        font.pixelSize: 8
        font.letterSpacing: 1.5
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        text:
            "ROT " +
            Math.floor(globe.globeRotation) +
            "°"

        color: Window.window ? Window.window.dysenAccent : "#2C6973"

        font.family: "monospace"
        font.pixelSize: 8
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        text: "SAT // 05"

        color: Window.window ? Window.window.dysenAccent : "#2C6973"

        font.family: "monospace"
        font.pixelSize: 8
    }

    // =========================================================
    // EXPLORER BACKDROP
    // =========================================================

    Rectangle {
        id: explorerBackdrop

        anchors.fill: parent

        visible:
            globe.exploreActive

        z: -100

        color: "#000000"
    }

    // =========================================================
    // EXPLORER INPUT
    // =========================================================

    MouseArea {
        id: explorerMouse

        anchors.fill: parent

        hoverEnabled: true

        acceptedButtons:
            Qt.LeftButton

        preventStealing: true

        cursorShape:
            globe.exploreActive
            ? (
                globe.pointerDragging
                ? Qt.ClosedHandCursor
                : Qt.OpenHandCursor
            )
            : Qt.ArrowCursor

        onPressed: function(mouse) {

            if (!globe.exploreActive)
                return

            globe.pointerDragging = true

            globe.lastPointerX =
                mouse.x

            globe.lastPointerY =
                mouse.y

            globe.rotationVelocity = 0
            globe.tiltVelocity = 0
        }

        onPositionChanged: function(mouse) {

            if (
                !pressed ||
                !globe.exploreActive ||
                !globe.pointerDragging
            )
                return

            var dx =
                mouse.x -
                globe.lastPointerX

            var dy =
                mouse.y -
                globe.lastPointerY

            globe.lastPointerX =
                mouse.x

            globe.lastPointerY =
                mouse.y

            if (
                Math.abs(dx) < 0.05 &&
                Math.abs(dy) < 0.05
            )
                return

            // Calm direct movement.
            // Small hand movement no longer
            // throws the whole planet around.
            globe.globeRotation +=
                dx * 0.14

            globe.globeTilt +=
                dy * 0.070

            globe.globeTilt =
                Math.max(
                    -34,
                    Math.min(
                        34,
                        globe.globeTilt
                    )
                )

            // Short, capped release momentum.
            globe.rotationVelocity =
                globe.rotationVelocity *
                0.50 +
                dx * 0.024

            globe.tiltVelocity =
                globe.tiltVelocity *
                0.50 +
                dy * 0.006

            globe.rotationVelocity =
                Math.max(
                    -0.13,
                    Math.min(
                        0.13,
                        globe.rotationVelocity
                    )
                )

            globe.tiltVelocity =
                Math.max(
                    -0.045,
                    Math.min(
                        0.045,
                        globe.tiltVelocity
                    )
                )

            // Do not force another paint here.
            // The 60 FPS timer owns the render cadence.
        }

        onReleased: {
            globe.pointerDragging = false
        }

        onCanceled: {
            globe.pointerDragging = false
        }

        onClicked: function(mouse) {

            if (!globe.exploreActive)
                return

            territoryOverlay.handleSelection(
                mouse.x,
                mouse.y
            )
        }

        onDoubleClicked: function(mouse) {

            console.log(
                "DYSEN GLOBE INPUT: DOUBLECLICK",
                "x=", mouse.x,
                "y=", mouse.y,
                "exploreActive=", globe.exploreActive
            )

            if (!globe.exploreActive) {

                var cx =
                    width *
                    globe.projectionCenterRatio

                var cy =
                    height / 2

                var radius =
                    Math.min(
                        width,
                        height
                    ) *
                    globe.globeScale

                var dx =
                    mouse.x - cx

                var dy =
                    mouse.y - cy

                if (
                    Math.sqrt(
                        dx * dx +
                        dy * dy
                    ) <= radius
                ) {
                    globe.enterExplorer()
                }

                return
            }

            territoryOverlay.handleSelection(
                mouse.x,
                mouse.y
            )
        }

        onWheel: function(wheel) {

            if (
                !globe.exploreActive
            )
                return

            var delta =
                wheel.angleDelta.y

            if (
                !delta &&
                wheel.pixelDelta
            )
                delta =
                    wheel.pixelDelta.y

            if (!delta)
                return

            // Tiny target changes.
            // The timer performs the actual smooth motion.
            var steps =
                delta / 120.0

            var factor =
                Math.pow(
                    1.022,
                    steps
                )

            globe.zoomTarget =
                Math.max(
                    0.28,
                    Math.min(
                        0.86,
                        globe.zoomTarget *
                        factor
                    )
                )

            wheel.accepted =
                true
        }
    }

    // =========================================================
    // EXPLORER HEADER
    // =========================================================

    Rectangle {
        id: explorerHeader

        visible:
            globe.exploreActive

        x: 28
        y: 24

        width: 360
        height: 58

        color: "#050B10"

        border.width: 1

        border.color:
            Window.window
            ? Window.window.dysenAccent
            : "#00F6FF"

        z: 50

        Column {
            anchors.fill: parent

            anchors.leftMargin: 16
            anchors.rightMargin: 10

            anchors.topMargin: 10

            spacing: 4

            Text {
                text:
                    "DYSEN // WORLD EXPLORER"

                color:
                    Window.window
                    ? Window.window.dysenAccent
                    : "#00F6FF"

                font.family: "monospace"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            Text {
                text:
                    "DRAG ROTATE   •   SCROLL ZOOM   •   CLICK SELECT"

                color: "#78929A"

                font.family: "monospace"
                font.pixelSize: 8
            }
        }
    }

    // =========================================================
    // CLOSE
    // =========================================================

    Rectangle {
        id: explorerClose

        visible:
            globe.exploreActive

        anchors.right:
            parent.right

        anchors.top:
            parent.top

        anchors.rightMargin: 28
        anchors.topMargin: 24

        width: 96
        height: 34

        color: "#050B10"

        border.width: 1

        border.color:
            Window.window
            ? Window.window.dysenAccentDim
            : "#007483"

        z: 60

        Text {
            anchors.centerIn: parent

            text: "ESC  CLOSE"

            color:
                Window.window
                ? Window.window.dysenAccent
                : "#00F6FF"

            font.family: "monospace"
            font.pixelSize: 8
            font.bold: true
            font.letterSpacing: 1.1
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                globe.exitExplorer()
        }
    }

    // =========================================================
    // COUNTRY PANEL
    // =========================================================



    // =========================================================
    // ESC
    // =========================================================

    GlobeTerritoryOverlay {

        id: territoryOverlay

        objectName:
            "globeTerritoryOverlay"

        anchors.fill:
            parent

        globeRoot:
            globe

    }

    Shortcut {
        sequence: "Esc"

        enabled:
            globe.exploreActive

        onActivated:
            globe.exitExplorer()
    }

}
