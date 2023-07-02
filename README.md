# FO4OutfitShuffler
Transform the outfits of the NPCs in Fallout 4 with OutfitShuffler! This mod lets you mix and match clothing and accessories to create endless fashion combinations. Customize the frequency, NPC selection, and item exclusions for outfit changes to make them fit your playstyle. And if you're lucky, you might even find some new outfit pieces as loot! Plus, OutfitShuffler supports other mods like Devious Devices for even more options. So get ready to revamp the wardrobe of the wasteland with OutfitShuffler!

Installing OutfitShuffler

There are a few different ways to install OutfitShuffler:

    Download the mod with a mod manager, such as Nexus Mod Manager or Vortex.

    Drag and drop the mod file into your mod manager.

    Manually install the mod by extracting the mod file into your Fallout 4 "Data" folder.

Note that if you already have a mod that includes the Lovers Lab Four Play F4SE plugin, you may see file conflicts. As long as your other mods are up-to-date, these conflicts should not cause any issues.

Upgrading OutfitShuffler

To upgrade OutfitShuffler to a newer version:

    Remove the previous version of the mod.

    Start the game and step through the warning about OutfitShuffler.esl not being present.

    Save the game and exit.

    Install the new version of the mod.

    Start the game and save the game again.

    Continue playing.

Operating OutfitShuffler

Once the mod is installed and activated, you can access the mod's settings through the Mod Configuration Menu (MCM) in the game.

Configuring OutfitShuffler

To configure OutfitShuffler, access the mod's settings through the Mod Configuration Menu (MCM) in the game. The mod's settings are organized into the following categories:

    Rescan: Rechecks the OutfitShuffler.ini file for updates and rescans all of the INI files in the [INIFiles] section.

    Change Items: Allows you to add 25 of each of the following types of items to the player's inventory:

    DontChange Item
    AlwaysChange Item
    DontBodyGen Item
    AlwaysBodyGen Item
    DontScale Item
    AlwaysScale Item

    General Settings: Allows you to enable or disable the mod, and enable or disable changing female and male NPCs. You can also allow or disallow container loot.

    Loot Options: Allows you to enable or disable finding outfit pieces as loot in containers and on bodies, as well as set a maximum number of random container items and allow or disallow random outfit pieces in.

    Shuffling Options: Allows you to enable OneShot, Keep Clothes On, enable random BodyGen, enable OneShot for BodyGen, and random BodyGen options.

    Advanced Settings: Allows you to customize the frequency of outfit changes, specify which NPCs should be affected by the mod, and include or exclude specific items from outfit changes.
	
