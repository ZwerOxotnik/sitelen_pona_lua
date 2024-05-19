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


return __lexicon
