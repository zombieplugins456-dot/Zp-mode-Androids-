# Extreme Zombie Arsenal — CS 1.6 / AMX Mod X

حزمة توسعة عملية فوق **Zombie Plague Special** لـ Counter-Strike 1.6. الاسم داخل اللعبة: **Extreme Zombie Arsenal**.

## ما تم تضمينه

## التوسعة الجديدة: الأسلحة والملحقات

أضيفت ثمانية أسلحة خارقة جديدة: Meteor AK، Golden Plasma M4، Void AWP، Inferno Galil، Thunder Famas، Quantum AUG، Gravity Shotgun، وDemon Plasma Claw. كما أضيفت ملحقات منفصلة: Laser Sight، ACOG Scope، Combat Suppressor، وExtended Magazine. الملحقات تغيّر الضرر أو التصويب أو الذخيرة، ولا تُسجّل كأسلحة عادية.

تم ربط موديلات GoldSrc المرئية الجاهزة لثلاثة أسلحة عبر `v_ak47_gold.mdl` و`v_m4a1_gold.mdl` و`v_awp_gold.mdl`، مع موديلات `p_` للمظهر الخارجي. لا يمكن إنشاء أو إعادة تصدير ملفات `.mdl` جديدة في هذه البيئة لعدم توفر `studiomdl`/Blender؛ لذلك استُخدمت ملفات GoldSrc الجاهزة المتوافقة مع CS 1.6، بينما تستخدم الأسلحة الأخرى موديلات CS القياسية إلى أن تُضاف لها ملفات `.mdl` مخصصة.


- **12 سلاحًا خارقًا**: Thunder AK (×2.2)، Plasma M4 (×2.5)، Inferno XM (×3)، Vulcan M249 (×1.8)، Golden Deagle (×5)، Rail AWP (×10)، Storm Scout (×4.5)، Frost P90 (×2)، Acid MP5 (×2.2)، VIP Soul Reaper (×4)، Demon Hell Claw (×3.5)، وVIP Dual Annihilators (×3.2).
- **نظام مستوى وخبرة** حتى Level 50: قتل لاعب يمنح XP، وVIP يحصل على Bonus XP، والتقدم يُحفظ عبر nVault.
- **VIP** عبر `ADMIN_RESERVATION`: درع ابتدائي وBonus XP.
- **Demon** عبر `ADMIN_LEVEL_H`: صحة إضافية وKnockback منخفض.
- **تحكم الإدارة**: `amx_felix_ap` و`amx_felix_level`.
- **واجهة اللاعب**: `/felix` أو `/arsenal`، وحالة المستوى عبر `/level`.
- أصول مستخرجة من مستودع ZP Special: موديل Wesker Deagle، موديلات القنابل، موديل zombie_source، وأصوات ZP.

## التثبيت

1. ثبّت Zombie Plague Special أولًا. قلبه ومصدره موجودان في `upstream-source/` كمرجع.
2. انسخ مجلدات `models/` و`sound/` و`sprites/` إلى مجلد خادم CS 1.6.
3. انسخ `addons/amxmodx/scripting/felix_zombie_expansion.sma` وملفات `include/` إلى بيئة AMX Mod X.
4. ترجِم الملف باستخدام `amxxpc`، ثم ضع الناتج في `addons/amxmodx/plugins/`.
5. أضف `felix_zombie_expansion.amxx` إلى `plugins-zplague.ini` أو `plugins.ini` بعد قلب ZP Special.
6. انسخ `felix_zombie_expansion.cfg` إلى `addons/amxmodx/configs/`.

## أوامر الإدارة

| الأمر | الصلاحية | الوظيفة |
|---|---|---|
| `amx_felix_ap <name/#userid> <amount>` | ADMIN_LEVEL_A | إضافة Ammo Packs |
| `amx_felix_level <name/#userid> <level>` | ADMIN_LEVEL_A | ضبط المستوى من 1 إلى 50 |

## ملاحظات التوافق

- الإضافة مبنية على natives وforwards الموجودة في `zombie_plague_special.inc` من ZP Special.
- تحتاج AMX Mod X 1.8.2+، وموديولات `cstrike`, `fun`, `fakemeta`, `hamsandwich`, `nvault`.
- قائمة الأسلحة تحتوي 12 سلاحًا خارقًا، وأضفت لها 4 علاجات منفصلة: First Aid Kit، Nano Regeneration، Demon Blood Heal، وNano Armor Repair. لا توجد قنابل أو عناصر حركة.
- ملف `.sma` مرفق؛ لم أضع `.amxx` لأن المترجم يختلف حسب بيئة الخادم وإصدار AMX Mod X.

## مصدر الأصول والتراخيص

- المصدر الأساسي الذي جُلب عبر GitHub Connector: [PerfectScrash/ZP-Special-Final](https://github.com/PerfectScrash/ZP-Special-Final).
- README للمصدر يذكر اعتماده على أعمال MeRcyLeZZ وZPA Team، ولا يضع ملف ترخيص واضحًا في المستودع.
- لذلك أُبقيت الأصول داخل الحزمة مع نسب المصدر، ويجب استخدام هذه النسخة على خادم شخصي/اختباري والتحقق من حقوق إعادة التوزيع قبل النشر العام.
- المصدر البرمجي الجديد في `felix_zombie_expansion.sma` من إعداد Felix لهذه الحزمة.

## اختبار سريع

بعد تشغيل الخادم:

1. ادخل بلاعبين.
2. استخدم `/level` للتحقق من XP/Level.
3. افتح قائمة ZP واشترِ العناصر المتاحة.
4. أعطِ لاعبًا صلاحية `b` لـ VIP أو `t` لـ Demon من `users.ini`.
5. اختبر `amx_felix_ap` و`amx_felix_level`.

## Visual weapon paths and firing effects

Every super weapon now has its own registered `models/extreme/v_*.mdl` path and a distinct firing effect color/sprite group. The plugin hooks `Ham_Weapon_PrimaryAttack`, emits a colored dynamic light and a flame/frost explosion at the firing origin, and precaches all model paths. The current assets are GoldSrc-valid staged variants from the documented golden weapon source; a future model-authoring pass can replace any individual `v_*.mdl` without changing the plugin API.
