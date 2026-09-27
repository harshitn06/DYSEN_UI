from pathlib import Path

from PySide6.QtCore import QObject, QUrl, Slot
from PySide6.QtMultimedia import QSoundEffect


class UIEffects(QObject):

    def __init__(self):
        super().__init__()

        base = Path(__file__).resolve().parent
        sounds = base / "assets" / "sounds"

        self.key_pool = []
        self.special_pool = []
        self.space_pool = []
        self.backspace_pool = []
        self.enter_pool = []
        self.panel_effect = None

        # Multiple preloaded key effects allow very fast typing
        # without the previous sound being interrupted.
        for _ in range(2):
            effect = QSoundEffect(self)

            effect.setSource(
                QUrl.fromLocalFile(
                    str(
                        (sounds / "key.wav").resolve()
                    )
                )
            )

            effect.setLoopCount(1)
            effect.setVolume(0.75)

            self.key_pool.append(effect)

        for _ in range(4):
            effect = QSoundEffect(self)

            effect.setSource(
                QUrl.fromLocalFile(
                    str(
                        (sounds / "special.wav").resolve()
                    )
                )
            )

            effect.setLoopCount(1)
            effect.setVolume(0.75)

            self.special_pool.append(effect)

        # Dedicated spacebar sound pool.
        for _ in range(2):
            effect = QSoundEffect(self)

            effect.setSource(
                QUrl.fromLocalFile(
                    str(
                        (sounds / "space.wav").resolve()
                    )
                )
            )

            effect.setLoopCount(1)
            effect.setVolume(0.75)

            self.space_pool.append(effect)

        self._space_index = 0

        for sound_name, pool in (
            ("backspace", self.backspace_pool),
            ("enter", self.enter_pool),
        ):
            for _ in range(2):
                effect = QSoundEffect(self)

                effect.setSource(
                    QUrl.fromLocalFile(
                        str(
                            (sounds / f"{sound_name}.wav").resolve()
                        )
                    )
                )

                effect.setLoopCount(1)
                effect.setVolume(0.75)

                pool.append(effect)

        self._backspace_index = 0
        self._enter_index = 0

        self.panel_effect = QSoundEffect(self)

        self.panel_effect.setSource(
            QUrl.fromLocalFile(
                str(
                    (sounds / "panel.wav").resolve()
                )
            )
        )

        self.panel_effect.setLoopCount(1)
        self.panel_effect.setVolume(0.75)

        self.extra_effects = {}
        for sound_name in (
            "panel_open",
            "panel_close",
            "panel_focus",
            "panel_resize",
            "toggle",
            "notify",
            "warning",
            "error",
        ):
            effect = QSoundEffect(self)
            effect.setSource(
                QUrl.fromLocalFile(
                    str((sounds / f"{sound_name}.wav").resolve())
                )
            )
            effect.setLoopCount(1)
            effect.setVolume(0.75)
            self.extra_effects[sound_name] = effect

        self._key_index = 0
        self._special_index = 0

    def _play_pool(self, pool, index_name):

        if not pool:
            return

        index = getattr(
            self,
            index_name
        )

        effect = pool[index]

        # Advance before playback so the next rapid event
        # gets a different preloaded effect.
        index = (
            index + 1
        ) % len(pool)

        setattr(
            self,
            index_name,
            index
        )

        effect.play()

    @Slot(str)
    def play(self, name):

        if name == "key":
            self._play_pool(
                self.key_pool,
                "_key_index"
            )
            return

        if name == "special":
            self._play_pool(
                self.special_pool,
                "_special_index"
            )
            return

        if name == "space":
            self._play_pool(
                self.space_pool,
                "_space_index"
            )
            return

        if name == "backspace":
            self._play_pool(
                self.backspace_pool,
                "_backspace_index"
            )
            return

        if name == "enter":
            self._play_pool(
                self.enter_pool,
                "_enter_index"
            )
            return

        if name == "panel":
            if self.panel_effect:
                self.panel_effect.play()
            return

        effect = self.extra_effects.get(name)
        if effect:
            effect.play()
