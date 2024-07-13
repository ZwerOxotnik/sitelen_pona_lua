-- TODO: use preprocess

local full_latin_lexicon = require("romanized_lexicon")
local latin_lexicon = {}
for k, v in pairs(full_latin_lexicon) do
	latin_lexicon[k] = (type(v) == "table" and v[1]) or v
end


---@type table<string, SitelenPona>
local greek_lexicon = {}

local latin_to_greek = {
	a = "α",
	e = "ε",
	i = "ι",
	j = "γ",
	k = "κ",
	l = "λ",
	m = "μ",
	n = "ν",
	o = "ο",
	p = "π",
	s = "σ",
	t = "τ",
	u = "υ",
	w = "β"
}

-- It's probably wrong!
for word, sitelen_pona in pairs(latin_lexicon) do
	local new_word = ""
	for l in word:gmatch(".") do
		new_word = new_word .. (latin_to_greek[l] or l)
	end
	greek_lexicon[new_word] = sitelen_pona
end

return greek_lexicon
