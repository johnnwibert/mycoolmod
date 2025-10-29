SMODS.Atlas {
    key = "mycoolmod",
    path = "mycoolmod.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "evil_ass_joker",
    rarity = 1,
    atlas = 'mycoolmod',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    cost = 1,
    discovered = true,
    config = {extra = { mult = -20}, },
    loc_txt = {
        name = "Evil Ass Joker",
        text = {
            "Does some",
            "{C:mult, s:1.2}Evil Ass{} shit",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                message = 'Get Fucked!'
            }
        end
    end
}

SMODS.Joker {
    key = "illusion_joker",
    rarity = 2,
    atlas = 'mycoolmod',
    pos = { x = 1, y = 0 },
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    loc_txt = {
        name = "Master of Illusions",
        text = {
            "On {C:attention}first hand of round{}, turns a random",
            "{C:attention}scoring card{} into a {C:green}lucky card{}, then",
            "destroys a random card held in hand",
        },
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local scored_card = pseudorandom_element(context.scoring_hand, 'Gobker')
            if scored_card then
                scored_card:set_ability('m_lucky', nil, true)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        scored_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = 'Magic!'
                }
            end
        end
        if context.joker_main and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local card_to_destroy = pseudorandom_element(G.hand.cards, 'random_destroy')
            SMODS.destroy_cards(card_to_destroy)
            return {
                message = 'Disappear!'
            }
        end
    end
}

SMODS.Joker {
    key = "your_card",
    rarity = 1,
    atlas = 'mycoolmod',
    pos = { x = 2, y = 0 },
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Is This Your Card?",
        text = {
            "On {C:attention}first hand of round{},",
            "each played {C:attention}#2#{} of {V:1}#3#{} ",
            "gives {C:money}$#1#{} when scored",
            "{s:0.8}Card changes every round"
            },
    },
    config = { extra = { dollars = 5 } },
    loc_vars = function(self, info_queue, card)
        local money_card = G.GAME.current_round.money_card or { rank = 'Ace', suit = 'Spades' }
        return {
            vars = { card.ability.extra.dollars, localize(money_card.rank, 'ranks'), localize(money_card.suit, 'suits_plural'), colours = { G.C.SUITS[money_card.suit] } }
        }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.individual and context.cardarea == G.play and 
            context.other_card:get_id() == G.GAME.current_round.money_card.id and
            context.other_card:is_suit(G.GAME.current_round.money_card.suit) and
            G.GAME.current_round.hands_played == 0 then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
}

SMODS.Joker {
    key = "heroic_sacrifice",
    rarity = 2,
    atlas = 'mycoolmod',
    pos = { x = 3, y = 0 },
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Heroic Sacrifice",
        text = {
            "When sold, re-enables a",
            "random {C:attention}disabled{} joker",
            "{s:0.8}If applicable, removes Perishable sticker"
        },
    },
    calculate = function(self, card, context)
        if context.selling_self then
            local valid_jokers = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.perishable or v.debuff then
                    table.insert(valid_jokers, v)
                end
            end
            local joker_to_save = pseudorandom_element(valid_jokers, 'heroic_sacrifice')

            if joker_to_save then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        joker_to_save:juice_up(0.8, 0.8)
                        card:start_dissolve({ G.C.RED }, nil, 2.5)
                        return true
                    end
                }))
                joker_to_save.ability.perishable = nil
                joker_to_save.debuff = nil
                return {
                    message = "I'll be back!", extra = { message = "Thanks!", message_card = joker_to_save }
                }
            end
        end
    end
}

SMODS.Joker {
    key = "transmutation_joker",
    rarity = 3,
    atlas = 'mycoolmod',
    pos = { x = 4, y = 0 },
    blueprint_compat = false,
    cost = 8,
    discovered = true,
    loc_txt = {
        name = "Transmutation Joker",
        text = {
            "All {C:attention}Steel Cards{} act as",
            "{C:attention}Gold Cards{} and vice versa"
        },
    },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.jokers and not context.blueprint then
            for i = 1, #G.hand.cards do
                local c = G.hand.cards[i]
                if c.ability.steel or c.ability.gold then
                    local key = c.config.center.key
                    c:set_ability('m_geel', nil, true)
                    c.ability.old_enhancement = key
                end
            end
        end
    end
}

SMODS.Joker {
    key = "piggy_bank",
    rarity = 1,
    atlas = 'mycoolmod',
    pos = { x = 5, y = 0 },
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    loc_txt = {
        name = "Piggy Bank",
        text = {
            "Gains {C:money}$#1#{} of {C:attention}sell value{}",
            "per reroll in the shop. {C:green}#2# in #3#{} chance",
            "to break per reroll in the shop."
        },
    },
    config = { extra = { price = 2, odds = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.price, (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'piggy_bank', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Whoops!",
                    play_sound('glass2')
                }
            else
                card.ability.extra_value = card.ability.extra_value + card.ability.extra.price
                card:set_cost()
                return {
                    message = "Invested!"
                }
            end
        end
        if context.selling_self or context.getting_sliced then
            return {
                message = "Smashed!",
                play_sound('glass2')
            }
        end
    end
}

SMODS.Enhancement {
    key = "geel",
    config = {
        h_x_mult = 1.5,
        h_dollars = 3,
        old_enhancement = nil,
    },
    weight = 0.1,
    in_pool = function(self, args)
        return false
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.h_x_mult, self.config.h_dollars } }
    end
}

local function reset_money_card()
    G.GAME.current_round.money_card = { rank = 'Ace', suit = 'Spades' }
    local valid_money_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(playing_card) and not SMODS.has_no_rank(playing_card) then
            valid_money_cards[#valid_money_cards + 1] = playing_card
        end
    end
    local money_card = pseudorandom_element(valid_money_cards, 'your_card' .. G.GAME.round_resets.ante)
    if money_card then
        G.GAME.current_round.money_card.rank = money_card.base.value
        G.GAME.current_round.money_card.suit = money_card.base.suit
        G.GAME.current_round.money_card.id = money_card.base.id
    end
end

function SMODS.current_mod.reset_game_globals(run_start)
    reset_money_card()
end
