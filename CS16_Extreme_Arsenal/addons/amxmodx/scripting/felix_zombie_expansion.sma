#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <zombie_plague_special>
#include <zpsp_const>

#define PLUGIN "Extreme Zombie Arsenal"
#define VERSION "1.0.0"
#define AUTHOR "Manus Assistant"
#define MAX_PLAYERS 32
#define XP_PER_KILL 25
#define MAX_LEVEL 50

new g_item[28], g_level[MAX_PLAYERS + 1], g_xp[MAX_PLAYERS + 1], g_vault;
new g_fx_flame, g_fx_frost;
new const g_weapon_models[][] = {
    "models/extreme/v_thunder_ak.mdl", "models/extreme/v_plasma_m4.mdl", "models/extreme/v_inferno_xm.mdl",
    "models/extreme/v_vulcan_m249.mdl", "models/extreme/v_golden_deagle.mdl", "models/extreme/v_rail_awp.mdl",
    "models/extreme/v_storm_scout.mdl", "models/extreme/v_frost_p90.mdl", "models/extreme/v_acid_mp5.mdl",
    "models/extreme/v_soul_reaper.mdl", "models/extreme/v_demon_hell_claw.mdl", "models/extreme/v_demon_plasma_claw.mdl", "models/extreme/v_dual_annihilators.mdl",
    "models/extreme/v_meteor_ak.mdl", "models/extreme/v_golden_plasma_m4.mdl", "models/extreme/v_void_awp.mdl",
    "models/extreme/v_inferno_galil.mdl", "models/extreme/v_thunder_famas.mdl", "models/extreme/v_quantum_aug.mdl",
    "models/extreme/v_gravity_shotgun.mdl"
};
new g_zclass[4], g_hclass[2], g_super_mode[MAX_PLAYERS + 1];
new bool:g_laser[MAX_PLAYERS + 1], bool:g_scope[MAX_PLAYERS + 1], bool:g_suppressor[MAX_PLAYERS + 1], bool:g_extended_mag[MAX_PLAYERS + 1];
new g_menu_title[] = "Extreme Arsenal";
new const g_level_xp[MAX_LEVEL + 1] = {0,100,250,450,700,1000,1350,1750,2200,2700,3250,3850,4500,5200,5950,6750,7600,8500,9450,10450,11500,12600,13800,15100,16500,18000,19600,21300,23100,25000,27000,29100,31300,33600,36000,38500,41100,43800,46600,49500,52500,55600,58800,62100,65500,69000,72600,76300,80100,84000,88000};

