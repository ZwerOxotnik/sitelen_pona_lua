---@class SitelenPona: string
-- TODO: use preprocess

---@type table<string, SitelenPona>
local __syntax = {}
do
	---@type table<string, SitelenPona>[]
	local syntaxes = {
		require("latin_to_sitelen_pona"),
		require("cyrillic_to_sitelen_pona"),
		require("greek_to_sitelen_pona"),
	}
	for _, _syntax in pairs(syntaxes) do
		for k, v in pairs(_syntax) do
			__syntax[k] = v
		end
	end
end


return __syntax
