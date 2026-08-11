# corne-zmk-config

ZMK firmware configuration for a Corne (crkbd) split keyboard.

## The board

A standard 3x6 Corne: 42 keys split across two halves, three columns of six on
each side plus three thumb keys per half. The shield here targets Seeed Studio
XIAO BLE controllers (`xiao_ble`), with a `col2row` matrix (4 rows x 12
columns) and an SSD1306 128x32 OLED on each half over I2C. It builds on the
upstream `foostan/corne` physical layouts and exposes both 6-column and
5-column transforms.

## Layers

Three layers, in `config/corne_xiao.keymap` (mirrored under
`boards/shields/corne_xiao/`):

- **default** — QWERTY with `LCTRL`/`LSHFT` on the home block and `LGUI`,
  `SPACE`, `RET`, `RALT` thumbs. `mo 1` and `mo 2` reach the other layers.
- **lower** — number row, arrow cluster, and Bluetooth (`BT_CLR`,
  `BT_SEL 0-4`).
- **raise** — symbols and brackets.

## Building and flashing

The GitHub Actions workflow (`.github/workflows/build.yml`) runs ZMK's
`build-user-config.yml` on push, pull request, or manual dispatch. `build.yaml`
builds `corne_left` and `corne_right` on `xiao_ble`.

To flash: download the `.uf2` artifacts from the workflow run, put each half
into bootloader mode (double-tap reset), and drop the matching `.uf2` onto the
mounted drive.

RGB underglow and the display are left as commented-out suggestions in the
`.conf` files; enable them there if your build has the hardware.