public plugin_precache()
{
    precache_model("models/v_deagle_wesker.mdl");
    precache_model("models/weapons/v_ak47_gold.mdl");
    precache_model("models/weapons/v_m4a1_gold.mdl");
    precache_model("models/weapons/v_awp_gold.mdl");
    precache_model("models/weapons/p_ak47_gold.mdl");
    precache_model("models/weapons/p_m4a1_gold.mdl");
    precache_model("models/weapons/p_awp_gold.mdl");
    precache_model("models/player/felix_demon/felix_demon.mdl");
    for (new i = 0; i < sizeof g_weapon_models; i++) precache_model(g_weapon_models[i]);
    precache_sound("zombie_plague/ambience.wav");
    precache_sound("zombie_plague/grenade_infect.wav");
    precache_sound("zombie_plague/nemesis1.wav");
    precache_sound("zombie_plague/zombie_infec1.wav");
    g_fx_flame = precache_model("sprites/flame.spr");
    g_fx_frost = precache_model("sprites/frost_explode.spr");
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /felix", "cmd_felix_menu");
    register_clcmd("say_team /felix", "cmd_felix_menu");
    register_clcmd("say /level", "cmd_level");
    register_clcmd("say /arsenal", "cmd_felix_menu");
    register_concmd("amx_felix_ap", "cmd_admin_ap", ADMIN_LEVEL_A, "<name/#userid> <amount>");
    register_concmd("amx_felix_level", "cmd_admin_level", ADMIN_LEVEL_A, "<name/#userid> <level>");
    RegisterHam(Ham_Killed, "player", "fw_player_killed", 1);
    RegisterHam(Ham_TakeDamage, "player", "fw_take_damage", 0);
    RegisterHam(Ham_Spawn, "player", "fw_player_spawn", 1);
    register_event("CurWeapon", "event_curweapon", "be", "1=1");
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_primary_attack", 1);
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_primary_attack", 1);
    register_forward(FM_ClientDisconnect, "fw_disconnect");

    g_vault = nvault_open("felix_zombie_levels");
    g_item[0] = zp_register_extra_item("Thunder AK", 12, ZP_TEAM_HUMAN);
    g_item[1] = zp_register_extra_item("Plasma M4", 14, ZP_TEAM_HUMAN);
    g_item[2] = zp_register_extra_item("Inferno XM", 16, ZP_TEAM_HUMAN);
    g_item[3] = zp_register_extra_item("Vulcan M249", 20, ZP_TEAM_HUMAN);
    g_item[4] = zp_register_extra_item("Golden Deagle", 25, ZP_TEAM_HUMAN);
    g_item[5] = zp_register_extra_item("Rail AWP", 30, ZP_TEAM_HUMAN);
    g_item[6] = zp_register_extra_item("Storm Scout", 20, ZP_TEAM_HUMAN);
    g_item[7] = zp_register_extra_item("Frost P90", 18, ZP_TEAM_HUMAN);
    g_item[8] = zp_register_extra_item("Acid MP5", 16, ZP_TEAM_HUMAN);
    g_item[9] = zp_register_extra_item("VIP Soul Reaper", 35, ZP_TEAM_HUMAN);
    g_item[10] = zp_register_extra_item("Demon Hell Claw", 30, ZP_TEAM_ZOMBIE);
    g_item[11] = zp_register_extra_item("VIP Dual Annihilators", 28, ZP_TEAM_HUMAN);
    g_item[12] = zp_register_extra_item("First Aid Kit", 8, ZP_TEAM_HUMAN);
    g_item[13] = zp_register_extra_item("Nano Regeneration", 12, ZP_TEAM_HUMAN);
    g_item[14] = zp_register_extra_item("Demon Blood Heal", 10, ZP_TEAM_ZOMBIE);
    g_item[15] = zp_register_extra_item("Nano Armor Repair", 14, ZP_TEAM_HUMAN);
    g_item[16] = zp_register_extra_item("Meteor AK", 24, ZP_TEAM_HUMAN);
    g_item[17] = zp_register_extra_item("Golden Plasma M4", 26, ZP_TEAM_HUMAN);
    g_item[18] = zp_register_extra_item("Void AWP", 34, ZP_TEAM_HUMAN);
    g_item[19] = zp_register_extra_item("Inferno Galil", 18, ZP_TEAM_HUMAN);
    g_item[20] = zp_register_extra_item("Thunder Famas", 18, ZP_TEAM_HUMAN);
    g_item[21] = zp_register_extra_item("Quantum AUG", 22, ZP_TEAM_HUMAN);
    g_item[22] = zp_register_extra_item("Gravity Shotgun", 22, ZP_TEAM_HUMAN);
    g_item[23] = zp_register_extra_item("Demon Plasma Claw", 35, ZP_TEAM_ZOMBIE);
    g_item[24] = zp_register_extra_item("Laser Sight", 8, ZP_TEAM_HUMAN);
    g_item[25] = zp_register_extra_item("ACOG Scope", 10, ZP_TEAM_HUMAN);
    g_item[26] = zp_register_extra_item("Combat Suppressor", 10, ZP_TEAM_HUMAN);
    g_item[27] = zp_register_extra_item("Extended Magazine", 12, ZP_TEAM_HUMAN);

    g_zclass[0] = zp_register_zombie_class("Felix Demon", "Admin demon: high HP", "felix_demon", "models/zombie_plague/v_knife_zombie.mdl", 280, 260, 0.70, 0.40);
    g_zclass[1] = zp_register_zombie_class("Plague Tank", "Heavy free class", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 420, 210, 0.85, 0.65);
    g_zclass[2] = zp_register_zombie_class("Shadow", "Fast low gravity", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 180, 330, 0.45, 0.90);
    g_zclass[3] = zp_register_zombie_class("Leaper", "Balanced jumper", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 240, 290, 0.55, 0.75);
    g_hclass[0] = zp_register_human_class("Felix VIP", "VIP firearm specialist", 115, 100, 255, 0.95);
    g_hclass[1] = zp_register_human_class("Rookie", "Free starter class", 100, 25, 245, 1.0);
}

