SMODS.Atlas {
    key = "Sachamodz",
    path = "Sachamod.png",
    px = 71,
    py = 95
}

SMODS.Joker {
	key = 'The_Jonker',
	loc_txt = {
		name = 'The jonker',
		text = {
			"{C:green}#2# in #3#{} chance this",
			"joker does {C:mult}+#1#{} Mult,",
            "else it does {C:chips}+#4#{} Chips"
		}
	},
	config = { extra = { mult = 40, odds = 3, chips = 150 } },
	rarity = 2,
	atlas = 'Sachamodz',
	pos = { x = 0, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.chips } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
            if pseudorandom('The_Jonker') < G.GAME.probabilities.normal / card.ability.extra.odds then
				return {
                    mult_mod = card.ability.extra.mult,
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
                }
			else
				return {
					chip_mod = card.ability.extra.chips,
                    message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips}}
				}
			end
		end
	end
}

SMODS.Joker {
	-- How the code refers to the joker.
	key = 'nine_mania',
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Nine mania',
		text = {
			--[[
			The #1# is a variable that's stored in config, and is put into loc_vars.
			The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
				There's {X:}, which sets the background, usually used for XMult.
				There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
				There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
				Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
				You can find the vanilla joker descriptions and names as well as several other things in the localization files.
				]]
			"Retrigger all scored {C:attention}9{} cards {C:attention}10 times{} "
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { repetitions = 10 } },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 3,
	-- Which atlas key to pull from.
	atlas = 'Sachamodz',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 1, y = 0 },
	-- Cost of card in shop.
	cost = 9,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)
		-- Tests if context.joker_main == true.
		-- joker_main is a SMODS specific thing, and is where the effects of jokers that just give +stuff in the joker area area triggered, like Joker giving +Mult, Cavendish giving XMult, and Bull giving +Chips.
		if context.cardarea == G.play and context.repetition and not context.repetition_only then
			-- context.other_card is something that's used when either context.individual or context.repetition is true
			-- It is each card 1 by 1, but in other cases, you'd need to iterate over the scoring hand to check which cards are there.
			if context.other_card:get_id() == 9 then
				return {
					message = 'Nine!',
					repetitions = card.ability.extra.repetitions,
					-- The card the repetitions are applying to is context.other_card
					card = context.other_card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'sixtynine',
	loc_txt = {
		name = '69',
		text = {
			"Gains {C:chips}+#2#{} Chips",
			"and {C:mult}+#4#{} Mult",
			"If played hand contains",
			"a {C:attention}6{} and a {C:attention}9{}.",
			"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)",
			"{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
		}
	},
	config = { extra = { chips = 0, chip_gain = 6, mult_gain = 1, mult = 0 } },
	rarity = 1,
	atlas = 'Sachamodz',
	pos = { x = 2, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain, card.ability.extra.mult, card.ability.extra.mult_gain } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips,
				mult = card.ability.extra.mult
			}
		end

		-- context.before checks if context.before == true, and context.before is true when it's before the current hand is scored.
		-- (context.poker_hands['Straight']) checks if the current hand is a 'Straight'.
		-- The 'next()' part makes sure it goes over every option in the table, which the table is context.poker_hands.
		-- context.poker_hands contains every valid hand type in a played hand.
		-- not context.blueprint ensures that Blueprint or Brainstorm don't copy this upgrading part of the joker, but that it'll still copy the added chips.
		if context.before and not context.blueprint then
			local six = false
			local nine = false
			-- Updated variable is equal to current variable, plus the amount of chips in chip gain.
			-- 15 = 0+15, 30 = 15+15, 75 = 60+15.
			for i = 1, #context.full_hand do
				if context.full_hand[i]:get_id() == 9 or context.full_hand[i]:get_id() == 6 then
					if context.full_hand[i]:get_id() == 9 then
						nine = true
					end

					if context.full_hand[i]:get_id() == 6 then
						six = true
					end
				end
				if nine == true and six == true then
					

					card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
					card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
					return {
					message = 'Nice!',
					colour = G.C.CHIPS,
					-- The return value, "card", is set to the variable "card", which is the joker.
					-- Basically, this tells the return value what it's affecting, which if it's the joker itself, it's usually card.
					-- It can be things like card = context.other_card in some cases, so specifying card (return value) = card (variable from function) is required.
					card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'the_Highest_Card',
	loc_txt = {
		name = 'The highest card',
		text = {
			"Gains {X:mult,C:white}X#2#{} for ",
			"every {C:attention}High card{} played",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { Xmult = 1, Xmult_gains = 0.1} },
	rarity = 2,
	atlas = 'Sachamodz',
	pos = { x = 3, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gains } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
				Xmult_mod = card.ability.extra.Xmult
			}
		end
		if context.before and context.poker_hands['High Card'] and not context.blueprint then
			card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gains

			return{
				message = 'High!',
				colour = G.C.CHANCE,

				card = card
			}
		end
	end
}