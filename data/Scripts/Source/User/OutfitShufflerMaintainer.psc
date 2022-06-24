Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect

int tid=867
Actor SelfAffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if ( akTarget == none || ! akTarget.WaitFor3DLoad() )
        return
    endif
	SelfAffect=akTarget
	starttimer(3.0, tid)
endevent

event OnTimer(int aiTimerID)
	if aiTimerID==tid
		EveryDayImShufflin()
	endif
	starttimer(3.0, tid)
endevent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
endevent

Function EveryDayImShufflin()
	if !SelfAffect.IsDead() && !SelfAffect.IsDeleted() && !SelfAffect.IsDisabled() && !SelfAffect.IsInPowerArmor() 
		Keyword AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If AAFBusyKeyword && !SelfAffect.HasKeyword(AAFBusyKeyword)
			int i=0
			Form[] InvItems = SelfAffect.GetInventoryItems()
			While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)
					if !SelfAffect.IsEquipped(akItem)
						SelfAffect.equipitem(akItem)
					EndIf
				endif
			i += 1
			EndWhile
		endif
	endif
endfunction