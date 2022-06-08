{
	Purpose: Export AMMO, with BodySlots
	Game: Fallout 4
	Author: tzenrick based on a script by fireundubh <fireundubh@gmail.com>
	Version: 0.1
	HOW TO USE:


	1. Tell fireundubh how much you love and adore him for making you this script. Kneeling is optional but encouraged.
}

unit UserScript;

var
	slMaterials, slMaterialsAll, slKeywords, slKeywordsAll, slFlags, slFlagsAll, slRows: TStringList;
    sourcename: string;
	i, x, z: integer;

function CountOccurences( const SubText: string; const Text: string): Integer;
begin
	Result := Pos(SubText, Text);
		if Result > 0 then
			Result := (Length(Text) - Length(StringReplace(Text, SubText, '', [rfReplaceAll]))) div  Length(subtext);
end;

function Initialize: integer;
begin

	Result := 0;

	slRows := TStringList.Create;
	slRows.Delimiter := '=';
	slRows.StrictDelimiter := True;

	x := 0;
	z := 0;

end;

function Process(e: IInterface): integer;
var
    list, listitem, item: IInterface;
    rec, formid, edid, bodyslots, FormINT32: string;
    bodyslotsElement: IInterface;
    i, tempint: integer;
    row: string;
    armo: boolean;
    bodySlotList: TStringList;
begin
 
    Result := 0;
 
    rec := Signature(e);
    sourcename := GetFileName(e);
    // Check record signature
    if (rec <> 'ARMO') then begin
        {just skip the record}
	exit;
    end;
 
    bodySlotList := TStringList.Create;
    // Common elements
	formid    := IntToHex(FixedFormID(e)-16777216,6);
	tempint := FixedFormID(e)-16777216;
	FormInt32 := IntToStr(tempint);
	edid    := GetEditValue(ElementBySignature(e, 'EDID'));
    bodyslotsElement := ElementByPath(e, 'BOD2\First Person Flags');
    for i := 0 to Pred(ElementCount(bodyslotsElement)) do begin
        bodyslots := Name(ElementByIndex(bodyslotsElement, i));
        bodyslots := Copy(bodyslots, 1, Pos(bodyslots, ' -') +2);
        bodySlotList.Add(bodyslots);
    end;
	bodyslots := bodySlotList.CommaText;
    row := sourcename + '=' + FormInt32;
	row := Trim(row);
    slRows.Add(row);
	row := ';' + formid + ';' + edid  + ';'  + EditorID(e) + ';' +  bodyslots;
	row := Trim(row);
    slRows.Add(row);
	row := '';
    slRows.Add(row);
    bodySlotList.Free;
end;

function Finalize: integer;
var
	s: string;
	dlgSave: TSaveDialog;
	slImportRows, slImportMaterials, slImportKeywords, slImportFlags: IInterface;
begin

	// Output main rows
	if (slRows.Count > 0) then begin
	
		// ask for file to export to
		dlgSave := TSaveDialog.Create(nil);
		dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
		dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
		dlgSave.InitialDir := ProgramPath;
		dlgSave.FileName := sourcename + '.ini';
		if dlgSave.Execute then
			slRows.SaveToFile(dlgSave.FileName);
		dlgSave.Free;

	end;

	// Exit
	Result := 1;

end;

end.
