{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit amw_ide_tools;

interface

uses
  amw_ide_menu_items, lazandroidtoolsexpert, uformsettingspaths, 
  AndroidXMLResString, ufrmEditor, ufrmCompCreate, uregistercompform, 
  ApkBuild, uFormStartEmulator, AndroidProjOptions, uFormBuildFPCCross, 
  uFormGetFPCSource, uimportjavastuff, uimportjavastuffchecked, uimportcstuff, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('amw_ide_menu_items', @amw_ide_menu_items.Register);
end;

initialization
  RegisterPackage('amw_ide_tools', @Register);
end.
