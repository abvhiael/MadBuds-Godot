# MB-3 Godot prototype integration

This branch wires a named animation-state adapter, physical impact/damage component and scoped headless tests. Approved animation files are **not yet imported**; the adapter expects verified images at `res://assets/characters/kush-krusher/animations/kk_anim_XX_name/kush_krusher_anim_XX_name_frame_NN.png`. The existing polygon is a fallback until those files arrive. Upstream source: `abvhiael/420-integrated-v0.1/assets/arcade/mad-buds/kush-krusher/animations/`. No animation art was fabricated.

Provisional destructible physics: moving Kush Krusher impacts apply relative-speed-derived damage multiplied by current mass and Wrecking Ball impulse modifier. This is gameplay prototype tuning, not canonical Unity numeric parity. Do not claim complete MB-3/engine-migration qualification until visual assets, cross-engine parity and actual level testing pass.
