-- Created for "sitelen seli kiwen" font (https://www.kreativekorp.com/software/fonts/sitelenselikiwen/)

---@class SitelenPona: string
-- TODO: use preprocess

---@type table<string, SitelenPona>
local __lexicon = {}
do
	---@type table<string, SitelenPona>[]
	local lexicons = {
		require("latin_to_sitelen_pona"),
		require("cyrillic_to_sitelen_pona"),
		require("greek_to_sitelen_pona"),
	}
	for _, _lexicon in pairs(lexicons) do
		for k, v in pairs(_lexicon) do
			__lexicon[k] = v
		end
	end
end


__lexicon["1"] = "󱥳"
__lexicon["2"] = "󱥮"
__lexicon["5"] = "󱤭"


return __lexicon
