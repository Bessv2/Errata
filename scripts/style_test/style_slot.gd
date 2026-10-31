class_name StyleSlot
extends Resource
## One slot on the style-test board (e.g. "Hero") and the candidates to compare in it.

## Name shown above the slot.
@export var title: String = ""
## How the slot is shown: "character" stands on a floor patch, "drop" falls from
## the sky on a loop (the Inevitable Anvil), "ground" tiles a floor patch with it.
@export_enum("character", "drop", "ground") var kind: String = "character"
## Candidates; arrow keys cycle through them. Empty = "awaiting art".
@export var candidates: Array[StyleCandidate] = []
