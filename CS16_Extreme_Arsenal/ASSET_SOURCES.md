# Asset provenance

Fetched read-only through the GitHub connector (`gh api` / `gh repo clone`):

- Repository: https://github.com/PerfectScrash/ZP-Special-Final
- Branch: `main`
- README read: https://github.com/PerfectScrash/ZP-Special-Final/blob/main/Readme.md
- Models copied: `models/v_deagle_wesker.mdl`, `models/player/zombie_source/zombie_source.mdl`, `models/zombie_plague/*.mdl`
- Sounds copied: `sound/zombie_plague/*.wav`
- Sprites copied: `sprites/*.spr`

The upstream repository has no explicit SPDX license field and no visible license file in the checked tree. Keep attribution and verify redistribution rights before publishing publicly.


## Added weapon models

- Repository: https://github.com/DadoDz/cs16-amxx-csdm-golden-weapons
- Branch: `main`
- README identifies the project as a Counter-Strike 1.6 Golden Weapons plugin and lists custom golden models.
- Copied files: `cstrike/models/weapons/v_ak47_gold.mdl`, `v_m4a1_gold.mdl`, `v_awp_gold.mdl`, and matching `p_*.mdl` files.
- GitHub license field: none reported; preserve attribution and verify redistribution permission before public release.

## Per-weapon visual paths and muzzle effects

The expansion registers a separate `models/extreme/v_*.mdl` path for every super weapon. These are GoldSrc-valid model files staged from the compatible golden weapon assets already documented above, plus the existing Wesker Deagle and zombie claw models. The plugin precaches every path and swaps the view model per weapon mode. `Ham_Weapon_PrimaryAttack` emits a colored `TE_DLIGHT` plus a flame/frost `TE_EXPLOSION` effect per weapon mode.
