import QtQuick

QtObject {
    id: motion

    property MotionTokens tokens: MotionTokens {}

    function duration(speed) {
        if (speed === "instant")
            return tokens.instant
        if (speed === "fast")
            return tokens.fast
        if (speed === "slow")
            return tokens.slow
        if (speed === "workspace")
            return tokens.workspace

        return tokens.normal
    }

    function easing(kind) {
        if (kind === "smooth")
            return tokens.smoothEasing
        if (kind === "enter")
            return tokens.enterEasing
        if (kind === "exit")
            return tokens.exitEasing
        if (kind === "spring")
            return tokens.springEasing

        return tokens.standardEasing
    }
}
