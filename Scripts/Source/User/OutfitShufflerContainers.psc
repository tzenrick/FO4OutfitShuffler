Scriptname OutfitShufflerContainers extends ActiveMagicEffect

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
	Bool ESPContainer
	If Game.IsPluginInstalled("ESPExplorerFO4.esp")
		if akSourceContainer==Game.GetFormFromFile(0x1742,"ESPExplorerFO4.esp") as ObjectReference
			ESPContainer=True
		endif
	endif
	if akSourceContainer && OSSuspend.GetValueInt() == 0 && !ESPContainer && OSTempContainer.GetSize()==0
		String dOut
		if !(akSourceContainer == akSourceContainer as Actor)||((akSourceContainer == akSourceContainer as Actor)&&(akSourceContainer as Actor).IsDead())
			MyOnlyContainer=akSourceContainer
			dout="OSContainers Adding to "+akSourceContainer+"("+(akSourceContainer as Actor)+")\n"
			If OSAllItems.GetSize()>1
				int i
				While i<Utility.RandomInt(1,MCM.GetModSettingInt("OutfitShuffler", "iContainerItems:General") as Int)
					Form TempItem=OSAllItems.GetAt(Utility.RandomInt(1,OSAllItems.GetSize()))
					OSTempContainer.AddForm(TempItem)
					dout+=TempItem+"\n"
					MyOnlyContainer.AddItem(TempItem)
					i+=1
				endwhile
				dout+="\n"+i+" items added to "+MyOnlyContainer
			endif
			dLog(1,dout)
			RegisterForDistanceGreaterThanEvent(PlayerRef, MyOnlyContainer, 1000.0)
			AddInventoryEventFilter(None)
		else
			dout="OSContainers NOT Adding to "+akSourceContainer+"("+(akSourceContainer as Actor)+")\n"
			AddInventoryEventFilter(None)
		endif
		dout="OSTempContainer Formlist:\n"
		int i=0
		While i<OSTempContainer.GetSize()
			Form TempItem=OSTempContainer.GetAt(i)
			dout+=TempItem+"\n"
			i+=1
		endwhile
		dout+="\n"+i+" items in "+OSTempContainer
		dLog(1,dout)
	endif
endEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnDistanceGreaterThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
	String dout="OSContainers Removing\n"
	int i=0
	While i<OSTempContainer.GetSize()
		Form TempItem=OSTempContainer.GetAt(i)
		dout+=TempItem+"\n"
		MyOnlyContainer.RemoveItem(TempItem, 1)
		i+=1
	endwhile
	dout+="\n"+i+" items removed from "+MyOnlyContainer
	dLog(1,dout)
	OSTempContainer.Revert()
	UnRegisterForDistanceEvents(PlayerRef, MyOnlyContainer)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	AddInventoryEventFilter(None)
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.
	bool NoisyConsole = MCM.GetModSettingBool("OutfitShuffler", "bNoisyConsole:General") as Bool
	int LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int
;File Output
	If LogLevel == 0 && dLogLevel == 1
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
	endif
;File and Notification
	If LogLevel == 0 && dLogLevel == 2
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
		debug.Notification("[OSc] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 0 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[.Container]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
	endif
;Higher Priority File and Notification
	If LogLevel == 0 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[.Container]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
		debug.Notification("[OSc] "+LogMe)
	endif
;File Output
	If LogLevel == 1 && dLogLevel == 1
		debug.TraceUser(OSLogName, "[.Container]"+LogMe)
	endif
;File and Notification
	If LogLevel == 1 && dLogLevel == 2
		debug.TraceUser(OSLogName, "[.Container]"+LogMe)
		debug.Notification("[OSc] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 1 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[.Container]"+LogMe,1)
	endif
;Higher Priority File and Notification
	If LogLevel == 1 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[.Container]"+LogMe,1)
		debug.Notification("[OSc] "+LogMe)
	endif
;Noisy Console
	If NoisyConsole
		LL_FourPlay.PrintConsole("[OSc] "+LogMe)
	endif
endFunction