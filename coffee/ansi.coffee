codes =
  reset:  0

  colors:
    black:    0
    red:      1
    green:    2
    yellow:   3
    blue:     4
    magenta:  5
    cyan:     6
    white:    7
    default:  9

  bold:
    on:   1
    off:  22
  bright:
    on:   1
    off:  22

  italics:
    on:   3
    off:  23

  underline:
    on:   4
    off:  24

  inverse:
    on:   7
    off:  27

  strikethrough:
    on:   9
    off:  29

foreground = (color) -> "3#{color}"

background = (color) -> "4#{color}"

ansi = (code) -> `'\033['+code+'m'`

module.exports =
  ansi:           ansi
  reset:          ansi codes.reset

  bold:           ansi codes.bold.on
  nobold:         ansi codes.bold.off

  bright:         ansi codes.bright.on
  nobright:       ansi codes.bright.off

  italics:        ansi codes.italics.on
  noitalics:      ansi codes.italics.off

  underline:      ansi codes.underline.on
  nounderline:    ansi codes.underline.off

  inverse:        ansi codes.inverse.on
  noinverse:      ansi codes.inverse.off

  strikethrough:  ansi codes.strikethrough.on
  nostrikethrough:ansi codes.strikethrough.off

  black:          ansi foreground codes.colors.black
  red:            ansi foreground codes.colors.red
  green:          ansi foreground codes.colors.green
  yellow:         ansi foreground codes.colors.yellow
  blue:           ansi foreground codes.colors.blue
  magenta:        ansi foreground codes.colors.magenta
  cyan:           ansi foreground codes.colors.cyan
  white:          ansi foreground codes.colors.white
  default:        ansi foreground codes.colors.default

  bgblack:        ansi background codes.colors.black
  bgred:          ansi background codes.colors.red
  bggreen:        ansi background codes.colors.green
  bgyellow:       ansi background codes.colors.yellow
  bgblue:         ansi background codes.colors.blue
  bgmagenta:      ansi background codes.colors.magenta
  bgcyan:         ansi background codes.colors.cyan
  bgwhite:        ansi background codes.colors.white

  style: (code, str) -> "#{code}#{str}#{@reset}"
