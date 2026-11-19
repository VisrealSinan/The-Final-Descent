# Visreal combat prototype

Davey requested a playable Visreal combat prototype using the agreed movement, attacks, skills and equipment, with temporary numbers. This build implements that scope in one test chamber. It is not the completed six-floor dungeon crawler.

## Play

On Windows x64, extract `deliverables/visreal-combat-prototype-windows.zip` and open `TheFinalDescent.exe`. Keep the adjacent `.pck` file. The package includes the runtime, so no Godot installation is needed. The unpacked local build is also available in `builds/visreal-prototype/`.

To play this older practice mode from source, open `game/combat.tscn` in Godot 4.7.2 and press F6. F5 now plays the six-floor dungeon. The character animation viewer is still available by opening `previews/characters_preview.tscn` and pressing F6.

| Control | Action |
| --- | --- |
| Enter / on-screen button | Start, advance to the next fight, or retry after death |
| WASD | Move; diagonal speed is normalized |
| Hold arrow keys | Aim independently of movement and repeat melee slashes |
| Two arrow keys | Diagonal aiming |
| Q | Shadowstep toward the last arrow aim and empower the next slash |
| E | Venom Blades poison coating |
| Esc | Pause/resume |
| R | Restart the run and clear its equipment |
| Close window / Alt+F4 | Quit |

The arrow at Visreal's feet shows his aim. Enemy red arcs announce a melee attack; moving out of range avoids the strike. Ability cards show remaining cooldowns. Hover an equipment card to see its effect.

## Combat and equipment

- Twin Slashes hit enemies in a short forward arc, once per target per slash. Holding an arrow repeats attacks. Misses still consume an empowered slash.
- Shadowstep moves toward the remembered arrow aim, collides with walls, and empowers the next slash. It does not grant invulnerability. Movement keys do not overwrite attack aim.
- Venom Blades applies a poison status on melee hits. Reapplying refreshes its duration without stacking damage or postponing the pending tick. Poison can kill enemies.
- Nightshade increases shadow damage on an empowered slash against a target that was already poisoned before that hit. This keeps the poison-then-shadow combo meaningful.
- The paired swords add direct poison and shadow damage to melee hits. This direct poison damage does not by itself apply the poison status; Venom Blades supplies that status.
- Armor reduces incoming damage. Cape reduces Shadowstep's cooldown. Mask increases direct poison damage and poison tick damage. Trinket increases the shadow damage contributed by Shadowstep's empowered slash.

The player starts in the approved visual outfit with basic swords, all skills available, and no boss-equipment bonuses. Each of five test fights has one guardian and two smaller melee enemies. A guardian death automatically equips the next reward from a shuffled list of all five slots. Each slot appears exactly once. All enemies must be defeated before advancing.

Health and skill cooldowns reset at the start of each fight. Equipment persists between fights. After the fifth fight, full-kit sparring lets the player test all bonuses together. Death opens the game-over panel. Restart clears equipment, health/status state and cooldowns, resets to fight one, and reshuffles rewards.

The five test fights are an equipment test sequence, not implemented dungeon floors. The placeholder enemies, automatic equipping, between-fight healing, default keys, damage-type interaction rules and base gear are provisional implementation choices for this prototype. Final enemy designs and the six-floor adventure remain open design work.

## Temporary balance

All values live in [`game/tuning.gd`](../game/tuning.gd). They are deliberately provisional.

| Parameter | Initial value |
| --- | --- |
| Health / movement speed | 140 / 230 pixels per second |
| Basic hit / attack interval | 18 physical / 0.42 seconds |
| Shadowstep | 4.5-second cooldown; 26 bonus shadow damage |
| Empowerment window | 4 seconds |
| Venom Blades | 8-second cooldown; 4-second coating |
| Poison status | 3 seconds; 5 damage every 0.5 seconds |
| Nightshade | 1.5x shadow damage on an empowered strike against existing poison |
| Paired swords | +7 direct shadow and +7 direct poison per melee hit |
| Armor | 25% damage reduction |
| Cape | 30% shorter Shadowstep cooldown |
| Mask | 50% more direct and ticking poison damage |
| Trinket | 50% more Shadowstep-contributed shadow damage |

## Validation and packaging

Run the integration checks with the Godot console executable:

```powershell
& $GodotPath --headless --path . --script tools/check_combat.gd
& $GodotPath --headless --path . --script tools/check_character.gd -- visreal
```

The combat suite checks physical-key input, normalized movement, independent and diagonal aim, melee direction/range, hold-to-repeat, dash collisions/cooldowns, poison timing/refresh/expiration, Nightshade, every gear effect, enemy windup/dodging/damage, all five boss rewards, pause, death and restart. It also tests fresh reward permutations across 20 new runs. It has been run against both source and the standalone package. Rendered output was inspected using `tools/capture_combat.gd`.

The current Windows packaging command builds the six-floor dungeon. To rebuild it:

```powershell
./tools/package_windows.ps1 -GodotPath 'C:/path/to/Godot_v4.7.2-stable_win64_console.exe'
```

The packaging script uses an explicit runtime dependency list and bundles the installed Godot GUI runtime alongside a same-name PCK. This avoids an export-template download but makes the build larger than an optimized release export. See the official [Windows distribution documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html) and [PCKPacker reference](https://docs.godotengine.org/en/stable/classes/class_pckpacker.html). The engine's [MIT license](GODOT-LICENSE.txt) is included in the ZIP.

## Remaining work

Han and Ghalrym are visual assets only. The prototype has no XP/leveling, six-floor layout, class-themed finale, audio, or final enemy designs. The separate dungeon scene now implements six floors, run XP and Visreal’s finale.