public plugin_end() if (g_vault != INVALID_HANDLE) nvault_close(g_vault);

public client_authorized(id) { load_player(id); }
public fw_disconnect(id) { if (1 <= id <= MAX_PLAYERS) save_player(id); }

load_player(id)
{
    g_level[id] = 1; g_xp[id] = 0;
    if (g_vault == INVALID_HANDLE || !is_user_connected(id)) return;
    new auth[40], data[32], a[12], b[12], timestamp;
    get_user_authid(id, auth, charsmax(auth));
    if (nvault_lookup(g_vault, auth, data, charsmax(data), timestamp))
    {
        parse(data, a, charsmax(a), b, charsmax(b));
        g_level[id] = clamp(str_to_num(a), 1, MAX_LEVEL);
        g_xp[id] = max(0, str_to_num(b));
    }
}

save_player(id)
{
    if (g_vault == INVALID_HANDLE || !is_user_connected(id)) return;
    new auth[40], data[32]; get_user_authid(id, auth, charsmax(auth));
    formatex(data, charsmax(data), "%d %d", g_level[id], g_xp[id]); nvault_set(g_vault, auth, data);
}

public fw_player_killed(victim, attacker, shouldgib)
{
    if (!is_user_connected(attacker) || attacker == victim || zp_get_user_zombie(attacker) == zp_get_user_zombie(victim)) return;
    add_xp(attacker, XP_PER_KILL + (is_vip(attacker) ? 10 : 0));
    zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + 1);
}

add_xp(id, amount)
{
    if (!is_user_connected(id)) return;
    g_xp[id] += amount;
    while (g_level[id] < MAX_LEVEL && g_xp[id] >= g_level_xp[g_level[id]]) { g_level[id]++; client_print(id, print_center, "Felix Level Up: %d", g_level[id]); }
    save_player(id);
}

public zp_user_infected_post(id, infector, classid)
{
    if (is_demon(id)) { g_super_mode[id] = 0; zp_set_user_zombie_class(id, g_zclass[0]); }
    else if (g_level[id] >= 20) zp_set_user_zombie_class(id, g_zclass[1]);
    else if (g_level[id] >= 10) zp_set_user_zombie_class(id, g_zclass[2]);
    else zp_set_user_zombie_class(id, g_zclass[3]);
}

public zp_user_humanized_post(id, classid, attacker)
{
    if (is_vip(id)) zp_set_user_human_class(id, g_hclass[0]);
    else zp_set_user_human_class(id, g_hclass[1]);
}



super_weapon(id, mode, const weapon[], csw, ammo)
{
    g_super_mode[id] = mode;
    give_weapon(id, weapon, csw, ammo);
    client_print(id, print_chat, "[Extreme] Super weapon mode %d activated.", mode);
}

