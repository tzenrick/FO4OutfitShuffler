Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
Int LogLevel
bool NoisyConsole
int tid=867
Actor NPC
string OSLogName="OutfitShuffler"
float MaxOffset=0.0035
float SavedTime
float ShortTime
Float ShortMult=5.0

Bool CheckAAFSafe
Keyword AAFBusyKeyword

FormList Property XXSafeItems auto
FormList Property XYSafeItems auto
Outfit Property ForceChangeOutfit auto
Keyword Property DontChange auto
Keyword Property OSAlwaysChange auto
Keyword Property OSWait Auto

GlobalVariable Property OSSuspend Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	Utility.Wait(10.0)
	if ( akTarget == none || !akTarget.WaitFor3DLoad() )
        return
    endif
	NPC=akTarget
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	starttimer(ShortTime*ShortMult, tid)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
event OnTimer(int aiTimerID)
	if aiTimerID==tid
		Debug.OpenUserLog(OSLogName)
		LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as Int
		NoisyConsole = MCM.GetModSettingBool("OutfitShuffler", "bNoisyConsole:General") as Bool
		If !NPC.HasKeyword(OSWait) && OSSuspend.GetValueInt() == 0
			EveryDayImShufflin()
		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in OSWait or OSSuspend="+OSSuspend.GetValueInt())
			Utility.Wait(15.00)
		endif
	endif
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	starttimer(ShortTime*ShortMult, tid)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectFinish (Actor akTarget, Actor akCaster)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function EveryDayImShufflin()
	canceltimer(tid)
	DontChange = Game.GetFormFromFile(0x81b,"OutfitShuffler.esl") as Keyword
	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck()
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance")
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If CheckAAFSafe(); So I'm working on 6.9, and realizing that changes back in 5.x somewhere added a pseudo-dependency for AAF at this script check. Added CheckAAFSafe function
			int i=0
			Form[] InvItems = NPC.GetInventoryItems()
			Int ItemCounter = 0
			Int ArmorItems = 0
			While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)
					if 0<akitem.getformid() && akitem.getformid()<0x07000000
						if !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool) && !NPC.HasKeyword(DontChange); So in 6.81, we're going to stop taking items away from NPCs with the DontChange keyword. I'm a derp for not realizing this was a problem in 6.7
							NPC.removeitem(akitem,-1)
						endif
					else
						if !NPC.IsEquipped(akItem)
							ItemCounter += 1
							dLog(1,NPC+" equipped "+akItem+akItem.GetName())
							NPC.equipitem(akItem)
						EndIf
					endif
				ArmorItems += 1
				endif
			i += 1
			EndWhile

			SavedTime=Utility.GetCurrentGameTime()
			
			If ItemCounter > 0
				dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" "+ItemCounter+"/"+InvItems.Length+" items were Armor that needed to be equipped")
			endif
			
;cleanup, Step 1: Make Sure as many SafeItems get put back on as possible

			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Waiting at SafeItems check... "+ShortTime*ShortMult+" seconds.")
			Utility.Wait(ShortTime)
			i=0

			While (i < InvItems.Length) && !NPC.HasKeyword(DontChange)
				Form akItem = InvItems[i]
				If akItem as ObjectReference != None
					If XYSafeitems.HasForm(akItem as ObjectReference)
						dLog(4,akitem+" is in XYSafeItems")
						NPC.EquipItem(akItem)
						ArmorItems += 1
					endif
					If XXSafeitems.HasForm(akItem as ObjectReference)
						dLog(4,akitem+" is in XXSafeItems")
						NPC.EquipItem(akItem)
						ArmorItems += 1
					endif
				endif
			i += 1
			EndWhile

;cleanup, Step 2:Now remove whatever is left

			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Waiting to cleanup... "+ShortTime*ShortMult+" seconds.")
			float ShortTimeMult = ShortTime*ShortMult
			Utility.Wait(ShortTimeMult)

			if Utility.GetCurrentGameTime()>SavedTime+MaxOffSet || Utility.GetCurrentGameTime()<SavedTime
				dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" EXCESSIVE TIME OFFSET CurrentGameTime="+Utility.GetCurrentGameTime()+" SavedTime="+SavedTime)
			else
			i=0
				While (i < InvItems.Length) && !NPC.HasKeyword(DontChange)
					Form akItem = InvItems[i]
					If (akItem as Armor)
						if !NPC.IsEquipped(akItem)
							dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed conflict item "+akItem+akItem.GetName())
							NPC.RemoveItem(akItem, -1)
						endif
					endif
				i += 1
				EndWhile
			endif		

			if ArmorItems < 1;assume we're naked, and force over to OutfitShuffler.SetSettlerOutfit
				dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" not enough armor in inventory, resetting outfits.")
				NPC.SetOutfit(ForceChangeOutfit)
				NPC.SetOutfit(ForceChangeOutfit,true)
				return
			endif

		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is AAFBusy")
		endif
	endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool Function PowerArmorCheck()
	if NPC.IsInPowerArmor()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Power Armor")
		return True
	endif
	if Game.IsPluginInstalled("PowerArmorLite.esp")
		if NPC.IsEquipped(Game.GetFormFromFile(0xf9c,"PowerArmorLite.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x1806,"PowerArmorLite.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x18a7,"PowerArmorLite.esp"))
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Talos II Armor")
			return True
		endif
	endif
	if Game.IsPluginInstalled("PowerArmorLiteReplacer.esp")
		if NPC.IsEquipped(Game.GetFormFromFile(0x806,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x807,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x808,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x80a,"PowerArmorLiteReplacer.esp"))
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Talos II Armor")
			return True
		endif
	endif
	return false
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bool Function CheckAAFSafe()
	if AAFBusyKeyword && !NPC.HasKeyword(AAFBusyKeyword)
		Return True
	endif
	if AAFBusyKeyword == None
		Return True
	endif
	Return False
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.
;File Output
	If LogLevel == 0 && dLogLevel == 1
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
	endif
;File and Notification
	If LogLevel == 0 && dLogLevel == 2
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
		debug.Notification("[OSm] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 0 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
	endif
;Higher Priority File and Notification
	If LogLevel == 0 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
		debug.Notification("[OSm] "+LogMe)
	endif
;File Output
	If LogLevel == 1 && dLogLevel == 1
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe)
	endif
;File and Notification
	If LogLevel == 1 && dLogLevel == 2
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe)
		debug.Notification("[OSm] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 1 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
	endif
;Higher Priority File and Notification
	If LogLevel == 1 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
		debug.Notification("[OSm] "+LogMe)
	endif
;Noisy Console
	If NoisyConsole
		LL_FourPlay.PrintConsole("[OSm] "+LogMe)
	endif
endFunction