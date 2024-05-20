-- TODO: use preprocess

local full_latin_lexicon = require("romanized_lexicon")
local latin_lexicon = {}
for k, v in pairs(full_latin_lexicon) do
	latin_lexicon[k] = (type(v) == "table" and v[1]) or v
end


---@type table<string, SitelenPona>
local cyrillic_lexicon = {}

-- Я знаю что это неправильно, но хуже иметь не правильное отображение
local latin_to_cyrillic = {
	a = "а",
	e = "э",
	i = "и",
	k = {"к", "г"},
	l = "л",
	m = "м",
	n = "н",
	o = "о",
	p = {"п", "б"},
	s = {"с", "c", "з"},
	t = {"т", "д"},
	w = {"в", "ў"},
	j = "й",
	u = "у"
}
local latin2_to_cyrillic = {
	jo = "ё",
	je = {"е", "є"},
	ju = "ю",
	ja = "я",
}


-- It has some mistakes and it can be optimized
for word, sitelen_pona in pairs(latin_lexicon) do
	---@param _word string
	local function parse_word(_word)
		local new_words = {}

		---@param letter string|string[]
		local function add_letter(letter)
			local is_table = type(letter) == "table"

			if not is_table then
				if #new_words == 0 then
					new_words[1] = letter
				else
					for k, __word in pairs(new_words) do
						new_words[k] = __word .. letter
					end
				end
			else
				---@cast letter string[]
				if #new_words == 0 then
					for _, cyrillic_letter in pairs(letter) do
						new_words[#new_words+1] = cyrillic_letter
					end
				else
					local new_words2 = {}
					for _, cyrillic_letter in pairs(letter) do
						for _, __word in pairs(new_words) do
							new_words2[#new_words2+1] = __word .. cyrillic_letter
						end
					end

					for k, v in pairs(new_words2) do
						new_words[k] = v
					end
				end
			end
		end

		for letter in _word:gmatch(".") do
			local cyrillic = latin_to_cyrillic[letter]
			add_letter(cyrillic or letter)
		end

		-- Add words
		for _, new_word in pairs(new_words) do
			cyrillic_lexicon[new_word] = sitelen_pona
		end
		for k in pairs(new_words) do
			new_words[k] = nil
		end
	end

	---@param _word string
	local function recursive_parse_word(_word)
		for latin_pattern, new_cyrillic_letter in pairs(latin2_to_cyrillic) do
			local new_word, last_word
			repeat
				print(string.format("new_word: %s, last_word: %s, _word: %s latin_pattern: %s", new_word or "", last_word or "", _word, latin_pattern))
				if type(new_cyrillic_letter) ~= "table" then
					new_word = _word:gsub(latin_pattern, new_cyrillic_letter, 1)
					if new_word ~= last_word and new_word ~= _word then
						last_word = new_word
						parse_word(new_word)
						recursive_parse_word(new_word)
					end
				else
					for _, _new_cyrillic_letter in pairs(new_cyrillic_letter) do
						new_word = _word:gsub(latin_pattern, _new_cyrillic_letter, 1)
						if new_word ~= last_word and new_word ~= _word then
							last_word = new_word
							parse_word(new_word)
							recursive_parse_word(new_word)
						end
					end
				end
			until( new_word == last_word or last_word == nil )
		end
	end

	parse_word(word)
	recursive_parse_word(word)
end

return cyrillic_lexicon
