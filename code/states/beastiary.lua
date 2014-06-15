-- Lionblaster Beastiary State
-- by zorg
-- @2014

-- Note: use http://josefnpat.github.io/RadarChart/ for showing semi-arbitrary stats :3
-- speed	-	Normalized between [0,1]
-- cunning	-	0: simplepath(e.g. mazesolver/wallfollower), 0.5: pseudorandom, 1: chaser
-- phasing	-	0: can't, 0.5: walls, 1: bombs and walls
-- special	- 	0: nothing, 0.5: mob specials, 1: boss
-- health	-	0: one hit kill, n/MAXHITS - how much hits it takes to kill it; MAXHITS is constant, derived from the boss that has the most health.