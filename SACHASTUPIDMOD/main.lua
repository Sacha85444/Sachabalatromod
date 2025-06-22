-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------Seals-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SMODS.Seal {
    name = "Darkred",
    key = "Dred",
    badge_colour = HEX("640000"),
	config = { x_mult = 1.25  },
    loc_txt = {
        -- Badge name (displayed on card description when seal is applied)
        label = 'Dark red Seal',
        -- Tooltip description
        name = 'Dark red Seal',
        text = {
            'Does {X:mult,C:white}X#1#{} Mult',
            "when scored"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {self.config.x_mult} }
    end,
    atlas = "seal_atlas",
    pos = {x=0, y=0},

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = function(self, card, context)
        -- main_scoring context is used whenever the card is scored
        if context.main_scoring and context.cardarea == G.play then
            return {
                x_mult = self.config.x_mult
            }
        end
    end,
}

SMODS.Atlas {
    key = "seal_atlas",
    path = "modded_seal.png",
    px = 71,
    py = 95
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------Consumables--------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SMODS.Consumable {
    set = "Spectral",
    key = "bloodlust",
	config = {
        -- How many cards can be selected.
        max_highlighted = 2,
        -- the key of the seal to change to
        extra = 'Sach_Dred',
    },
    loc_vars = function(self, info_queue, card)
        --Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
         --Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Bloodlust',
        text = {
            "Add a {C:red}Dark red Seal{} to ",
            "{C:attention}#1#{} selected",
			"card in your hand"
        }
    },
    cost = 4,
    atlas = "Blust_atlas",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:set_seal("Sach_Dred", nil, true)
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

SMODS.Atlas {
    key = "Blust_atlas",
    path = "Bloodlust.png",
    px = 71,
    py = 95
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------DECKS-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SMODS.Atlas {
	key = "deckmod",
	path = "decks.png",
	px = 71,
	py = 95
}

SMODS.Back({
    key = "jimbo_deck",
    loc_txt = {
        name = "Jimbo",
        text={
        "Start with a",
        "{C:attention}Jimbo?{} and",
        "{C:attention}4 joker{}",
        },
    },
	
	config = { hands = 0, discards = 0},
	pos = { x = 0, y = 0 },
	order = 1,
	atlas = "deckmod",
    unlocked = true,

	apply = function(self)
        G.E_MANAGER:add_event(Event({
			func = function()
				if G.consumeables then
                    local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_Sach_jimbodude", "Sach_deck")
                    card:add_to_deck()
                    --card:start_materialize()
                    G.jokers:emplace(card)

					for i = 1, 4, 1 do
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker", "Sach_deck")
                    card:add_to_deck()
                    --card:start_materialize()
                    G.jokers:emplace(card)
            
					end
					return true
                end
			end,
		}))
	end
})


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------JOKERS----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
			"Retrigger all scored {C:attention}9{} cards {C:attention}4 times{} "
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { repetitions = 4 } },
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
			"Gains {X:mult,C:white}X#2#{} if played ",
			"hand contains {C:attention}1{} card",
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
		if context.before and next(context.poker_hands['High Card']) and not context.blueprint then
			local numberofcard = 0
			for i = 1, #context.full_hand do
				numberofcard = numberofcard +1
			end

			if numberofcard == 1 then
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gains
			

			return{
				message = 'High!',
				colour = G.C.CHANCE,

				card = card
			}
			end
		end
	end
}

SMODS.Joker {
	key = 'Onix',
	loc_txt = {
		name = 'Onix',
		text = {
			"Gains {C:chips}+#2#{} Chips for every",
			"{C:attention}Spades{} cards scored and {X:mult,C:white}X#3#{}",
			"for every {C:attention}Stones{} cards played",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
			"{C:inactive}(Currently {C:chips}+#4#{C:inactive} Chips)"
		}
	},
	config = { extra = { Xmult = 1, chips_gains_spade = 10, Xmult_gains_stone = 0.2, chips = 0} },
	rarity = 4,
	atlas = 'Sachamodz',
	pos = { x = 0, y = 1 },
	soul_pos = { x = 4, y = 1},
	cost = 10,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.chips_gains_spade, card.ability.extra.Xmult_gains_stone, card.ability.extra.chips } }
	end,
	calculate = function(self, card, context)

		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult,
				chips = card.ability.extra.chips
			}
		end

		if context.individual and context.cardarea == G.play then
			if context.other_card:is_suit('Spades') and not context.blueprint then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gains_spade
				return {
					message = 'Upgraded.',
					colour = G.C.GREY
				}
			end

			if context.other_card.ability.effect == 'Stone Card' and not context.blueprint then
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gains_stone
				return {
					message = 'Upgraded.',
					colour = G.C.GREY
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'Mgem',
	loc_txt = {
		name = 'Mystic gem',
		text = {
			"gives {C:mult}+#1#{} Mult when",
			"a {C:attention}Stone Card{} is scored.",
		}
	},
	config = { extra = {mult = 15} },
	rarity = 1,
	atlas = 'Sachamodz',
	pos = { x = 4, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.extra.mult} }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then

			if context.other_card.ability.effect == 'Stone Card' then

				return {

						mult = card.ability.extra.mult,
						card = context.other_card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'Tmap',
	loc_txt = {
		name = 'Treasure map',
		text = {
			"{C:green}#1# in #2#{} chance to",
			"create a {C:attention}Random Consumable{}",
			"when shop is rerolled"
		}
	},
	config = { extra = {odds = 6} },
	rarity = 1,
	atlas = 'Sachamodz',
	pos = { x = 5, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = {(G.GAME.probabilities.normal or 1), card.ability.extra.odds} }
	end,
	calculate = function(self, card, context)
		if context.reroll_shop then

			if pseudorandom('Tmap') < G.GAME.probabilities.normal / card.ability.extra.odds then
				return {
					   func = function ()
						local card = create_card('Consumeables', pseudorandom_element(G.consumeables.cards, pseudoseed('Tmap')), nil, nil ,nil ,nil)
						card:add_to_deck()
						G.consumeables:emplace(card)
						return true
					end,

					message = 'Treasure!',
					colour = G.C.yellow,
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'Nio',

	
	loc_txt = {
		name = 'Niomstr74',
		text = {
			"{C:attention}Sacha please{}",
			"When a {C:attention}7 of heart{} is played:",
			"Create a negative copy of {C:attention}Cavendish{}",
			"then, {C:attention}destroy this joker{}",
		}
	},
	config = { extra = {mult = 1} },
	rarity = 2,
	atlas = 'Sachamodz',
	pos = { x = 1, y = 1 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.j_cavendish
		return { vars = { card.ability.extra.mult} }
	end,
	calculate = function(self, card, context)

		if context.individual and context.cardarea == G.play then
			if context.other_card:is_suit('Hearts') and context.other_card:get_id() == 7 and not context.blueprint then

				G.E_MANAGER:add_event(Event({
					func = function()
						play_sound('tarot1')
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true;
							end
						}))
						return true
					end
				}))

				return {
						message = 'Sacha please',

						func = function ()
							local card = create_card('Joker', G.jokers, nil, nil ,nil ,nil, "j_cavendish")
							card:set_edition('e_negative', true)
							card:add_to_deck()
							G.jokers:emplace(card)
							return true
						end,
				}
			end
		end
	end
}

