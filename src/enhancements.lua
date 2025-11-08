SMODS.Atlas {
    key = "jonkler_enhancement",
    path = "jonkler_enhancement.png",
    px = 71,
    py = 95
}

SMODS.Enhancement {
    key = "geel",
    atlas = "jonkler_enhancement",
    pos = { x = 0, y = 0 },
    config = {
        h_x_mult = 1.5,
        h_dollars = 3,
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.h_x_mult, self.config.h_dollars } }
    end,
    loc_txt = {
        name = "Geel Card",
        text = {
            "{C:white,X:red}X#1#{} {C:red}Mult{} when held in hand",
            "{C:money}$#2#{} if this card is",
            "held in hand at",
            "end of round"
        },
    },
}

--you can just use the enhancement key instead of e_polychrome there if you made a new enhancement 