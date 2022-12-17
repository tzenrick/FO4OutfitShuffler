Scriptname OutfitShufflerContainers extends ActiveMagicEffect
{Attempts to manage random container loot, and dead body loot.}

GlobalVariable Property OSSuspend Auto
Formlist Property OSAllItems Auto
Actor Property PlayerRef Auto Const
ObjectReference MyOnlyContainer
FormList Property OSTempContainer Auto
String OSLogName="OutfitShuffler"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If OSSuspend.GetValueInt()==0
		OSSuspend.SetValueInt(1)
		dlog(1,"Setting OSSuspend=1")
		RemoveInventoryEventFilter(None)
		Bool BadContainer
		If Game.IsPluginInstalled("ESPExplorerFO4.esp")
			if akSourceContainer==Game.GetFormFromFile(0x1742,"ESPExplorerFO4.esp") as ObjectReference
				BadContainer=True
			endif
		endif
		If akSourceContainer.IsOwnedBy(PlayerRef)
			BadContainer=True
		endif
		if (akSourceContainer && !BadContainer && OSTempContainer.GetSize()==0) && (!(akSourceContainer == akSourceContainer as Actor)||((akSourceContainer == akSourceContainer as Actor)&&(akSourceContainer as Actor).IsDead()))
			MyOnlyContainer=akSourceContainer
			If OSAllItems.GetSize()>1
				int i
				While i<Utility.RandomInt(1,MCM.GetModSettingInt("OutfitShuffler", "iContainerItems:General") as Int)
					Form TempItem=OSAllItems.GetAt(Utility.RandomInt(1,OSAllItems.GetSize()))
					OSTempContainer.AddForm(TempItem)
					MyOnlyContainer.AddItem(TempItem)
					i+=1
				endwhile
			endif
			RegisterForDistanceGreaterThanEvent(PlayerRef, MyOnlyContainer, 1000.0)
		else
			Utility.Wait(Utility.RandomFloat(0.5,2.0))
		endif
		AddInventoryEventFilter(None)
		OSSuspend.SetValueInt(0)
		dlog(1,"Setting OSSuspend=0")
	endif
endEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnDistanceGreaterThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
	int i=0
	While i<OSTempContainer.GetSize()
		Form TempItem=OSTempContainer.GetAt(i)
		MyOnlyContainer.RemoveItem(TempItem, 1)
		i+=1
	endwhile
	OSTempContainer.Revert()
	UnRegisterForDistanceEvents(PlayerRef, MyOnlyContainer)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	AddInventoryEventFilter(None)
EndEvent
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.
	Int LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int

	If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
		debug.TraceUser(OSLogName, "[.Container]"+LogMe,1)
	endif

	If dLogLevel > 1
		debug.Notification("[OSc] "+LogMe)
	endif

	If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 2 || dLogLevel == 2
		LL_FourPlay.PrintConsole("[OSc] "+LogMe)
	endif
endFunction