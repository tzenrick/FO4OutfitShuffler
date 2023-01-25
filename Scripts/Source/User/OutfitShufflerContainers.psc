Scriptname OutfitShufflerContainers extends ActiveMagicEffect
{Attempts to manage random container loot, and dead body loot.}

import OutfitShuffler
import Game
import MCM
import Utility

GlobalVariable Property OSSuspend Auto
Formlist Property OSAllItems Auto
Actor Property PlayerRef Auto Const
ObjectReference MyOnlyContainer
FormList Property OSTempContainer Auto
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If OSSuspend.GetValueInt()==0
		OSSuspend.SetValueInt(1)
		RemoveInventoryEventFilter(None)
		Bool BadContainer
		If IsPluginInstalled("ESPExplorerFO4.esp")
			if akSourceContainer==GetFormFromFile(0x1742,"ESPExplorerFO4.esp") as ObjectReference
				BadContainer=True
			endif
		endif
		if akSourceContainer
			If akSourceContainer.IsOwnedBy(PlayerRef)
				BadContainer=True
			endif
		endif
		if (akSourceContainer && !BadContainer && OSTempContainer.GetSize()==0) && (!(akSourceContainer == akSourceContainer as Actor)||((akSourceContainer == akSourceContainer as Actor)&&(akSourceContainer as Actor).IsDead()))
			MyOnlyContainer=akSourceContainer
			If OSAllItems.GetSize()>1
				int i
				While i<RandomInt(1,GetModSettingInt("OutfitShuffler", "iContainerItems:General") as Int)
					Form TempItem=OSAllItems.GetAt(RandomInt(1,OSAllItems.GetSize()))
					OSTempContainer.AddForm(TempItem)
					MyOnlyContainer.AddItem(TempItem)
					i+=1
				endwhile
			endif
			RegisterForDistanceGreaterThanEvent(PlayerRef, MyOnlyContainer, 1000.0)
		else
			Wait(RandomFloat(0.5,2.0))
		endif
		AddInventoryEventFilter(None)
		OSSuspend.SetValueInt(0)
	endif
endEvent
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
Event OnEffectStart(Actor akTarget, Actor akCaster)
	AddInventoryEventFilter(None)
EndEvent