program PlotPanelDemo;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here },plotpaneldemounit;
  

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.