SMODS.Joker{
    key = 'darkw',
    loc_txt= {
        name = 'Dark world',
        text = { 	
			"{C:dark_edition}+#1#{} Joker Slot",
			"when {C:attention}Boss Blind{} is selected",
			"then {C:attention}destroy itself{}"
		}
    },
    atlas = 'Sachamodz',
    rarity = 3,
    cost = 7,
    
    unlocked = true,
    discovered = true,
    blueprint_compat = false,

    pos = {x=2, y= 1},
    config = { extra = {jokerslots = 1}},

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.jokerslots }  }
	end,

	calculate = function(self, card, context)
		if context.setting_blind then
			local boss = 0
         	if G.GAME.blind:get_type() == 'Boss' then

				G.E_MANAGER:add_event(Event({
					func = function()
						play_sound('tarot1')
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true;
							end
						}))
						return true
						
					end
				}))

				return{
					message = 'Expanded',
					colour = G.C.DARK_EDITION,
					
					func = function ()
						G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.jokerslots
						return{
							
						}
					end
				}
         	end
		end
    end,

}

SMODS.Joker {
	key = 'jimbodude',
	loc_txt = {
		name = 'Jimbo?',
		text = {
			"{C:mult}+#1#{} Mult",
			"This joker does something",
            "after {C:attention}5 round{}",
			"{C:inactive}(#2#/5)"
		}
	},
	config = { extra = { mult = 4, turnleft = 0, turnleftgain = 1} },
	rarity = 3,
	atlas = 'Sachamodz',
	pos = { x = 3, y = 1 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.turnleft, card.ability.extra.turnleftgain} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end

		if  context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
			if card.ability.extra.turnleft >= 5 then
				G.E_MANAGER:add_event(Event({
					func = function()
						play_sound('tarot1')
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true;
							end
						}))
						return true
						
					end
				}))

				return{
					message = 'Jimbo',
					colour = G.C.CHIPS,
					
					func = function ()
						local card = create_card('Joker', G.jokers, nil, nil ,nil ,nil, "j_Sach_Thejimbo")
						card:add_to_deck()
						G.jokers:emplace(card)
						return true
					end
				}
			else
				card.ability.extra.turnleft = card.ability.extra.turnleft + card.ability.extra.turnleftgain 

				return{
					message = 'Jimbo',
					colour = G.C.MULT,
				}

			end
		end
	end
}

SMODS.Joker {
	key = 'Thejimbo',
	loc_txt = {
		name = 'The jimbo',
		text = {
			"{C:mult}+#1#{} Mult and",
			"{X:mult,C:white}X#3#{} Mult",
			"{C:inactive}(Gains {C:mult}+#2#{} Mult and",
			"{X:mult,C:white}X#4#{} {C:inactive}Mult when boss{} ",
			"{C:inactive}blind is defeated){}"
		}
	},
	config = { extra = { mult = 4, mult_gains = 8, Xmult = 4, Xmult_gains = 1.5} },
	rarity = 4,
	atlas = 'Sachamodz',
	pos = { x = 0, y = 2 },
	soul_pos = { x = 5, y = 1},
	cost = 20,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_gains, card.ability.extra.Xmult, card.ability.extra.Xmult_gains } }
	end,
	calculate = function(self, card, context)

		if context.joker_main then
			return {
				mult = card.ability.extra.mult,
				Xmult = card.ability.extra.Xmult
			}
		end

		if context.setting_blind and not context.blueprint then
			card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gains
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gains
			return {
				message = "Jimbo",
				colour = G.C.MULT
			}
		end
	end
}


--[[else
	return {

		func = function ()
			local card = create_card('Consumeables', pseudorandom_element(G.consumeables.cards, pseudoseed('bloody')), nil, nil ,nil ,nil)
			card:add_to_deck()
			G.consumeables:emplace(card)
			return true
		end,

		message = 'Bloody',
		colour = G.C.MULT
	}
				--]]