class_name CreditsData
extends Resource
## The text shown on the in-game credits screen. Lives in data/ui/credits.tres.
## Keep it in step with CREDITS.md: every CC BY asset's required credit must appear here.

## Credits text, one line per entry. Blank lines separate sections.
@export_multiline var text: String = ""
