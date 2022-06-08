string[] Function GetCustomConfigSections(string fileName) native global

; Get all the keys and values contained in a section. Both at once to avoid discrepancies in the order.
;	The keys are in VarToVarArray(Var[0]) as String[] and the values in VarToVarArray(Var[1]) as String[]
Var[] Function GetCustomConfigOptions(string fileName, string section) native global

int Function GetCustomConfigOption_UInt32(string name, string section, string key) native global


String KeyFromINI = "Dummy.esp" as String
String ValueFromINI = "0x00FFFF" as String; or "00FFFF"
Form Game.GetFormFromFile(ValueFromINI, KeyFromINI) as Form


    30 - Hair on top of head / most hats
    31 - long hair / flight cap linings / under helmet / hat hoods
    32 - FaceGenHead (used if your worried about the face clipping through a full face mask)
    33 - Full outfits - Shoes / Boots
    34 - Left Hand
    35 - Right Hand
    36 - Arm Add-on (Bracelets), Melee weapon on back
    37 - Torso Layered Add-on (Jackets)
    38 - Separate Tops (for vanilla outfits that need a second slot to show all armatures-Cage/Spike/ChildofAtom)
    39 - Leg Add-on (Gun on Hip/Tights/Stockings/Vanilla outfits that need a third slot to show all armatures-ChildofAtom)
    40 - Separate Pants / Shorts /S kirts
    41 - Torso armor
    42 - Left Arm armor
    43 - Right Arm armor
    44 - Left Leg armor
    45 - Right Leg armor
    46 - Earrings / Masks that cover face / Headbands /(hats/helmets/hoods meant to show all hair)
    47 - Eyes (Glasses / Eyepatchs)
    48 - Beard (surgical mask / lower face masks)
    49 - Mouth (surgical mask / lower face masks)(toothpick / cigarette / joint / cigar / blunt / lip rings)
    50 - Necklace / Scarfs
    51 - Ring
    54 - Backpacks / Capes / Cloaks
    55 - Belts (utility belts/gunbelts/sword belts) / Gun on hip / Satchels
    56 - Shoulder Harnesses / Bandoliers
    57 - Plate Carrier / Cargo Pack Vests(front and back torso) / Capes / Cloaks(alternate backup slot)
    58 - Body Jewelry (piercings) / Gun on back
    61 - Off-Hand Accessories (Sword Sheath / Decorative Gun / SOS)