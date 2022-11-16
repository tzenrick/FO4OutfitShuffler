Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
int tid=867
Actor SelfAffect
string OSLogName="OutfitShuffler"

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if ( akTarget == none || ! akTarget.WaitFor3DLoad() )
        return
    endif
	SelfAffect=akTarget
	starttimer(3.0, tid)
endevent

event OnTimer(int aiTimerID)
	if aiTimerID==tid
		Debug.OpenUserLog(OSLogName)
		EveryDayImShufflin()
	endif
	float ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	starttimer(ShortTime, tid)
endevent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
endevent

Function EveryDayImShufflin()
	debug.traceuser(OSLogName,"[Maintainer]"+SelfAffect+SelfAffect.GetLeveledActorBase().GetName()+" Checking for Maintenance")
	if SelfAffect.Is3DLoaded() && !SelfAffect.IsDead() && !SelfAffect.IsDeleted() && !SelfAffect.IsDisabled() && !PowerArmorCheck(SelfAffect) 
		Keyword AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If AAFBusyKeyword && !SelfAffect.HasKeyword(AAFBusyKeyword)
			int i=0
			Form[] InvItems = SelfAffect.GetInventoryItems()
			Int ItemCounter = 0
			While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)
					if 0<akitem.getformid() && akitem.getformid()<0x07000000
						if !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
							selfaffect.removeitem(akitem,-1)
						endif
					else
						if !SelfAffect.IsEquipped(akItem)
							ItemCounter += 1
							debug.TraceUser(OSLogName, "[Maintainer]"+SelfAffect+" equipped "+akItem+akItem.GetName())
							SelfAffect.equipitem(akItem)
						EndIf
					endif
				endif
			i += 1
			EndWhile
			Debug.TraceUser(OSLogName,"[Maintainer]"+SelfAffect+SelfAffect.GetLeveledActorBase().GetName()+" "+ItemCounter+"/"+InvItems.Length+" items were Armor that needed to be equipped")
		else
			debug.traceuser(OSLogName,"[Maintainer]"+SelfAffect+SelfAffect.GetLeveledActorBase().GetName()+" is AAFBusy")
		endif
	endif
endfunction

bool Function PowerArmorCheck(Actor NPC)
	If Game.GetFormFromFile(0xf9c,"PowerArmorLite.esp")
		If NPC.IsEquipped(Game.GetFormFromFile(0xf9c,"PowerArmorLite.esp"))||NPC.IsEquipped(Game.GetFormFromFile(0x18a7,"PowerArmorLite.esp"))||NPC.IsEquipped(Game.GetFormFromFile(0x1806,"PowerArmorLite.esp"))
			debug.traceuser(OSLogName,"[Maintainer]"+SelfAffect+SelfAffect.GetLeveledActorBase().GetName()+" is in Talos II armor")
			return True
		endif
	endif
	If NPC.IsInPowerArmor()
		debug.traceuser(OSLogName,"[Maintainer]"+SelfAffect+SelfAffect.GetLeveledActorBase().GetName()+" is in Power Armor")
		return True
	endif
	return false
endfunction