public fw_take_damage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if (!is_user_alive(attacker) || attacker == victim) return HAM_IGNORED;
    new weapon = cs_get_user_weapon(attacker), mode = g_super_mode[attacker];
    new Float:multiplier = 1.0;
    switch (mode)
    {
        case 1: if (weapon == CSW_AK47) multiplier = 2.2;
        case 2: if (weapon == CSW_M4A1) multiplier = 2.5;
        case 3: if (weapon == CSW_XM1014) multiplier = 3.0;
        case 4: if (weapon == CSW_M249) multiplier = 1.8;
        case 5: if (weapon == CSW_DEAGLE) multiplier = 5.0;
        case 6: if (weapon == CSW_AWP) multiplier = 10.0;
        case 7: if (weapon == CSW_SCOUT) multiplier = 4.5;
        case 8: if (weapon == CSW_P90) multiplier = 2.0;
        case 9: if (weapon == CSW_MP5NAVY) multiplier = 2.2;
        case 10: if (weapon == CSW_M4A1) multiplier = 4.0;
        case 11: if (weapon == CSW_KNIFE) multiplier = 3.5;
        case 12: if (weapon == CSW_ELITE) multiplier = 3.2;
        case 13: if (weapon == CSW_AK47) multiplier = 3.5;
        case 14: if (weapon == CSW_M4A1) multiplier = 3.8;
        case 15: if (weapon == CSW_AWP) multiplier = 12.0;
        case 16: if (weapon == CSW_GALIL) multiplier = 2.8;
        case 17: if (weapon == CSW_FAMAS) multiplier = 2.8;
        case 18: if (weapon == CSW_AUG) multiplier = 3.0;
        case 19: if (weapon == CSW_M3) multiplier = 4.0;
        case 20: if (weapon == CSW_KNIFE) multiplier = 5.0;
    }
    if (g_laser[attacker]) multiplier += 0.20;
    if (g_suppressor[attacker]) multiplier += 0.15;
    if (g_scope[attacker] && (weapon == CSW_AWP || weapon == CSW_SCOUT)) multiplier += 0.25;
    if (multiplier > 1.0) SetHamParamFloat(4, damage * multiplier);
    return HAM_IGNORED;
}

public fw_player_spawn(id)
{
    if (!is_user_alive(id)) return;
    g_super_mode[id] = 0;
    g_laser[id] = false; g_scope[id] = false; g_suppressor[id] = false; g_extended_mag[id] = false;
    if (is_demon(id)) { set_user_health(id, max(get_user_health(id), 250)); zp_set_user_knockback(id, 0.45); }
    if (is_vip(id)) set_user_armor(id, max(get_user_armor(id), 75));
}

public zp_extra_item_selected(id, itemid)
{
    for (new i = 0; i < sizeof g_item; i++) if (itemid == g_item[i]) { use_item(id, i); return; }
}

use_item(id, item)
{
    if (!is_user_alive(id)) return;
    switch (item)
    {
        case 0: super_weapon(id, 1, "weapon_ak47", CSW_AK47, 90);
        case 1: super_weapon(id, 2, "weapon_m4a1", CSW_M4A1, 90);
        case 2: super_weapon(id, 3, "weapon_xm1014", CSW_XM1014, 40);
        case 3: super_weapon(id, 4, "weapon_m249", CSW_M249, 200);
        case 4: super_weapon(id, 5, "weapon_deagle", CSW_DEAGLE, 35);
        case 5: super_weapon(id, 6, "weapon_awp", CSW_AWP, 30);
        case 6: super_weapon(id, 7, "weapon_scout", CSW_SCOUT, 90);
        case 7: super_weapon(id, 8, "weapon_p90", CSW_P90, 150);
        case 8: super_weapon(id, 9, "weapon_mp5navy", CSW_MP5NAVY, 120);
        case 9: if (is_vip(id)) super_weapon(id, 10, "weapon_m4a1", CSW_M4A1, 200); else client_print(id, print_chat, "[Extreme] VIP فقط.");
        case 10: if (is_demon(id)) { g_super_mode[id] = 11; client_print(id, print_chat, "[Extreme] Demon Hell Claw activated."); } else client_print(id, print_chat, "[Extreme] Demon فقط.");
        case 11: if (is_vip(id)) super_weapon(id, 12, "weapon_elite", CSW_ELITE, 120); else client_print(id, print_chat, "[Extreme] VIP فقط.");
        case 12: set_user_health(id, min(get_user_health(id) + 100, 250));
        case 13: set_user_health(id, min(get_user_health(id) + 180, 350));
        case 14: set_user_health(id, min(get_user_health(id) + 220, 500));
        case 15: set_user_armor(id, min(get_user_armor(id) + 100, 200));
        case 16: super_weapon(id, 13, "weapon_ak47", CSW_AK47, 180);
        case 17: super_weapon(id, 14, "weapon_m4a1", CSW_M4A1, 180);
        case 18: super_weapon(id, 15, "weapon_awp", CSW_AWP, 60);
        case 19: super_weapon(id, 16, "weapon_galil", CSW_GALIL, 180);
        case 20: super_weapon(id, 17, "weapon_famas", CSW_FAMAS, 180);
        case 21: super_weapon(id, 18, "weapon_aug", CSW_AUG, 180);
        case 22: super_weapon(id, 19, "weapon_m3", CSW_M3, 80);
        case 23: if (is_demon(id)) { g_super_mode[id] = 20; client_print(id, print_chat, "[Extreme] Demon Plasma Claw activated."); } else client_print(id, print_chat, "[Extreme] Demon فقط.");
        case 24: g_laser[id] = true;
        case 25: g_scope[id] = true;
        case 26: g_suppressor[id] = true;
        case 27: g_extended_mag[id] = true;
    }
    client_print(id, print_chat, "[Extreme] تم تفعيل العنصر رقم %d", item + 1);
}

