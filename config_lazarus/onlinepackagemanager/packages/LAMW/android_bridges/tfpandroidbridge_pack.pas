{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit tfpandroidbridge_pack;

{$warn 5023 off : no warning about unused units}
interface

uses
  regandroidbridge, And_jni, And_jni_Bridge, And_lib_Unzip, And_lib_Image, 
  Laz_And_Controls, Laz_And_GLESv2_Canvas_h, Laz_And_GLESv1_Canvas_h, 
  Laz_And_GLESv1_Canvas, Laz_And_GLESv2_Canvas, And_log, And_bitmap_h, 
  And_log_h, register_extras, Laz_And_Controls_Events, AndroidWidget, 
  Laz_And_jni_Controls, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('regandroidbridge', @regandroidbridge.Register);
  RegisterUnit('register_extras', @register_extras.Register);
end;

initialization
  RegisterPackage('tfpandroidbridge_pack', @Register);
end.
