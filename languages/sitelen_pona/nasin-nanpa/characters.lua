-- Created for "nasin-nanpa" font (https://github.com/ETBCOR/nasin-nanpa)

package.loaded.romanized_lexicon = nil
local full_latin_lexicon = require("romanized_lexicon")
package.loaded.romanized_lexicon = nil

local latin_lexicon = {}
for k, v in pairs(full_latin_lexicon) do
	latin_lexicon[k] = (type(v) == "table" and v[1]) or v
end

package.loaded.numbers = nil
local numbers = require("numbers")
package.loaded.numbers = nil


local result = {
	["["] = "󱦐",
	["]"] = "󱦑",
	-- ["("] = "(",
	-- [")"] = ")",
	-- ["-"] = "-",
	["="] = latin_lexicon.sama,
	["「"] = "「",
	["」"] = "」",
	["﹁"] = "﹁", -- TODO: fix
	["﹂"] = "﹂", -- TODO: fix
	["《"] = "《",
	["》"] = "》",
	["«"] = "«",
	["»"] = "»",
	["『"] = "『",
	["』"] = "』",
	["„"] = "„",
	-- ["‚"] = "‚",
	-- ["."] = ".",
	[","] = ",",
	["、"] = ",",
	["。"] = ".",
	["+"] = latin_lexicon.en,
	["?"] = latin_lexicon.seme,
}

for k, v in pairs(numbers) do
	if v == 1 then
		result[k] = latin_lexicon.wan
	elseif v == 2 then
		result[k] = latin_lexicon.tu
	elseif v == 5 then
		result[k] = latin_lexicon.luka
	end
end


return result
