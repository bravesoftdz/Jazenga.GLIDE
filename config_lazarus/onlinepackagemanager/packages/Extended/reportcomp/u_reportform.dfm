inherited ReportForm: TReportForm
  Left = 547
  Top = 240
  AutoSize = True
  Caption = 'ReportForm'
  object RLReport: TExtReport[0]
    Left = 0
    Height = 1123
    Top = 24
    Width = 794
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    RealBounds.Left = 0
    RealBounds.Top = 0
    RealBounds.Width = 0
    RealBounds.Height = 0
  end
  object Panel1: TPanel[1]
    Left = 0
    Height = 26
    Top = 0
    Width = 320
    Align = alTop
    TabOrder = 1
  end
  object RLRichFilter: TRLRichFilter[2]
    DisplayName = 'Format RichText'
    left = 103
    top = 80
  end
  object RLPDFFilter: TRLPDFFilter[3]
    DocumentInfo.Creator = 'FortesReport (Open Source) v3.24(B14)  \251 Copyright � 1999-2008 Fortes Inform�tica'
    DocumentInfo.ModDate = 0
    ViewerOptions = []
    FontEncoding = feNoEncoding
    DisplayName = 'Document PDF'
    left = 103
    top = 157
  end
  object RLHTMLFilter: TRLHTMLFilter[4]
    DocumentStyle = dsCSS2
    DisplayName = 'Page Web'
    left = 227
    top = 79
  end
  object RLDraftFilter: TRLDraftFilter[5]
    FontSizeReal = False
    left = 216
    top = 160
  end
end
