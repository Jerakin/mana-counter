local M = {}

-- Version for user consent, update this if user agreement changes
M.user_consent = 1

M.icons = {
	"empty",
	"ability-activated", "ability-adamant", "ability-adapt", "ability-addendum", "ability-adventure", 
	"ability-afflict", "ability-afterlife", "ability-aftermath", "ability-amass", 
	"ability-ascend", "ability-companion", "ability-constellation", "ability-convoke", 
	"ability-deathtouch", "ability-defender", "ability-devotion", "ability-doublestrike", 
	"ability-embalm", "ability-enrage", "ability-escape", "ability-eternalize", "ability-explore", 
	"ability-firststrike", "ability-flash", "ability-flying", "ability-haste", "ability-hexproof-black", 
	"ability-hexproof-blue", "ability-hexproof-green", "ability-hexproof-red", "ability-hexproof-white", 
	"ability-hexproof", "ability-indestructible", "ability-jumpstart", "ability-lifelink", 
	"ability-menace", "ability-mentor", "ability-mutate", "ability-proliferate", "ability-prowess", 
	"ability-raid", "ability-reach", "ability-revolt", "ability-riot", "ability-spectacle", 
	"ability-static", "ability-summoning-sickness", "ability-surveil", "ability-trample", 
	"ability-transform", "ability-triggered", "ability-undergrowth", "ability-vigilance", "acorn", 
	"artifact", "artist-brush", "artist-nib", "chaos", "clan-abzan", "clan-atarka", "clan-dromoka",
	"clan-jeskai", "clan-kolaghan", "clan-mardu", "clan-ojutai", "clan-silumgar", "clan-sultai", 
	"clan-temur", "conspiracy", "counter-arrow", "counter-brick", "counter-charge", "counter-devotion",
	"counter-doom", "counter-echo", "counter-flame", "counter-flood", "counter-fungus", "counter-gold", 
	"counter-ki", "counter-lore", "counter-loyalty", "counter-mining", "counter-minus-uneven", 
	"counter-minus", "counter-muster", "counter-paw", "counter-pin", "counter-plus-uneven", 
	"counter-plus", "counter-scream", "counter-skeleton", "counter-skull", "counter-slime", 
	"counter-time", "counter-verse", "counter-vortex", "creature", "dfc-day", "dfc-emrakul",
	"dfc-enchantment", "dfc-ignite", "dfc-moon", "dfc-night", "dfc-spark", "e", "enchantment", 
	"flashback", "guild-azorius", "guild-boros", "guild-dimir", "guild-golgari", "guild-gruul", 
	"guild-izzet", "guild-orzhov", "guild-rakdos", "guild-selesnya", "guild-simic", "half", 
	"infinity", "instant", "land", "loyalty-down", "loyalty-start", "loyalty-up", "loyalty-zero",
	"multiple", "p", "phenomenon", "plane", "planeswalker", "polis-akros", "polis-meletis", 
	"polis-setessa", "power", "rarity", "s", "saga", "scheme", "sorcery", "tap-alt", "tap", "token", 
	"toughness", "untap", "vanguard", "x", "y", "z "
}

return M