give_weapon(id, const weapon[], csw, ammo)
{
    give_item(id, weapon); cs_set_user_bpammo(id, csw, ammo);
}

public event_curweapon(id)
{
    if (!is_user_alive(id)) return;
    new weapon = read_data(2), mode = g_super_mode[id];
    if (weapon == CSW_DEAGLE && mode == 5) set_pev(id, pev_viewmodel2, "models/extreme/v_golden_deagle.mdl");
    else if (weapon == CSW_AK47 && (mode == 13 || mode == 1)) set_pev(id, pev_viewmodel2, mode == 13 ? "models/extreme/v_meteor_ak.mdl" : "models/extreme/v_thunder_ak.mdl");
    else if (weapon == CSW_M4A1 && (mode == 14 || mode == 10 || mode == 2)) set_pev(id, pev_viewmodel2, mode == 10 ? "models/extreme/v_soul_reaper.mdl" : (mode == 14 ? "models/extreme/v_golden_plasma_m4.mdl" : "models/extreme/v_plasma_m4.mdl"));
    else if (weapon == CSW_AWP && (mode == 15 || mode == 6)) set_pev(id, pev_viewmodel2, mode == 15 ? "models/extreme/v_void_awp.mdl" : "models/extreme/v_rail_awp.mdl");
    else if (weapon == CSW_XM1014 && mode == 3) set_pev(id, pev_viewmodel2, "models/extreme/v_inferno_xm.mdl");
    else if (weapon == CSW_M249 && mode == 4) set_pev(id, pev_viewmodel2, "models/extreme/v_vulcan_m249.mdl");
    else if (weapon == CSW_SCOUT && mode == 7) set_pev(id, pev_viewmodel2, "models/extreme/v_storm_scout.mdl");
    else if (weapon == CSW_P90 && mode == 8) set_pev(id, pev_viewmodel2, "models/extreme/v_frost_p90.mdl");
    else if (weapon == CSW_MP5NAVY && mode == 9) set_pev(id, pev_viewmodel2, "models/extreme/v_acid_mp5.mdl");
    else if (weapon == CSW_GALIL && mode == 16) set_pev(id, pev_viewmodel2, "models/extreme/v_inferno_galil.mdl");
    else if (weapon == CSW_FAMAS && mode == 17) set_pev(id, pev_viewmodel2, "models/extreme/v_thunder_famas.mdl");
    else if (weapon == CSW_AUG && mode == 18) set_pev(id, pev_viewmodel2, "models/extreme/v_quantum_aug.mdl");
    else if (weapon == CSW_M3 && mode == 19) set_pev(id, pev_viewmodel2, "models/extreme/v_gravity_shotgun.mdl");
    else if (weapon == CSW_KNIFE && mode == 11) set_pev(id, pev_viewmodel2, "models/extreme/v_demon_hell_claw.mdl");
    else if (weapon == CSW_KNIFE && mode == 20) set_pev(id, pev_viewmodel2, "models/extreme/v_demon_plasma_claw.mdl");
    else if (weapon == CSW_ELITE && mode == 12) set_pev(id, pev_viewmodel2, "models/extreme/v_dual_annihilators.mdl");
    if (g_extended_mag[id] && weapon >= CSW_P228 && weapon <= CSW_P90) cs_set_user_bpammo(id, weapon, 240);
    if (g_scope[id] && (weapon == CSW_AWP || weapon == CSW_SCOUT)) cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 1);
}

