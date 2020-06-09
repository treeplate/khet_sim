# khet_sim
## Idea
The idea came from the game [Khet](https://en.wikipedia.org/wiki/Khet_(game)).
`main.dart` reads from `in.khet` and prints to `stdout` where the laser goes.
## Input
An 8x10 with the following characters:
- `|`  : nothing on this square (`EmptyPiece`)
- `|/\`: obelisk or pharaoh(`Obelisk`)
- `|RB`, `|BL`, `|TR`, `|LT`: Pyramids (`RBMirror`, `BLMirror`, `TRMirror`, and `LTMirror`)
- `|\\` and `|//`: Djeds (`TRBLDjed` and `LTRBDjed`)
## Output
A string printed to `stdout` of the form `"$x, $y"` where `"1, 0"` is the laser.

