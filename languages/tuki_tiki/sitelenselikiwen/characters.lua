-- Created for "sitelen seli kiwen" font (https://www.kreativekorp.com/software/fonts/sitelenselikiwen/)


package.loaded.romanized_lexicon = nil
local full_latin_lexicon = require("romanized_lexicon")
package.loaded.romanized_lexicon = nil

local latin_lexicon = {}
for k, v in pairs(full_latin_lexicon) do
	latin_lexicon[k] = (type(v) == "table" and v[1]) or v
end


local result = {
	["["] = "󱦐",
	["]"] = "󱦑",
	["("] = "(",
	[")"] = ")",
	["-"] = "-",
	["="] = latin_lexicon.sama,
	["「"] = "「",
	["」"] = "」",
	["﹁"] = "﹁",
	["﹂"] = "﹂",
	["《"] = "《",
	["》"] = "》",
	["«"] = "«",
	["»"] = "»",
	["『"] = "『",
	["』"] = "』",
	["„"] = "„",
	["‚"] = "‚",
	["."] = ".",
	[","] = ",",
	["、"] = ",",
	["。"] = ".",
	["+"] = latin_lexicon.en,
	["?"] = latin_lexicon.seme,
}


return result
