import QtQuick
import QtQuick.Window

Item {

    id: overlay

    property Item globeRoot: null

    property var countryMeta: []
    property var stateData: null

    property bool countryMetaLoaded: false
    property bool stateLoaded: false

    // ============================================================
    // INFO VISUAL TOKENS
    // ============================================================

    property color infoTitleColor: "#F8FFFF"
    property color infoPrimaryColor: "#F2FCFF"
    property color infoSecondaryColor: "#D5EEF2"
    property color infoDataColor: "#EAF8FA"
    property color infoMutedColor: "#9CC3C8"
    property color infoOutlineColor: "#001216"

    property string selectedKind: ""
    property string selectedName: ""

    property var selectedCountryMeta: null
    property var selectedState: null

    property string primaryInfo: ""
    property string secondaryInfo: ""
    property string economyInfo: ""
    property string liveInfo: ""

    property bool liveLoading: false

    property string livePopulation: "—"
    property string liveGdp: "—"
    property string liveGdpPc: "—"
    property string liveInflation: "—"
    property string liveUnemployment: "—"
    property string liveInternet: "—"
    property string liveLife: "—"

    property string liveCapital: "—"
    property string liveWeather: "—"
    property string liveFx: "—"
    property string liveYear: ""

    anchors.fill: parent

    z: 800000

    // =========================================================
    // DATA LOADING
    // =========================================================

    function loadLocalData() {

        var cReq =
            new XMLHttpRequest()

        cReq.open(
            "GET",
            Qt.resolvedUrl(
                "../data/earth/countries_metadata.json"
            ),
            false
        )

        try {
            cReq.send()
        } catch (e) {
            console.log(
                "DYSEN TERRITORY COUNTRY ERROR:",
                e
            )
        }

        if (
            cReq.status === 200 ||
            cReq.status === 0
        ) {
            try {

                countryMeta =
                    JSON.parse(
                        cReq.responseText
                    )

                countryMetaLoaded = true

                console.log(
                    "DYSEN TERRITORY:",
                    countryMeta.length,
                    "country records"
                )

            } catch (e2) {

                console.log(
                    "DYSEN TERRITORY COUNTRY JSON:",
                    e2
                )
            }
        }

        var sReq =
            new XMLHttpRequest()

        sReq.open(
            "GET",
            Qt.resolvedUrl(
                "../data/earth/admin1_qml.json"
            ),
            false
        )

        try {
            sReq.send()
        } catch (e3) {
            console.log(
                "DYSEN TERRITORY STATE ERROR:",
                e3
            )
        }

        if (
            sReq.status === 200 ||
            sReq.status === 0
        ) {
            try {

                stateData =
                    JSON.parse(
                        sReq.responseText
                    )

                stateLoaded = true

                console.log(
                    "DYSEN TERRITORY:",
                    stateData.features.length,
                    "ADMIN1 records"
                )

            } catch (e4) {

                console.log(
                    "DYSEN TERRITORY STATE JSON:",
                    e4
                )
            }
        }
    }

    function norm(value) {

        return String(value || "")
            .toLowerCase()
            .replace(
                /[^a-z0-9]+/g,
                ""
            )
    }

    function findCountry(name) {

        if (
            !countryMetaLoaded ||
            !countryMeta
        )
            return null

        var target =
            norm(name)

        var aliases = {
            unitedstatesofamerica:
                "unitedstates",

            russiansovietfederation:
                "russia",

            republicofkorea:
                "southkorea",

            czechia:
                "czechrepublic"
        }

        if (aliases[target])
            target =
                aliases[target]

        for (
            var i = 0;
            i < countryMeta.length;
            i++
        ) {

            var c =
                countryMeta[i]

            var candidates = [
                c.common,
                c.official,
                c.cca2,
                c.cca3
            ]

            var alt =
                c.altSpellings || []

            for (
                var a = 0;
                a < alt.length;
                a++
            )
                candidates.push(
                    alt[a]
                )

            for (
                var j = 0;
                j < candidates.length;
                j++
            ) {

                if (
                    norm(
                        candidates[j]
                    ) === target
                )
                    return c
            }
        }

        return null
    }

    // =========================================================
    // FORMATTING
    // =========================================================

    function compact(value) {

        var n =
            Number(value)

        if (
            isNaN(n) ||
            !isFinite(n)
        )
            return "—"

        if (
            Math.abs(n) >=
            1000000000
        )
            return (
                (
                    n / 1000000000
                ).toFixed(2) +
                "B"
            )

        if (
            Math.abs(n) >=
            1000000
        )
            return (
                (
                    n / 1000000
                ).toFixed(2) +
                "M"
            )

        if (
            Math.abs(n) >=
            1000
        )
            return (
                (
                    n / 1000
                ).toFixed(1) +
                "K"
            )

        return n.toFixed(0)
    }

    function money(value) {

        var n =
            Number(value)

        if (
            isNaN(n) ||
            !isFinite(n)
        )
            return "—"

        if (
            Math.abs(n) >=
            1000000000000
        )
            return "$" +
                (
                    n / 1000000000000
                ).toFixed(2) +
                "T"

        if (
            Math.abs(n) >=
            1000000000
        )
            return "$" +
                (
                    n / 1000000000
                ).toFixed(2) +
                "B"

        if (
            Math.abs(n) >=
            1000000
        )
            return "$" +
                (
                    n / 1000000
                ).toFixed(2) +
                "M"

        return "$" +
            n.toLocaleString(
                undefined,
                {
                    maximumFractionDigits: 0
                }
            )
    }

    function currency(meta) {

        if (
            !meta ||
            !meta.currencies ||
            !meta.currencies.length
        )
            return "—"

        var c =
            meta.currencies[0]

        return (
            String(c.name || "—") +
            " [" +
            String(c.code || "—") +
            "]"
        )
    }

    function langs(meta) {

        if (
            !meta ||
            !meta.languages ||
            !meta.languages.length
        )
            return "—"

        return meta.languages.join(
            ", "
        )
    }

    // =========================================================
    // COUNTRY SELECTION
    // =========================================================

    function selectCountry() {

        if (
            !globeRoot ||
            !globeRoot.selectedCountry
        )
            return

        selectedKind =
            "COUNTRY"

        selectedName =
            String(
                globeRoot.selectedCountryName ||
                "UNKNOWN"
            )

        selectedState = null

        selectedCountryMeta =
            findCountry(
                globeRoot.selectedCountryName
            )

        if (
            !selectedCountryMeta
        ) {

            primaryInfo =
                "REFERENCE DATA UNAVAILABLE"

            secondaryInfo = ""
            economyInfo = ""
            liveInfo = ""

            return
        }

        buildCountry()

        loadLiveCountry(
            selectedCountryMeta
        )

        annotationCanvas.requestPaint()
    }

    function buildCountry() {

        var m =
            selectedCountryMeta

        var capital =
            (
                m.capital &&
                m.capital.length
            )
            ? m.capital.join(
                ", "
            )
            : "—"

        var area =
            m.area
            ? Number(
                m.area
            ).toLocaleString() +
              " km²"
            : "—"

        var borders =
            (
                m.borders &&
                m.borders.length
            )
            ? String(
                m.borders.length
            ) +
              " COUNTRIES"
            : "ISLAND / NONE"

        primaryInfo =
            "ISO        " +
            String(
                m.cca3 || "—"
            ) +
            " / " +
            String(
                m.cca2 || "—"
            ) +
            "\n" +
            "CAPITAL    " +
            capital +
            "\n" +
            "REGION     " +
            String(
                m.region || "—"
            ) +
            "\n" +
            "SUB-REGION " +
            String(
                m.subregion || "—"
            ) +
            "\n" +
            "AREA       " +
            area +
            "\n" +
            "BORDERS    " +
            borders

        secondaryInfo =
            "CURRENCY   " +
            currency(m) +
            "\n" +
            "LANGUAGES  " +
            langs(m) +
            "\n" +
            "STATUS     " +
            (
                m.unMember
                ? "UN MEMBER"
                : "NON-UN MEMBER"
            )

        updateLiveText()
    }

    // =========================================================
    // STATE / PROVINCE SELECTION
    // =========================================================

    function pointInPolygon(
        points,
        x,
        y
    ) {

        var inside = false

        for (
            var i = 0,
            j = points.length - 1;
            i < points.length;
            j = i++
        ) {

            var xi =
                points[i].x

            var yi =
                points[i].y

            var xj =
                points[j].x

            var yj =
                points[j].y

            var hit =
                (
                    (yi > y) !==
                    (yj > y)
                ) &&
                (
                    x <
                    (
                        (xj - xi) *
                        (y - yi) /
                        (
                            (yj - yi) ||
                            0.000001
                        )
                    ) +
                    xi
                )

            if (hit)
                inside = !inside
        }

        return inside
    }

    function stateAt(
        x,
        y
    ) {

        if (
            !stateLoaded ||
            !stateData ||
            !globeRoot
        )
            return -1

        var cx =
            globeRoot.width *
            globeRoot.projectionCenterRatio

        var cy =
            globeRoot.height / 2

        var radius =
            Math.min(
                globeRoot.width,
                globeRoot.height
            ) *
            globeRoot.globeScale

        var features =
            stateData.features || []

        for (
            var f = 0;
            f < features.length;
            f++
        ) {

            var feature =
                features[f]

            if (
                !feature ||
                !feature.g
            )
                continue

            if (
                feature.x &&
                feature.x.length >= 2
            ) {

                var center =
                    globeRoot.project(
                        feature.x[0],
                        feature.x[1],
                        cx,
                        cy,
                        radius
                    )

                if (!center)
                    continue
            }

            var polygonGroups =
                feature.g

            for (
                var p = 0;
                p < polygonGroups.length;
                p++
            ) {

                var polygon =
                    polygonGroups[p]

                if (
                    !polygon ||
                    !polygon.length
                )
                    continue

                var ring =
                    polygon[0]

                var projected = []

                for (
                    var q = 0;
                    q < ring.length;
                    q++
                ) {

                    var point =
                        globeRoot.project(
                            ring[q][0],
                            ring[q][1],
                            cx,
                            cy,
                            radius
                        )

                    if (point)
                        projected.push(
                            point
                        )
                }

                if (
                    projected.length >= 3 &&
                    pointInPolygon(
                        projected,
                        x,
                        y
                    )
                )
                    return f
            }
        }

        return -1
    }

    // ============================================================
    // STATE LIVE DATA
    // ============================================================

    property string stateTemperature: "—"
    property string stateFeelsLike: "—"
    property string stateHumidity: "—"
    property string stateWind: "—"
    property string statePressure: "—"
    property string stateCondition: "—"
    property string stateLocalTime: "—"
    property string stateTimezone: "—"
    property string stateDayNight: "—"
    property string stateLatitude: "—"
    property string stateLongitude: "—"

    function selectState(index) {

        if (
            index < 0 ||
            !stateData ||
            !stateData.features
        )
            return

        selectedState =
            stateData.features[index]

        if (!selectedState)
            return

        selectedKind =
            "STATE / PROVINCE"

        selectedName =
            String(
                selectedState.n ||
                "UNKNOWN"
            )

        // --------------------------------------------------------
        // RESET STATE LIVE DATA
        // --------------------------------------------------------

        stateTemperature = "—"
        stateFeelsLike = "—"
        stateHumidity = "—"
        stateWind = "—"
        statePressure = "—"
        stateCondition = "—"
        stateLocalTime = "—"
        stateTimezone = "—"
        stateDayNight = "—"
        stateLatitude = "—"
        stateLongitude = "—"

        var coords =
            selectedState.x || []

        var stateLon =
            coords.length >= 2
            ? Number(coords[0])
            : NaN

        var stateLat =
            coords.length >= 2
            ? Number(coords[1])
            : NaN

        if (
            isFinite(stateLat) &&
            isFinite(stateLon)
        ) {

            stateLatitude =
                stateLat.toFixed(4) + "°"

            stateLongitude =
                stateLon.toFixed(4) + "°"

            console.log(
                "DYSEN STATE COORDS:",
                selectedName,
                "lat=",
                stateLat,
                "lon=",
                stateLon
            )

            loadStateWeather(
                stateLat,
                stateLon
            )
        }

        // --------------------------------------------------------
        // PRIMARY STATE IDENTITY
        // --------------------------------------------------------

        primaryInfo =
            "STATE      " +
            selectedName +
            "\n" +
            "COUNTRY    " +
            String(
                selectedState.a ||
                "—"
            ) +
            "\n" +
            "ISO 3166-2 " +
            String(
                selectedState.i ||
                "—"
            ) +
            "\n" +
            "TYPE       " +
            String(
                selectedState.t ||
                "—"
            )

        // --------------------------------------------------------
        // SECONDARY STATE METADATA
        // --------------------------------------------------------

        secondaryInfo =
            "REGION     " +
            String(
                selectedState.r ||
                "—"
            ) +
            "\n" +
            "CENTROID   " +
            stateLatitude +
            " / " +
            stateLongitude +
            "\n" +
            "BOUNDARY   ADMIN-1"

        // --------------------------------------------------------
        // STATE DATA
        // --------------------------------------------------------

        economyInfo =
            "STATE DATA\n" +
            "GEOMETRY   VERIFIED\n" +
            "CENTROID   " +
            stateLatitude +
            " / " +
            stateLongitude +
            "\n" +
            "SOURCE     NATURAL EARTH"

        liveInfo =
            "LIVE STATE CONDITIONS\n" +
            "TEMP       " +
            stateTemperature +
            "\n" +
            "FEELS      " +
            stateFeelsLike +
            "\n" +
            "HUMIDITY   " +
            stateHumidity +
            "\n" +
            "WIND       " +
            stateWind +
            "\n" +
            "PRESSURE   " +
            statePressure +
            "\n" +
            "CONDITION  " +
            stateCondition +
            "\n" +
            "LOCAL TIME " +
            stateLocalTime +
            "\n" +
            "TIMEZONE   " +
            stateTimezone +
            "\n" +
            "DAY/NIGHT  " +
            stateDayNight +
            "\n" +
            "SOURCE     OPEN-METEO"

        annotationCanvas.requestPaint()
        stateCanvas.requestPaint()
    }

    function handleSelection(
        x,
        y
    ) {

        if (
            !globeRoot ||
            !globeRoot.exploreActive
        )
            return

        if (
            globeRoot.globeScale >= 0.58 &&
            stateLoaded
        ) {

            var si =
                stateAt(
                    x,
                    y
                )

            if (si >= 0) {

                globeRoot.selectedCountryIndex =
                    -1

                globeRoot.selectedCountry =
                    null

                selectState(si)

                return
            }
        }

        selectedState = null

        globeRoot.selectCountryAt(
            x,
            y
        )

        selectCountry()
    }

    // =========================================================
    // LIVE COUNTRY DATA
    // =========================================================

    function loadLiveCountry(
        meta
    ) {

        if (
            !meta ||
            !meta.cca3
        )
            return

        liveLoading = true

        livePopulation = "..."
        liveGdp = "..."
        liveGdpPc = "..."
        liveInflation = "..."
        liveUnemployment = "..."
        liveInternet = "..."
        liveLife = "..."
        liveCapital = "..."
        liveWeather = "..."
        liveFx = "..."
        liveYear = ""

        var iso3 =
            String(
                meta.cca3
            )

        var countryReq =
            new XMLHttpRequest()

        countryReq.open(
            "GET",
            "https://api.worldbank.org/v2/country/" +
            encodeURIComponent(
                iso3
            ) +
            "?format=json"
        )

        countryReq.onreadystatechange =
            function() {

            if (
                countryReq.readyState !== 4
            )
                return

            if (
                countryReq.status !== 200 &&
                countryReq.status !== 0
            )
                return

            try {

                var response =
                    JSON.parse(
                        countryReq.responseText
                    )

                var row =
                    response &&
                    response[1] &&
                    response[1].length
                    ? response[1][0]
                    : null

                if (row) {

                    liveCapital =
                        row.capitalCity ||
                        "—"

                    var lat =
                        row.latitude

                    var lon =
                        row.longitude

                    if (
                        lat &&
                        lon
                    )
                        loadWeather(
                            lat,
                            lon
                        )
                }

                updateLiveText()

            } catch (e) {

                console.log(
                    "DYSEN WB COUNTRY:",
                    e
                )
            }
        }

        countryReq.send()

        var indicators =
            "SP.POP.TOTL;" +
            "NY.GDP.MKTP.CD;" +
            "NY.GDP.PCAP.CD;" +
            "FP.CPI.TOTL.ZG;" +
            "SL.UEM.TOTL.ZS;" +
            "IT.NET.USER.ZS;" +
            "SP.DYN.LE00.IN"

        var indicatorReq =
            new XMLHttpRequest()

        indicatorReq.open(
            "GET",
            "https://api.worldbank.org/v2/country/" +
            encodeURIComponent(
                iso3
            ) +
            "/indicator/" +
            indicators +
            "?format=json&source=2&mrnev=5&per_page=100"
        )

        indicatorReq.onreadystatechange =
            function() {

            if (
                indicatorReq.readyState !== 4
            )
                return

            console.log(
                "DYSEN WB INDICATORS HTTP:",
                iso3,
                "status=",
                indicatorReq.status
            )

            if (
                indicatorReq.status !== 200 &&
                indicatorReq.status !== 0
            ) {
                liveLoading = false
                updateLiveText()
                return
            }

            try {

                var response =
                    JSON.parse(
                        indicatorReq.responseText
                    )

                var rows =
                    response[1] || []

                console.log(
                    "DYSEN WB INDICATORS:",
                    iso3,
                    "rows=",
                    rows.length
                )

                for (
                    var i = 0;
                    i < rows.length;
                    i++
                ) {

                    var row =
                        rows[i]

                    if (!row)
                        continue

                    var id = ""

                    if (
                        row.indicator &&
                        typeof row.indicator === "object"
                    ) {
                        id =
                            row.indicator.id ||
                            ""
                    } else if (
                        typeof row.indicator === "string"
                    ) {
                        id = row.indicator
                    }

                    if (!id)
                        continue

                    if (
                        row.date &&
                        (
                            !liveYear ||
                            Number(row.date) >
                            Number(liveYear)
                        )
                    )
                        liveYear =
                            String(row.date)

                    if (
                        id ===
                        "SP.POP.TOTL"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            livePopulation === "..."
                        ) {
                            livePopulation =
                                compact(
                                    row.value
                                )
                        }

                    } else if (
                        id ===
                        "NY.GDP.MKTP.CD"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveGdp === "..."
                        ) {
                            liveGdp =
                                money(
                                    row.value
                                )
                        }

                    } else if (
                        id ===
                        "NY.GDP.PCAP.CD"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveGdpPc === "..."
                        ) {
                            liveGdpPc =
                                money(
                                    row.value
                                )
                        }

                    } else if (
                        id ===
                        "FP.CPI.TOTL.ZG"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveInflation === "..."
                        ) {
                            liveInflation =
                                Number(
                                    row.value
                                ).toFixed(1) +
                                "%"
                        }

                    } else if (
                        id ===
                        "SL.UEM.TOTL.ZS"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveUnemployment === "..."
                        ) {
                            liveUnemployment =
                                Number(
                                    row.value
                                ).toFixed(1) +
                                "%"
                        }

                    } else if (
                        id ===
                        "IT.NET.USER.ZS"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveInternet === "..."
                        ) {
                            liveInternet =
                                Number(
                                    row.value
                                ).toFixed(1) +
                                "%"
                        }

                    } else if (
                        id ===
                        "SP.DYN.LE00.IN"
                    ) {

                        if (
                            row.value !== null &&
                            row.value !== undefined &&
                            liveLife === "..."
                        ) {
                            liveLife =
                                Number(
                                    row.value
                                ).toFixed(1)
                        }
                    }
                }

                liveLoading = false

                updateLiveText()

            } catch (e2) {

                liveLoading = false

                updateLiveText()

                console.log(
                    "DYSEN WB INDICATORS:",
                    e2
                )
            }
        }

        indicatorReq.send()

        var code = ""

        if (
            meta.currencies &&
            meta.currencies.length
        )
            code =
                String(
                    meta.currencies[0].code ||
                    ""
                ).toLowerCase()

        if (
            code &&
            code !== "usd"
        ) {

            var fxReq =
                new XMLHttpRequest()

            fxReq.open(
                "GET",
                "https://api.frankfurter.dev/v2/rate/usd/" +
                encodeURIComponent(
                    code
                )
            )

            fxReq.onreadystatechange =
                function() {

                if (
                    fxReq.readyState !== 4
                )
                    return

                if (
                    fxReq.status !== 200 &&
                    fxReq.status !== 0
                )
                    return

                try {

                    var f =
                        JSON.parse(
                            fxReq.responseText
                        )

                    liveFx =
                        "1 USD = " +
                        Number(
                            f.rate
                        ).toFixed(4) +
                        " " +
                        String(
                            f.quote ||
                            code
                        ).toUpperCase()

                    updateLiveText()

                } catch (e3) {
                    liveFx = "—"
                }
            }

            fxReq.send()

        } else {

            liveFx =
                "1 USD = 1 USD"

            updateLiveText()
        }
    }

    function loadWeather(
        lat,
        lon
    ) {

        var req =
            new XMLHttpRequest()

        req.open(
            "GET",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" +
            encodeURIComponent(lat) +
            "&longitude=" +
            encodeURIComponent(lon) +
            "&current=" +
            "temperature_2m," +
            "weather_code," +
            "wind_speed_10m"
        )

        req.onreadystatechange =
            function() {

            if (
                req.readyState !== 4
            )
                return

            if (
                req.status !== 200 &&
                req.status !== 0
            )
                return

            try {

                var w =
                    JSON.parse(
                        req.responseText
                    )

                var c =
                    w.current || {}

                liveWeather =
                    (
                        c.temperature_2m !==
                        undefined
                        ? Number(
                            c.temperature_2m
                        ).toFixed(1) +
                          "°C"
                        : "—"
                    ) +
                    " // WCODE " +
                    String(
                        c.weather_code !==
                        undefined
                        ? c.weather_code
                        : "—"
                    ) +
                    " // WIND " +
                    (
                        c.wind_speed_10m !==
                        undefined
                        ? Number(
                            c.wind_speed_10m
                        ).toFixed(0) +
                          " km/h"
                        : "—"
                    )

                updateLiveText()

            } catch (e) {

                liveWeather = "—"
                updateLiveText()
            }
        }

        req.send()
    }

    function stateWeatherLabel(code) {

        var c = Number(code)

        if (!isFinite(c))
            return "—"

        if (c === 0)
            return "CLEAR"

        if (c === 1 || c === 2 || c === 3)
            return "PARTLY CLOUDY"

        if (c === 45 || c === 48)
            return "FOG"

        if (
            c === 51 ||
            c === 53 ||
            c === 55 ||
            c === 56 ||
            c === 57
        )
            return "DRIZZLE"

        if (
            c === 61 ||
            c === 63 ||
            c === 65 ||
            c === 66 ||
            c === 67
        )
            return "RAIN"

        if (
            c === 71 ||
            c === 73 ||
            c === 75 ||
            c === 77
        )
            return "SNOW"

        if (
            c === 80 ||
            c === 81 ||
            c === 82
        )
            return "SHOWERS"

        if (
            c === 85 ||
            c === 86
        )
            return "SNOW SHOWERS"

        if (
            c === 95 ||
            c === 96 ||
            c === 99
        )
            return "THUNDERSTORM"

        return "WEATHER " + c
    }


    function loadStateWeather(
        lat,
        lon
    ) {

        if (
            !isFinite(lat) ||
            !isFinite(lon)
        )
            return

        var req =
            new XMLHttpRequest()

        req.open(
            "GET",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" +
            encodeURIComponent(lat) +
            "&longitude=" +
            encodeURIComponent(lon) +
            "&current=" +
            "temperature_2m," +
            "relative_humidity_2m," +
            "apparent_temperature," +
            "wind_speed_10m," +
            "pressure_msl," +
            "weather_code," +
            "is_day" +
            "&timezone=auto"
        )

        req.onreadystatechange =
            function() {

            if (
                req.readyState !== 4
            )
                return

            if (
                req.status !== 200 &&
                req.status !== 0
            ) {
                console.log(
                    "DYSEN STATE WEATHER HTTP:",
                    req.status
                )
                return
            }

            try {

                var response =
                    JSON.parse(
                        req.responseText
                    )

                var current =
                    response &&
                    response.current
                    ? response.current
                    : null

                if (!current)
                    return

                if (
                    current.temperature_2m !== null &&
                    current.temperature_2m !== undefined
                ) {
                    stateTemperature =
                        Number(
                            current.temperature_2m
                        ).toFixed(1) +
                        " °C"
                }

                if (
                    current.apparent_temperature !== null &&
                    current.apparent_temperature !== undefined
                ) {
                    stateFeelsLike =
                        Number(
                            current.apparent_temperature
                        ).toFixed(1) +
                        " °C"
                }

                if (
                    current.relative_humidity_2m !== null &&
                    current.relative_humidity_2m !== undefined
                ) {
                    stateHumidity =
                        Number(
                            current.relative_humidity_2m
                        ).toFixed(0) +
                        " %"
                }

                if (
                    current.wind_speed_10m !== null &&
                    current.wind_speed_10m !== undefined
                ) {
                    stateWind =
                        Number(
                            current.wind_speed_10m
                        ).toFixed(1) +
                        " km/h"
                }

                if (
                    current.pressure_msl !== null &&
                    current.pressure_msl !== undefined
                ) {
                    statePressure =
                        Number(
                            current.pressure_msl
                        ).toFixed(0) +
                        " hPa"
                }

                if (
                    current.weather_code !== null &&
                    current.weather_code !== undefined
                ) {
                    stateCondition =
                        stateWeatherLabel(
                            current.weather_code
                        )
                }

                if (
                    current.is_day !== null &&
                    current.is_day !== undefined
                ) {
                    stateDayNight =
                        Number(
                            current.is_day
                        ) === 1
                        ? "DAY"
                        : "NIGHT"
                }

                stateLocalTime =
                    response.timezone
                    ? String(
                        current.time ||
                        "—"
                    )
                    : String(
                        current.time ||
                        "—"
                    )

                stateTimezone =
                    response.timezone ||
                    "—"

                console.log(
                    "DYSEN STATE WEATHER:",
                    selectedName,
                    stateTemperature,
                    stateCondition,
                    stateTimezone
                )

                updateLiveText()

            } catch (e) {

                console.log(
                    "DYSEN STATE WEATHER:",
                    e
                )
            }
        }

        req.send()
    }

    function updateLiveText() {

        if (
            selectedKind ===
            "STATE / PROVINCE"
        ) {

            economyInfo =
                "STATE DATA\n" +
                "CENTROID   " +
                stateLatitude +
                " / " +
                stateLongitude +
                "\n" +
                "BOUNDARY   ADMIN-1\n" +
                "GEOMETRY   VERIFIED"

            liveInfo =
                "LIVE STATE CONDITIONS\n" +
                "TEMP       " +
                stateTemperature +
                "\n" +
                "FEELS      " +
                stateFeelsLike +
                "\n" +
                "HUMIDITY   " +
                stateHumidity +
                "\n" +
                "WIND       " +
                stateWind +
                "\n" +
                "PRESSURE   " +
                statePressure +
                "\n" +
                "CONDITION  " +
                stateCondition +
                "\n" +
                "LOCAL TIME " +
                stateLocalTime +
                "\n" +
                "TIMEZONE   " +
                stateTimezone +
                "\n" +
                "DAY/NIGHT  " +
                stateDayNight +
                "\n" +
                "SOURCE     OPEN-METEO"

            annotationCanvas.requestPaint()
            stateCanvas.requestPaint()

            return
        }

        if (
            selectedKind !== "COUNTRY"
        )
            return

        economyInfo =
            "POPULATION " +
            livePopulation +
            "\n" +
            "GDP        " +
            liveGdp +
            "\n" +
            "GDP / CAP  " +
            liveGdpPc +
            "\n" +
            "INFLATION  " +
            liveInflation +
            "\n" +
            "UNEMPLOY.  " +
            liveUnemployment +
            "\n" +
            "INTERNET   " +
            liveInternet +
            "\n" +
            "LIFE EXP.  " +
            liveLife

        liveInfo =
            "CAPITAL    " +
            liveCapital +
            "\n" +
            "CAPITAL WX " +
            liveWeather +
            "\n" +
            "FX / USD   " +
            liveFx +
            "\n" +
            "SOURCE     " +
            (
                liveYear
                ? "WORLD BANK " +
                  liveYear
                : (
                    liveLoading
                    ? "SYNCING"
                    : "READY"
                )
            )

        annotationCanvas.requestPaint()
    }

    // =========================================================
    // ANCHOR POINT
    // =========================================================

    function anchorPoint() {

        if (
            !globeRoot
        )
            return {
                x: 0,
                y: 0
            }

        var cx =
            globeRoot.width *
            globeRoot.projectionCenterRatio

        var cy =
            globeRoot.height / 2

        var radius =
            Math.min(
                globeRoot.width,
                globeRoot.height
            ) *
            globeRoot.globeScale

        if (
            selectedState &&
            selectedState.x &&
            selectedState.x.length >= 2
        ) {

            var sp =
                globeRoot.project(
                    selectedState.x[0],
                    selectedState.x[1],
                    cx,
                    cy,
                    radius
                )

            if (sp)
                return sp
        }

        if (
            globeRoot.selectedCountry
        ) {

            var feature =
                globeRoot.selectedCountry

            if (
                feature.p &&
                feature.p.length &&
                feature.p[0] &&
                feature.p[0].length
            ) {

                var ring =
                    feature.p[0]

                var count =
                    Math.min(
                        ring.length,
                        100
                    )

                var lon = 0
                var lat = 0

                for (
                    var i = 0;
                    i < count;
                    i++
                ) {

                    lon +=
                        Number(
                            ring[i][0]
                        )

                    lat +=
                        Number(
                            ring[i][1]
                        )
                }

                var cp =
                    globeRoot.project(
                        lon / count,
                        lat / count,
                        cx,
                        cy,
                        radius
                    )

                if (cp)
                    return cp
            }
        }

        return {
            x: cx,
            y: cy
        }
    }

    // =========================================================
    // STATE BOUNDARIES
    // =========================================================

    function drawStates(
        ctx
    ) {

        if (
            !globeRoot ||
            !globeRoot.exploreActive ||
            !stateLoaded ||
            !stateData
        )
            return

        var cx =
            globeRoot.width *
            globeRoot.projectionCenterRatio

        var cy =
            globeRoot.height / 2

        var radius =
            Math.min(
                globeRoot.width,
                globeRoot.height
            ) *
            globeRoot.globeScale

        var accent =
            Window.window
            ? Window.window.dysenAccentSecondary
            : "#7CF2FF"

        ctx.lineWidth = 0.48

        ctx.strokeStyle =
            Qt.rgba(
                accent.r,
                accent.g,
                accent.b,
                0.24
            )

        var features =
            stateData.features || []

        for (
            var f = 0;
            f < features.length;
            f++
        ) {

            var feature =
                features[f]

            if (
                !feature ||
                !feature.g
            )
                continue

            if (
                feature.x &&
                feature.x.length >= 2
            ) {

                var center =
                    globeRoot.project(
                        feature.x[0],
                        feature.x[1],
                        cx,
                        cy,
                        radius
                    )

                if (!center)
                    continue
            }

            for (
                var p = 0;
                p < feature.g.length;
                p++
            ) {

                var poly =
                    feature.g[p]

                if (
                    !poly ||
                    !poly.length
                )
                    continue

                var ring =
                    poly[0]

                ctx.beginPath()

                var started = false

                for (
                    var q = 0;
                    q < ring.length;
                    q++
                ) {

                    var pt =
                        globeRoot.project(
                            ring[q][0],
                            ring[q][1],
                            cx,
                            cy,
                            radius
                        )

                    if (!pt) {
                        started = false
                        continue
                    }

                    if (!started) {
                        ctx.moveTo(
                            pt.x,
                            pt.y
                        )
                        started = true
                    } else {
                        ctx.lineTo(
                            pt.x,
                            pt.y
                        )
                    }
                }

                ctx.stroke()
            }
        }

        if (
            selectedState &&
            selectedState.g
        ) {

            ctx.lineWidth = 1.4

            ctx.strokeStyle =
                Window.window
                ? Window.window.dysenAccent
                : "#00F6FF"

            for (
                var s = 0;
                s < selectedState.g.length;
                s++
            ) {

                var selectedPoly =
                    selectedState.g[s]

                if (
                    !selectedPoly ||
                    !selectedPoly.length
                )
                    continue

                var selectedRing =
                    selectedPoly[0]

                ctx.beginPath()

                var startedSelected =
                    false

                for (
                    var z = 0;
                    z < selectedRing.length;
                    z++
                ) {

                    var selectedPoint =
                        globeRoot.project(
                            selectedRing[z][0],
                            selectedRing[z][1],
                            cx,
                            cy,
                            radius
                        )

                    if (!selectedPoint) {
                        startedSelected =
                            false
                        continue
                    }

                    if (!startedSelected) {
                        ctx.moveTo(
                            selectedPoint.x,
                            selectedPoint.y
                        )
                        startedSelected =
                            true
                    } else {
                        ctx.lineTo(
                            selectedPoint.x,
                            selectedPoint.y
                        )
                    }
                }

                ctx.stroke()
            }
        }
    }

    // =========================================================
    // STATE CANVAS
    // =========================================================

    Canvas {

        id: stateCanvas

        anchors.fill: parent

        visible:
            globeRoot &&
            globeRoot.exploreActive &&
            stateLoaded

        z: 2

        antialiasing: true

        onPaint: {

            var ctx =
                getContext("2d")

            ctx.reset()

            ctx.save()

            var cx =
                globeRoot.width *
                globeRoot.projectionCenterRatio

            var cy =
                globeRoot.height / 2

            var radius =
                Math.min(
                    globeRoot.width,
                    globeRoot.height
                ) *
                globeRoot.globeScale

            ctx.beginPath()

            ctx.arc(
                cx,
                cy,
                radius + 1,
                0,
                Math.PI * 2
            )

            ctx.clip()

            drawStates(ctx)

            ctx.restore()
        }
    }

    // =========================================================
    // FUTURISTIC ANNOTATION
    // =========================================================

    Canvas {

        id: annotationCanvas

        anchors.fill: parent

        visible:
            globeRoot &&
            globeRoot.exploreActive &&
            selectedName !== ""

        z: 3

        onPaint: {

            var ctx =
                getContext("2d")

            ctx.reset()

            var p =
                anchorPoint()

            var targetX =
                width - 455

            var targetY =
                160

            var accent =
                Window.window
                ? Window.window.dysenAccent
                : "#00F6FF"

            ctx.strokeStyle =
                Qt.rgba(
                    accent.r,
                    accent.g,
                    accent.b,
                    0.82
                )

            ctx.fillStyle =
                Qt.rgba(
                    accent.r,
                    accent.g,
                    accent.b,
                    0.92
                )

            ctx.lineWidth = 1

            ctx.beginPath()

            ctx.moveTo(
                p.x,
                p.y
            )

            ctx.lineTo(
                Math.min(
                    p.x + 115,
                    targetX - 70
                ),
                p.y
            )

            ctx.lineTo(
                targetX - 32,
                targetY
            )

            ctx.lineTo(
                targetX,
                targetY
            )

            ctx.stroke()

            ctx.beginPath()

            ctx.arc(
                p.x,
                p.y,
                4,
                0,
                Math.PI * 2
            )

            ctx.fill()

            ctx.lineWidth = 0.65

            ctx.beginPath()

            ctx.arc(
                p.x,
                p.y,
                10,
                0,
                Math.PI * 2
            )

            ctx.stroke()
        }
    }

    // =========================================================
    // INFO
    // =========================================================

    Item {

        id: info

        anchors.right:
            parent.right

        anchors.rightMargin:
            52

        y: 112

        width: 410

        z: 4

        visible:
            globeRoot &&
            globeRoot.exploreActive &&
            selectedName !== ""

        Column {

            anchors.fill: parent

            spacing: 13

            Text {

                text:
                    selectedKind +
                    " // TARGET"

                color:
                    Window.window
                    ? Window.window.dysenAccentSecondary
                    : "#7CF2FF"

                font.family:
                    "Monospace"

                font.pixelSize:
                    11

                font.bold:
                    true

                font.letterSpacing:
                    1.5
            }

            Text {

                text:
                    selectedName

                color:
                    Window.window
                    ? Window.window.dysenAccent
                    : "#00F6FF"

                font.family:
                    "Monospace"

                font.pixelSize:
                    28

                font.bold:
                    true

                font.letterSpacing:
                    2.2

                elide:
                    Text.ElideRight

                width:
                    parent.width
            }

            Rectangle {

                width: 145
                height: 1

                color:
                    Window.window
                    ? Window.window.dysenAccent
                    : "#00F6FF"
            }

            Text {

                text:
                    primaryInfo

                color:
                    "#B8CED3"

                font.family:
                    "Monospace"

                font.pixelSize:
                    12

                lineHeight:
                    1.35

                wrapMode:
                    Text.Wrap

                width:
                    parent.width
            }

            Text {

                text:
                    secondaryInfo

                color:
                    "#81999F"

                font.family:
                    "Monospace"

                font.pixelSize:
                    11

                lineHeight:
                    1.35

                wrapMode:
                    Text.Wrap

                width:
                    parent.width
            }

            Rectangle {

                width: 220
                height: 1

                color:
                    Window.window
                    ? Window.window.dysenAccentDim
                    : "#007483"

                opacity: 0.72
            }

            Text {

                text:
                    economyInfo

                color:
                    "#A7C1C6"

                font.family:
                    "Monospace"

                font.pixelSize:
                    11

                lineHeight:
                    1.35

                wrapMode:
                    Text.Wrap

                width:
                    parent.width
            }

            Text {

                text:
                    liveInfo

                color:
                    Window.window
                    ? Window.window.dysenAccentSecondary
                    : "#7CF2FF"

                font.family:
                    "Monospace"

                font.pixelSize:
                    10

                lineHeight:
                    1.4

                wrapMode:
                    Text.Wrap

                width:
                    parent.width
            }

            Text {

                text:
                    "STREAM // " +
                    (
                        liveLoading
                        ? "SYNCING"
                        : "ONLINE"
                    )

                color:
                    "#536970"

                font.family:
                    "Monospace"

                font.pixelSize:
                    9

                font.letterSpacing:
                    1.1
            }
        }
    }

    Timer {

        interval:
            globeRoot &&
            globeRoot.pointerDragging
            ? 90
            : 60

        running:
            globeRoot &&
            globeRoot.exploreActive

        repeat: true

        onTriggered: {

            if (
                stateCanvas.visible
            )
                stateCanvas.requestPaint()

            if (
                annotationCanvas.visible
            )
                annotationCanvas.requestPaint()
        }
    }

    Component.onCompleted: {

        loadLocalData()

    }
}