Changelog:
	9.1 NO LONGER UPGRADE FRIENDLY! The scripts are wildly different, and upgrading in situ, is definitely not supported! If you can manage to clean the old script out with ReSaver, more power to you. This is an advanced proceedure and incredibly risky.
	
	Documentation is two major overhauls out of date now... There haven't been changes in the effective operation, but speed is FAR FAR FAR improved, in every facet of the mod. Scanning 2278+Restricted and Diabled Items now takes 240-250 second instead of 600+. Main script is no longer responsible for assigning outfit items, it sets a variable on the NPC, the Maintenance script catches it, and handle the outfit change. Maintenance scripts on NPCs can run in parallel. Container script now resticts loot on dead bodies, based on the same Allowed Races/Disallowed Factions as outfit changes.

	8.2 Furniture checks are in a better place now. Container and Dead Body loot chances can be independently changed in MCM.

	8.1.0001 Just documentation updates. 
	
	8.1 So now it's using GetSlotMask to try to prevent outfit pieces from replacing each other. Seems to respect Devious Devices, Real Handcuffs, and SafeItems better.
	Added a hotkey to spawn a captive from Commonwealth Captives (if available) or a random female settler.

	There's a new section available for use, [OSRestrictedFurniture], and I've included INI files for some of the more popular restrictive furniture. I also threw in Cryopods, Memory Loungers, toilets, etc.

	8.0c A wild settings file appeared! This is the "Hard Save data file update, with Additional Optimizations" update. That's a mouthful. Outfits and Weapons are now saved to a file, and reloaded when NPCs come back into range. I highly recommend having Buffout 4 installed, as it uses a RAM buffer instead of going to disk for every INI check. The Hard Save has the additional feature of maintaining outfits across savegames. You can also manually edit loadouts. I made the unilateral decision to use a file, over an array tied to the script, for those reasons. I added a function at the bottom of the MCM to Clear OSNPCData. It will remove any OutfitShuffler special items from all NPCs in OSNPCData, and delete their outfits from the file.

	I removed a lot of repitition from the code by making a lot of the functions global, to call them from any script. I am passing properties, arrays, and formlists around, like joints at a Grateful Dead concert.

	I have not updated the documentation yet. I hate documentation. I spent years writing technical documentation. Would anyone like to update my documentation for me?

	7.7 Fixed AAF Doppelgangers. Fixed an annoying bug that repeated a message unnecessarily.
	7.6.1 Fixed a glitch in the updater code. It was adding the maintenance spell to ALL the NPCs, then relying on the maintenance to remove itself. The maintenance script was removing itself, but not before doing the maintenance.
	7.6 Removed Debug hotkey. Added variables and checks to handle updating NPC scripts when upgrading the mod.
	7.5 DD Compatibility was breaking things, and I had to fix it. Left a debug function in, that teleports NPCs to your position. Not recommended in firefights.
	7.4 Hammered out a little more speed in the outfit change routine.  Changed the scan routine to prioritize based on FOV and distance.7.3 Lots of cleaning, speed improvements, logging improvements (Disable if you don't need it. Seriously.) Much better Devious Devices/Real Handcuffs compatibility.

	7.2 Container management is much cleaner now. It's SUPPOSED to ignore the container used by Dave's In-Game ESP Explorer, now. I added rudimentary Devious Devices Support. I also added in a NoNudes option. It should be more aggressive at keeping some sort of clothing on the NPC's, unless they've been hit with the DontChange keyword. ** It is advised by the authors, and other users, that Devious Devices and NPCs don't mix well. I tried.

	7.1 Now adds random amounts of random items to containers when you're looting. You rummage around in there, and sometimes something turns up.

	7.0 BodyGen options now include a "BodyGen OneShot" option, that will only regenerate the NPCs once, then flag them to not change, even if their outfit does. Hotkey is available to change NPCs even if the other BodyGen options are disabled.
	[Races] and [FactionsToIgnore] in the OufitShuffler.ini, now accept regular hexadecimal values. 0x123456 <== Is the correct format to use.
	MCM Readme.txt is in Data\MCM\Config\OutfitShuffler\ in the 7z, and in the root of the repo at https://github.com/tzenrick/FO4OutfitShuffler/blob/main/MCM%20Readme.txt

	6.9 Nice. Huge Speed and Stability improvements.
	There was an accidental soft-dependency on AAF in previous versions. It would have caused extra outfit changes on some NPCs. Talos II Exosuits are now properly protected.

	6.8 Fixed the pesky issue that was removing clothing from everyone...I think.

	6.7 Outfit INI files now accept standard hexadecimal, so no more converting.

	6.6 Cleaned up most of the outfit 'flicker.' (When two items keep replacing each other.)

	6.5 Lots of code cleanup, much cleaner/more readable debugging. Optimization for speed.

	6.3 BodyGen and Scale can be randomized with outfit changes, with a hotkey, or just disabled.

	6.2 Some of the updates are pretty big...

	6.23 Added more Vtaw Outfits

	6.21 Just outfit sets. Don't bother unless you're adding Classy Chassis outfits to your collection.

	6.22 Changed directory structure to hopefully make it MO2 friendly.
Transform the outfits of the NPCs in Fallout 4 with OutfitShuffler! This mod lets you mix and match clothing and accessories to create endless fashion combinations. Customize the frequency, NPC selection, and item exclusions for outfit changes to make them fit your playstyle. And if you're lucky, you might even find some new outfit pieces as loot! Plus, OutfitShuffler supports other mods like Devious Devices for even more options. So get ready to revamp the wardrobe of the wasteland with OutfitShuffler!

Installing OutfitShuffler

There are a few different ways to install OutfitShuffler:

    Download the mod with a mod manager, such as Nexus Mod Manager or Vortex.

    Drag and drop the mod file into your mod manager.

    Manually install the mod by extracting the mod file into your Fallout 4 "Data" folder.

Note that if you already have a mod that includes the Lovers Lab Four Play F4SE plugin, you may see file conflicts. As long as your other mods are up-to-date, these conflicts should not cause any issues.

Upgrading OutfitShuffler

To upgrade OutfitShuffler to a newer version:

    Remove the previous version of the mod.

    Start the game and step through the warning about OutfitShuffler.esl not being present.

    Save the game and exit.

    Install the new version of the mod.

    Start the game and save the game again.

    Continue playing.

Operating OutfitShuffler

Once the mod is installed and activated, you can access the mod's settings through the Mod Configuration Menu (MCM) in the game.

Configuring OutfitShuffler

To configure OutfitShuffler, access the mod's settings through the Mod Configuration Menu (MCM) in the game. The mod's settings are organized into the following categories:

    Rescan: Rechecks the OutfitShuffler.ini file for updates and rescans all of the INI files in the [INIFiles] section.

    Change Items: Allows you to add 25 of each of the following types of items to the player's inventory:

    DontChange Item
    AlwaysChange Item
    DontBodyGen Item
    AlwaysBodyGen Item
    DontScale Item
    AlwaysScale Item

    General Settings: Allows you to enable or disable the mod, and enable or disable changing female and male NPCs. You can also allow or disallow container loot.

    Loot Options: Allows you to enable or disable finding outfit pieces as loot in containers and on bodies, as well as set a maximum number of random container items and allow or disallow random outfit pieces in.

    Shuffling Options: Allows you to enable OneShot, Keep Clothes On, enable random BodyGen, enable OneShot for BodyGen, and random BodyGen options.

    Advanced Settings: Allows you to customize the frequency of outfit changes, specify which NPCs should be affected by the mod, and include or exclude specific items from outfit changes.
	
Changelog:
	7.3 Lots of cleaning, speed improvements, logging improvements (Disable if you don't need it. Seriously.) Much better Devious Devices/Real Handcuffs compatibility.

	7.2 Container management is much cleaner now. It's SUPPOSED to ignore the container used by Dave's In-Game ESP Explorer, now. I added rudimentary Devious Devices Support. I also added in a NoNudes option. It should be more aggressive at keeping some sort of clothing on the NPC's, unless they've been hit with the DontChange keyword. ** It is advised by the authors, and other users, that Devious Devices and NPCs don't mix well. I tried.

	7.1 Now adds random amounts of random items to containers when you're looting. You rummage around in there, and sometimes something turns up.

	7.0 BodyGen options now include a "BodyGen OneShot" option, that will only regenerate the NPCs once, then flag them to not change, even if their outfit does. Hotkey is available to change NPCs even if the other BodyGen options are disabled.
	[Races] and [FactionsToIgnore] in the OufitShuffler.ini, now accept regular hexadecimal values. 0x123456 <== Is the correct format to use.
	MCM Readme.txt is in Data\MCM\Config\OutfitShuffler\ in the 7z, and in the root of the repo at https://github.com/tzenrick/FO4OutfitShuffler/blob/main/MCM%20Readme.txt

	6.9 Nice. Huge Speed and Stability improvements.
	There was an accidental soft-dependency on AAF in previous versions. It would have caused extra outfit changes on some NPCs. Talos II Exosuits are now properly protected.

	6.8 Fixed the pesky issue that was removing clothing from everyone...I think.

	6.7 Outfit INI files now accept standard hexadecimal, so no more converting.

	6.6 Cleaned up most of the outfit 'flicker.' (When two items keep replacing each other.)

	6.5 Lots of code cleanup, much cleaner/more readable debugging. Optimization for speed.

	6.3 BodyGen and Scale can be randomized with outfit changes, with a hotkey, or just disabled.

	6.2 Some of the updates are pretty big...

	6.23 Added more Vtaw Outfits

	6.21 Just outfit sets. Don't bother unless you're adding Classy Chassis outfits to your collection.

	6.22 Changed directory structure to hopefully make it MO2 friendly.