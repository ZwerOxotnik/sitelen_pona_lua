-- Library to simplify text interactions with sitelen pona
-- sitelen pona: https://sona.pona.la/wiki/sitelen_pona/en
-- toki pona: https://tokipona.org
-- Maintainer: ZwerOxotnik
-- License: MIT


---@class SitelenPonaModule : module
local M = {
	_VERSION = "0.0.2",
	_LICENSE = "MIT",
	_SOURCE  = "https://github.com/ZwerOxotnik/sitelen_pona_lua"
}


---@type table<string, SitelenPona>[]
local __syntax = require("sitelen_pona_syntax")
M.__syntax = __syntax

---@type table<string, SitelenPona>[]
local __characters_syntax = require("characters_to_sitelen_pona")
M.__characters_syntax = __characters_syntax

---@type table<string, SitelenPona>[]
local __compound_syntax = require("sitelen_pona_kulupu")
M.__compound_syntax = __compound_syntax


-- TODO: use preprocessor
local __special_chars_length = {} -- messy workaround due to Lua bug
local __dots = {
	["。"] = true,
}
local __commas = {
	["、"] = true,
}
local __special_char_expr = "(["
local __spec_string_delimeters = {
	["「"]  = "」", -- for Chinese Simplified language
	["﹁"]  = "﹂", -- for Chinese Simplified language
	["《"]  = "》", -- for Chinese Simplified language
	["«"]   = "»", -- for German language
	["『"]  = "』", -- for Japanese language
	["„"]   = "”", -- for several language
	["‚"]   = "‘", -- for several language
}
for k, v in pairs(__spec_string_delimeters) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	_, _, char = v:find("([" .. v .. "])")
	__special_chars_length[char] = #v
	__special_char_expr = __special_char_expr .. k .. v
end
for k in pairs(__dots) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	__special_char_expr = __special_char_expr .. k
end
for k in pairs(__commas) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	__special_char_expr = __special_char_expr .. k
end
__special_char_expr = __special_char_expr .. "])"


---@class SitelenPonaPart : table
---@field sitelep_pona SitelenPona?
---@field original string?
---@field is_add_space true?
---@field is_new_line boolean?


---@param word string
---@return SitelenPona?
function M.toki_pona_to_sitelen_pona(word)
	return __syntax[word]
end


---@param _text string
---@param new_line_pattern string?new_line_pattern
---@return SitelenPonaPart[], boolean # string[], is sitelen pona?
function M.toki_pona_mute_to_sitelen_pona(_text, new_line_pattern)
	new_line_pattern = new_line_pattern or "[^\r\n]+"
	local is_sitelen_pona = false
	local result = {}

	---@param word string
	---@return string
	local function find_special_characters(word)
		local last_part = word
		local last_result_i = 1
		while true do
			local first_i, last_i, char = last_part:find(__special_char_expr, last_result_i)
			if first_i == nil then
				if last_result_i == 1 then
					return word
				else
					return last_part:sub(last_result_i, #last_part)
				end
			end

			if last_result_i < last_i then
				local prev_part = last_part:sub(last_result_i, last_i-1)
				local sitelen_pona_char = __syntax[prev_part]
				if sitelen_pona_char then
					result[#result+1] = {
						sitelep_pona = sitelen_pona_char,
						original = prev_part
					}
				else
					result[#result+1] = {original = prev_part}
				end
			end

			last_result_i = last_i + (__special_chars_length[char] or 1)
			local original_char = last_part:sub(last_i, last_result_i-1)
			local sitelen_pona_char = __characters_syntax[original_char]
			if sitelen_pona_char then
				result[#result+1] = {
					sitelep_pona = sitelen_pona_char,
					original = original_char
				}
			else
				result[#result+1] = {original = original_char}
			end
			if last_i == #char then
				return ""
			end
		end
	end

	local function parse(text)
		local _, end_i, punc, word, punc2 = text:find("^([%p]*)([^%p]*)([%p]*)")
		if punc == "" then
			punc = nil
		end
		if word == "" then
			word = nil
		else
			word = find_special_characters(word)
		end
		if punc2 == "" then
			punc2 = nil
		end

		local sitelen_pona_char
		local is_end = #text == end_i
		if punc then
			sitelen_pona_char = __characters_syntax[punc]
			if sitelen_pona_char then
				result[#result+1] = {
					sitelep_pona = sitelen_pona_char,
					original = punc,
					is_add_space = (is_end and word == nil)
				}
			else
				result[#result+1] = {
					original = punc,
					is_add_space = (is_end and word == nil)
				}
			end
		end
		if word then
			local sitelen_pona = __syntax[word]
			result[#result+1] = {
				sitelep_pona = sitelen_pona,
				original = word,
				is_add_space = (is_end and punc2 == nil)
			}
		end
		if punc2 then
			sitelen_pona_char = __characters_syntax[punc2]
			if sitelen_pona_char then
				result[#result+1] = {
					sitelep_pona = sitelen_pona_char,
					original = punc2,
					is_add_space = is_end
				}
			else
				result[#result+1] = {
					original = punc2,
					is_add_space = is_end
				}
			end
		end

		if not is_end then
			parse(text:sub(end_i+1, #text))
		end
	end

	for line in _text:gmatch(new_line_pattern) do -- TODO: improve, detect several new lines
		for part_text in line:gmatch("[^%s]+") do
			parse(part_text)
		end
		result[#result+1] = {
			is_new_line = true
		}
	end

	return result, is_sitelen_pona
end


---@param parts SitelenPonaPart[]
---@return SitelenPonaPart[], boolean # is compounded?
function M.compound_sitelen_pona(parts)
	local parts_copy = {}
	for i = 1, #parts do
		parts_copy[i] = parts[i]
	end

	if #parts_copy <= 1 then return parts_copy, false end

	local original_text = ""
	local compound_length = 0
	local compound_syntax = __compound_syntax
	local i = 0
	while true do
		if i == #parts_copy then
			return parts_copy, #parts_copy ~= #parts
		end

		i = i + 1
		local part = parts_copy[i]
		if not part.sitelep_pona then
			compound_length = 0
			compound_syntax = __compound_syntax
			original_text = ""
			goto skip
		end

		if part.original == "-" then
			if compound_length > 0 then
				compound_length = compound_length + 1
			end
			goto skip
		end

		compound_syntax = compound_syntax[part.sitelep_pona] or __compound_syntax
		if compound_syntax == __compound_syntax then
			original_text = ""
			compound_length = 0

			compound_syntax = compound_syntax[part.sitelep_pona]
			if compound_syntax == nil then
				compound_syntax = __compound_syntax
				goto skip
			end
		end

		compound_length = compound_length + 1

		original_text = original_text .. part.original .. " "
		if type(compound_syntax) == "table" then
			goto skip
		end

		local prev_i = i - compound_length + 1
		for _ = 1, compound_length - 1 do
			table.remove(parts_copy, prev_i)
		end
		i = prev_i
		parts_copy[i] = {
			sitelep_pona = compound_syntax,
			original = original_text,
			is_add_space = part.is_add_space
		}

		::skip::
	end
end


return M
