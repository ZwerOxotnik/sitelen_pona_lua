-- Library to simplify text interactions with sitelen pona
-- sitelen pona: https://sona.pona.la/wiki/sitelen_pona/en
-- toki pona: https://tokipona.org
-- Maintainer: ZwerOxotnik
-- License: MIT


---@class SitelenPonaModule : module
local M = {
	_VERSION = "0.0.1",
	_LICENSE = "MIT",
	_SOURCE  = "https://github.com/ZwerOxotnik/sitelen_pona_lua"
}


---@type table<string, SitelenPona>[]
local __syntax = require("sitelen_pona_syntax")
M.__syntax = __syntax


---@class SitelenPonaPart : table
---@field sitelep_pona SitelenPona?
---@field original string
---@field is_add_space boolean


---@param word string
---@return SitelenPona?
function M.toki_pona_to_sitelen_pona(word)
	return __syntax[word]
end


---@param _text string
---@return SitelenPonaPart[], boolean # string, is sitelen pona?
function M.toki_pona_mute_to_sitelen_pona(_text)
	local is_sitelen_pona = false
	local result = {}

	local function parse(text)
		local _, end_i, punc, word, punc2 = text:find("^([%p]*)([^%p]*)([%p]*)")
		result[#result+1] = {
			original = punc,
			is_add_space = (#text == end_i and word == nil)
		}
		if word then
			local sitelen_pona = __syntax[word]
			result[#result+1] = {
				sitelep_pona = sitelen_pona,
				original = word,
				is_add_space = (#text == end_i and punc2 == nil)
			}
		end
		if punc2 then
			result[#result+1] = {
				original = punc2,
				is_add_space = #text == end_i
			}
		end
		if #text ~= end_i then
			parse(text:sub(end_i+1, #text))
		end
	end

	for part_text in _text:gmatch("[^%s]+") do
		parse(part_text)
	end

	return result, is_sitelen_pona
end


return M