public fw_primary_attack(ent)
{
    new id = pev(ent, pev_owner);
    if (1 <= id <= MAX_PLAYERS && is_user_alive(id) && g_super_mode[id] > 0) fire_effect(id);
    return HAM_IGNORED;
}

fire_effect(id)
{
    new origin[3]; get_user_origin(id, origin, 3);
    new mode = g_super_mode[id], r = 255, g = 180, b = 20, sprite = g_fx_flame;
    switch (mode)
    {
        case 2, 8, 14, 18: { r = 40; g = 170; b = 255; sprite = g_fx_frost; }
        case 5, 9, 16: { r = 80; g = 255; b = 60; }
        case 6, 7, 15: { r = 190; g = 80; b = 255; }
        case 11, 20: { r = 255; g = 40; b = 40; sprite = g_fx_flame; }
        case 19: { r = 80; g = 255; b = 255; sprite = g_fx_frost; }
    }
    message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
    write_byte(TE_DLIGHT); write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2]);
    write_byte(18); write_byte(r); write_byte(g); write_byte(b); write_byte(2); write_byte(0); message_end();
    message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
    write_byte(TE_EXPLOSION); write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2]);
    write_short(sprite); write_byte(4); write_byte(20); write_byte(TE_EXPLFLAG_NOSOUND); message_end();
}

public cmd_level(id)
{
    client_print(id, print_chat, "[Extreme] المستوى: %d/%d | XP: %d/%d | AP: %d", g_level[id], MAX_LEVEL, g_xp[id], g_level[id] < MAX_LEVEL ? g_level_xp[g_level[id]] : g_xp[id], zp_get_user_ammo_packs(id));
    return PLUGIN_HANDLED;
}

public cmd_felix_menu(id)
{
    if (!is_user_alive(id)) return PLUGIN_HANDLED;
    new menu = menu_create(g_menu_title, "felix_menu_handler"), line[96];
    formatex(line, charsmax(line), "Stats: Level %d | XP %d | AP %d", g_level[id], g_xp[id], zp_get_user_ammo_packs(id)); menu_additem(menu, line, "0");
    menu_additem(menu, "Open ZP Extra Items", "1");
    menu_additem(menu, "VIP/Demon status", "2");
    menu_display(id, menu); return PLUGIN_HANDLED;
}

public felix_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    new key[8], name[64], access, callback; menu_item_getinfo(menu, item, access, key, charsmax(key), name, charsmax(name), callback);
    if (str_to_num(key) == 0) cmd_level(id);
    else if (str_to_num(key) == 1) client_cmd(id, "say /zpmenu");
    else client_print(id, print_chat, "[Extreme] VIP=%d | DEMON=%d", is_vip(id), is_demon(id));
    menu_destroy(menu); return PLUGIN_HANDLED;
}

bool:is_vip(id) return (get_user_flags(id) & ADMIN_RESERVATION) != 0;
bool:is_demon(id) return (get_user_flags(id) & ADMIN_LEVEL_H) != 0;

public cmd_admin_ap(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
    new arg[32], amount[12], target; read_argv(1, arg, charsmax(arg)); read_argv(2, amount, charsmax(amount)); target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);
    if (!target) return PLUGIN_HANDLED; zp_set_user_ammo_packs(target, zp_get_user_ammo_packs(target) + str_to_num(amount)); console_print(id, "Extreme AP updated"); return PLUGIN_HANDLED;
}

public cmd_admin_level(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
    new arg[32], value[12], target; read_argv(1, arg, charsmax(arg)); read_argv(2, value, charsmax(value)); target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);
    if (!target) return PLUGIN_HANDLED; g_level[target] = clamp(str_to_num(value), 1, MAX_LEVEL); g_xp[target] = g_level_xp[g_level[target] - 1]; save_player(target); console_print(id, "Extreme level updated"); return PLUGIN_HANDLED;
}
