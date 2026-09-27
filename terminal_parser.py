from dataclasses import dataclass
import re


@dataclass
class Cell:
    char: str = " "
    fg: str = "#BFEAF0"
    bg: str = "#000000"
    bold: bool = False
    dim: bool = False
    underline: bool = False


class TerminalScreen:

    ANSI_COLORS = {
        30: "#000000",
        31: "#FF5555",
        32: "#50FA7B",
        33: "#F1FA8C",
        34: "#5A8CFF",
        35: "#FF79C6",
        36: "#00E6F5",
        37: "#F8F8F2",
        90: "#6272A4",
        91: "#FF6E6E",
        92: "#69FF94",
        93: "#FFFFA5",
        94: "#82AAFF",
        95: "#FF92DF",
        96: "#8BE9FD",
        97: "#FFFFFF",
    }

    def __init__(
        self,
        cols=120,
        rows=32,
        scrollback=50000,
    ):
        self.cols = max(20, cols)
        self.rows = max(5, rows)
        self.scrollback_limit = max(100, scrollback)

        self.cursor_x = 0
        self.cursor_y = 0

        self.saved_x = 0
        self.saved_y = 0

        self.fg = "#BFEAF0"
        self.bg = "#000000"

        self.bold = False
        self.dim = False
        self.underline = False

        self.cursor_visible = True

        self.scroll_top = 0
        self.scroll_bottom = self.rows - 1

        self.scrollback = []

        self.grid = [
            [Cell() for _ in range(self.cols)]
            for _ in range(self.rows)
        ]

        self._state = "normal"
        self._csi = ""

    # =========================================================
    # RESIZE
    # =========================================================

    def resize(self, cols, rows):
        cols = max(20, int(cols))
        rows = max(5, int(rows))

        if cols == self.cols and rows == self.rows:
            return

        old = self.grid

        self.cols = cols
        self.rows = rows

        self.grid = [
            [Cell() for _ in range(cols)]
            for _ in range(rows)
        ]

        for y in range(min(rows, len(old))):
            for x in range(min(cols, len(old[y]))):
                self.grid[y][x] = old[y][x]

        self.cursor_x = min(
            self.cursor_x,
            self.cols - 1
        )

        self.cursor_y = min(
            self.cursor_y,
            self.rows - 1
        )

        self.scroll_bottom = self.rows - 1

    # =========================================================
    # RESET
    # =========================================================

    def reset(self):
        self.cursor_x = 0
        self.cursor_y = 0

        self.saved_x = 0
        self.saved_y = 0

        self.fg = "#BFEAF0"
        self.bg = "#000000"

        self.bold = False
        self.dim = False
        self.underline = False

        self.scrollback.clear()

        self.grid = [
            [Cell() for _ in range(self.cols)]
            for _ in range(self.rows)
        ]

    # =========================================================
    # CELL WRITE
    # =========================================================

    def put_char(self, char):
        if self.cursor_x >= self.cols:
            self.cursor_x = 0
            self.newline()

        if self.cursor_y < 0:
            self.cursor_y = 0

        if self.cursor_y >= self.rows:
            self.scroll_up()
            self.cursor_y = self.rows - 1

        self.grid[self.cursor_y][self.cursor_x] = Cell(
            char=char,
            fg=self.fg,
            bg=self.bg,
            bold=self.bold,
            dim=self.dim,
            underline=self.underline,
        )

        self.cursor_x += 1

    # =========================================================
    # BASIC CONTROL
    # =========================================================

    def newline(self):
        self.cursor_x = 0

        if self.cursor_y >= self.scroll_bottom:
            self.scroll_up()
        else:
            self.cursor_y += 1

    def carriage_return(self):
        self.cursor_x = 0

    def backspace(self):
        self.cursor_x = max(
            0,
            self.cursor_x - 1
        )

    def tab(self):
        next_tab = (
            ((self.cursor_x // 8) + 1) * 8
        )

        self.cursor_x = min(
            next_tab,
            self.cols - 1
        )

    # =========================================================
    # SCROLL
    # =========================================================

    def scroll_up(self):
        if not self.grid:
            return

        removed = self.grid[self.scroll_top]

        text = "".join(
            cell.char
            for cell in removed
        )

        self.scrollback.append(text)

        if len(self.scrollback) > self.scrollback_limit:
            del self.scrollback[
                :len(self.scrollback) -
                self.scrollback_limit
            ]

        for y in range(
            self.scroll_top,
            self.scroll_bottom
        ):
            self.grid[y] = self.grid[y + 1]

        self.grid[self.scroll_bottom] = [
            Cell()
            for _ in range(self.cols)
        ]

    # =========================================================
    # ERASE
    # =========================================================

    def erase_in_line(self, mode):
        if mode == 0:
            start = self.cursor_x
            end = self.cols
        elif mode == 1:
            start = 0
            end = self.cursor_x + 1
        else:
            start = 0
            end = self.cols

        for x in range(start, end):
            self.grid[self.cursor_y][x] = Cell()

    def erase_in_display(self, mode):
        if mode == 2:
            for y in range(self.rows):
                self.grid[y] = [
                    Cell()
                    for _ in range(self.cols)
                ]

            self.cursor_x = 0
            self.cursor_y = 0
            return

        if mode == 3:
            self.scrollback.clear()

            for y in range(self.rows):
                self.grid[y] = [
                    Cell()
                    for _ in range(self.cols)
                ]

            self.cursor_x = 0
            self.cursor_y = 0
            return

        if mode == 0:
            for x in range(
                self.cursor_x,
                self.cols
            ):
                self.grid[self.cursor_y][x] = Cell()

            for y in range(
                self.cursor_y + 1,
                self.rows
            ):
                self.grid[y] = [
                    Cell()
                    for _ in range(self.cols)
                ]

        elif mode == 1:
            for y in range(0, self.cursor_y):
                self.grid[y] = [
                    Cell()
                    for _ in range(self.cols)
                ]

            for x in range(0, self.cursor_x + 1):
                self.grid[self.cursor_y][x] = Cell()

    # =========================================================
    # CURSOR
    # =========================================================

    def cursor_up(self, n=1):
        self.cursor_y = max(
            self.scroll_top,
            self.cursor_y - n
        )

    def cursor_down(self, n=1):
        self.cursor_y = min(
            self.scroll_bottom,
            self.cursor_y + n
        )

    def cursor_forward(self, n=1):
        self.cursor_x = min(
            self.cols - 1,
            self.cursor_x + n
        )

    def cursor_back(self, n=1):
        self.cursor_x = max(
            0,
            self.cursor_x - n
        )

    def cursor_position(self, row=1, col=1):
        self.cursor_y = max(
            0,
            min(
                self.rows - 1,
                row - 1
            )
        )

        self.cursor_x = max(
            0,
            min(
                self.cols - 1,
                col - 1
            )
        )

    # =========================================================
    # SGR
    # =========================================================

    def sgr(self, params):
        if not params:
            params = [0]

        for code in params:

            if code == 0:
                self.fg = "#BFEAF0"
                self.bg = "#000000"
                self.bold = False
                self.dim = False
                self.underline = False

            elif code == 1:
                self.bold = True

            elif code == 2:
                self.dim = True

            elif code == 4:
                self.underline = True

            elif code == 22:
                self.bold = False
                self.dim = False

            elif code == 24:
                self.underline = False

            elif code == 39:
                self.fg = "#BFEAF0"

            elif code == 49:
                self.bg = "#000000"

            elif code in self.ANSI_COLORS:
                self.fg = self.ANSI_COLORS[code]

            elif 40 <= code <= 47:
                fg_code = code - 10
                self.bg = self.ANSI_COLORS.get(
                    fg_code,
                    "#000000"
                )

            elif 100 <= code <= 107:
                fg_code = code - 10
                self.bg = self.ANSI_COLORS.get(
                    fg_code,
                    "#000000"
                )

            elif code == 38:
                # Basic 256-color / RGB handling is completed
                # in parameter parser where extra arguments
                # are available.
                pass

    # =========================================================
    # CSI
    # =========================================================

    def handle_csi(self, sequence):
        if not sequence:
            return

        final = sequence[-1]
        body = sequence[:-1]

        private = False

        if body.startswith("?"):
            private = True
            body = body[1:]

        params = []

        if body:
            for part in body.split(";"):
                if part == "":
                    params.append(0)
                else:
                    try:
                        params.append(int(part))
                    except ValueError:
                        params.append(0)

        # -----------------------------------------------------
        # CURSOR
        # -----------------------------------------------------

        if final == "A":
            self.cursor_up(params[0] if params else 1)

        elif final == "B":
            self.cursor_down(params[0] if params else 1)

        elif final == "C":
            self.cursor_forward(params[0] if params else 1)

        elif final == "D":
            self.cursor_back(params[0] if params else 1)

        elif final == "E":
            self.cursor_down(params[0] if params else 1)
            self.cursor_x = 0

        elif final == "F":
            self.cursor_up(params[0] if params else 1)
            self.cursor_x = 0

        elif final == "G":
            self.cursor_position(
                self.cursor_y + 1,
                params[0] if params else 1
            )

        elif final in ("H", "f"):
            row = params[0] if len(params) >= 1 and params[0] else 1
            col = params[1] if len(params) >= 2 and params[1] else 1
            self.cursor_position(row, col)

        # -----------------------------------------------------
        # ERASE
        # -----------------------------------------------------

        elif final == "J":
            self.erase_in_display(
                params[0] if params else 0
            )

        elif final == "K":
            self.erase_in_line(
                params[0] if params else 0
            )

        # -----------------------------------------------------
        # SGR
        # -----------------------------------------------------

        elif final == "m":
            self.sgr(params)

            # 256 / RGB colors
            i = 0
            while i < len(params):

                if params[i] == 38 and i + 1 < len(params):

                    if params[i + 1] == 5 and i + 2 < len(params):
                        idx = params[i + 2]
                        self.fg = self.xterm256(idx)
                        i += 2

                    elif (
                        params[i + 1] == 2 and
                        i + 4 < len(params)
                    ):
                        r = params[i + 2]
                        g = params[i + 3]
                        b = params[i + 4]

                        self.fg = (
                            f"#{r:02x}{g:02x}{b:02x}"
                        )

                        i += 4

                i += 1

        # -----------------------------------------------------
        # SAVE / RESTORE CURSOR
        # -----------------------------------------------------

        elif final == "s":
            self.saved_x = self.cursor_x
            self.saved_y = self.cursor_y

        elif final == "u":
            self.cursor_x = self.saved_x
            self.cursor_y = self.saved_y

        # -----------------------------------------------------
        # PRIVATE MODES
        # -----------------------------------------------------

        elif private and final == "h":
            for p in params:
                if p == 25:
                    self.cursor_visible = True

        elif private and final == "l":
            for p in params:
                if p == 25:
                    self.cursor_visible = False

    @staticmethod
    def xterm256(index):
        index = max(0, min(255, int(index)))

        base = [
            "#000000",
            "#800000",
            "#008000",
            "#808000",
            "#000080",
            "#800080",
            "#008080",
            "#C0C0C0",
            "#808080",
            "#FF0000",
            "#00FF00",
            "#FFFF00",
            "#0000FF",
            "#FF00FF",
            "#00FFFF",
            "#FFFFFF",
        ]

        if index < 16:
            return base[index]

        if 16 <= index <= 231:
            n = index - 16

            r = n // 36
            g = (n % 36) // 6
            b = n % 6

            levels = [0, 95, 135, 175, 215, 255]

            return (
                f"#{levels[r]:02x}"
                f"{levels[g]:02x}"
                f"{levels[b]:02x}"
            )

        gray = 8 + (index - 232) * 10

        return f"#{gray:02x}{gray:02x}{gray:02x}"

    # =========================================================
    # FEED
    # =========================================================

    def feed(self, data):
        if not data:
            return

        i = 0

        while i < len(data):

            ch = data[i]

            # -------------------------------------------------
            # ESC
            # -------------------------------------------------

            if self._state == "escape":

                if ch == "[":
                    self._state = "csi"
                    self._csi = ""

                elif ch == "7":
                    self.saved_x = self.cursor_x
                    self.saved_y = self.cursor_y
                    self._state = "normal"

                elif ch == "8":
                    self.cursor_x = self.saved_x
                    self.cursor_y = self.saved_y
                    self._state = "normal"

                elif ch == "c":
                    self.reset()
                    self._state = "normal"

                else:
                    self._state = "normal"

                i += 1
                continue

            # -------------------------------------------------
            # CSI
            # -------------------------------------------------

            if self._state == "csi":

                self._csi += ch

                if (
                    "\x40" <= ch <= "\x7e"
                ):
                    self.handle_csi(
                        self._csi
                    )
                    self._state = "normal"
                    self._csi = ""

                i += 1
                continue

            # -------------------------------------------------
            # ESC START
            # -------------------------------------------------

            if ch == "\x1b":
                self._state = "escape"
                i += 1
                continue

            # -------------------------------------------------
            # CONTROL
            # -------------------------------------------------

            if ch == "\r":
                self.carriage_return()

            elif ch == "\n":
                self.newline()

            elif ch == "\b":
                self.backspace()

            elif ch == "\t":
                self.tab()

            elif ch == "\x07":
                pass

            elif ord(ch) >= 0x20:
                self.put_char(ch)

            i += 1

    # =========================================================
    # EXPORT
    # =========================================================

    def rows_as_text(self):
        lines = list(self.scrollback)

        lines.extend(
            "".join(
                cell.char
                for cell in row
            )
            for row in self.grid
        )

        return lines
