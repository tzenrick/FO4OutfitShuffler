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
	if SelfAffect.Is3DLoaded() && !SelfAffect.IsDead() && !SelfAffect.IsDeleted() && !SelfAffect.IsDisabled() && !SelfAffect.IsInPowerArmor() 
		Keyword AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If AAFBusyKeyword && !SelfAffect.HasKeyword(AAFBusyKeyword)
			int i=0
			Form[] InvItems = SelfAffect.GetInventoryItems()
			Int ItemCounter = 0
			While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)
;				Debug.Trace("[OutfitShufflerMaintainer] ************************************************ "+(SelfAffect as Actor)+ " Checking item "+ akItem.GetName() +"="+akitem.getformid())
					if 0<akitem.getformid() && akitem.getformid()<0x07000000
						if !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
							selfaffect.removeitem(akitem,-1)
;							Debug.Trace("[OutfitShufflerMaintainer] ******** "+(SelfAffect as Actor)+ " Removed Base/DLC item "+ akItem +" from inventory")
						endif
					else
						if !SelfAffect.IsEquipped(akItem)
							ItemCounter += 1
							SelfAffect.equipitem(akItem)
						EndIf
					endif
				endif
			i += 1
			EndWhile
;			Debug.Trace("[OutfitShufflerMaintainer]"+(SelfAffect as Actor)+ " !Is(Dead|Disabled|Deleted|InPowerArmor) AAFKeywordState="+ AAFBusyKeyword +" NPCAAFKeywordState="+ SelfAffect.HasKeyword(AAFBusyKeyword) +"|||"+ ItemCounter+"/"+InvItems.Length+" items were Armor that needed to be equiped")
		endif
	endif
endfunction