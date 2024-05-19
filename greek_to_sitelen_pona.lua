-- TODO: use preprocess

local dictionary = require("latin_to_sitelen_pona")
---@type table<string, string>
local greek_lexicon = {}

-- It's probably wrong!
local latin_to_greek = {
	a = "α",
	e = "ε",
	i = "ι",
	k = "κ",
	l = "λ",
	m = "μ",
	n = "ν",
	o = "ο",
	p = "π",
	s = "σ",
	t = "τ",
	u = "υ"
}

-- It's probably wrong!
for word, sitelen_pona in pairs(dictionary) do
	local new_word = ""
	for l in word:gmatch(".") do
		new_word = new_word .. (latin_to_greek[l] or l)
	end
	greek_lexicon[new_word] = sitelen_pona
end

return greek_lexicon
