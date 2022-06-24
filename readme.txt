20220624: 4.8 Created a second script to handle keeping outfits on NPCs. Main script runs much faster. NPCs will receive their script at their next outfit change.

20220623: 4.6 Cleaned up the main scripts a bit. Updated xEdit script to handle armor or weapons, and to export entire record on one line. (now they can be imported with spreadsheet software, and possibly more easily sorted.)

20220611:  4.4 Added a couple of sanity checks, tweaked a couple of things so that any race from any mod should be able to be added, as long as they can wear human clothes, and any faction from any mod can be excluded.

4.3 Factions can be ignored by specifying them in the OutfitShuffler.ini file.

https://i.ibb.co/y5NDBP6/image.png
(This is how everything in the INI files is specified. File.esm=DecimalConversionofFormID)

4.2 Moved Race selection from esl to OutfitShuffler.ini. This is a "If you don't need it, don't bother" type feature update.

4.1 has a couple of significant bugfixes over 4.0.
It's kinda(in my opinion, anyway) worth it.


20220611: Stopped doing most of the static string comparisons for a lot of things, built an array, now I can iterate the array for the string comparisions. Got code from 30K to 23K, so that's not insignificant.

20220609: I'm updating code faster than the readme. Trying to parallelize, and still getting serial execution.

20220607: It's 3.0 now... Fully dynamic with config INIs and ingame outfit item chances.

20220606: 3.0 Is a work in progress at this point.

20220526: a little later: Jonathan Ostrus banged in some more optimization.

20220526: much much later: I got a handle on the hitching issue from using Resurrect() to refresh NPCs. The handle was, don't use Resurrect(). I got a a ton of help with some code optimization from Jonathan Ostrus over on the xEdit Discord.

20220526: Removed debugging output. Now with MCM support. Huge code update. 450-ish lines, down to 142.

STILL LOOKING FOR A WAY TO FORCE OUTFIT UPDATES WITHOUT CALLING resurrect()

INITIAL COMMIT: I've been exporting outfit sets, reformatting the data, rearranging the data based on the nested leveled lists, importing the rearranged data as leveled lists of outfit items... It's a process... At this point, I could probably just rename the Leveled Lists as Body Slots, and almost be there, though...

If you want to modify the script so that it's slot based, I'll welcome the addition. I've honestly been contemplating it.

I just dropped the project into GitHub https://github.com/tzenrick/FO4OutfitShuffler

This project is my first foray into sharing my own original code for others to review and modify. I have no idea what I'm doing. It's basically undocumented. I tried to stay descriptive and distinct with variable names, for my own sanity, before I decided to share, so I guess, "you're welcome?"

My script is a disaster. I have a backwards 'Bool Property' being imported, that's happening somewhere, but working as intended, I think....

My biggest problem with the script right now, is that after every outfit change, I'm running 'setoutfit, resurrect' on the actor. This causes a noticeable stutter in-game. I tried using 'setoutfit, disable, wait, enable', and it changes the outfit for their record, and updates them, unless they have 'an enable state parent.' If the actor you're trying to do that to, has 'an enable state parent,' you can't do that, and it spews papyrus errors all over the log. They still change their outfit after they unload and reload, but if they're someone that's about to die, they'll never get reloaded, and you won't see their fancy new outfit. They have to unload and reload, before you see the outfit change. 

I'm bad at this. I bashed together code to get to 'pretty close to intended function, with a performance hit.' Then I tried to optimize it some. There have been many failures, and reversions.
