﻿unit fonctions_db;

interface

{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

{$I ..\DLCompilers.inc}
{$I ..\extends.inc}
uses SysUtils,
  {$IFDEF DELPHI_9_UP}
     WideStrings,
  {$ENDIF}
     DB,
  {$IFDEF REMOTE}
     BufDataset,
  {$ENDIF}
  {$IFDEF CSV}
    SdfData,
  {$ENDIF}
{$IFDEF VERSIONS}
   fonctions_version,
{$ENDIF}
   fonctions_string,
   fonctions_proprietes,
   fonctions_variant,
   Classes ;


type TSpecialProcDataset = procedure ( const ADataset : TDataset );
     TSpecialFuncDataset = function ( const ADataset : TDataset ):Boolean;
     TSpecialFuncDatasetException = function ( const AException : Exception; const ADataset : TDataset ):Boolean;
     TSpecialFuncSort = function  ( const ADataset : TDataset; const AFieldName : String ; const ADesc : Boolean ) : Boolean;
     TEDataSetErrorEvent = procedure(DataSet: TDataSet; E: EDatabaseError;
       var DataAction: TDataAction);
     IDatalinkOwner = interface
         ['{876E98E5-9E2E-4FAF-AF1B-ECE5DB3FA5A3}']
         procedure EditingChanged;
         procedure DataSetChanged;
         procedure ActiveChanged;
       End;
     { TExtNavDataLink }

       { TDataLinkOwnered }

       TDataLinkOwnered = class(TDataLink)
       private
         FOwner: IDatalinkOwner;
       protected
         procedure EditingChanged; override;
         procedure DataSetChanged; override;
         procedure ActiveChanged; override;
       public
         constructor Create(AOwner: IDatalinkOwner);
       end;

const
  ge_SpecialRefreshDataset : TSpecialProcDataset = nil;
  ge_SpecialSort : TSpecialFuncSort = nil;
  CST_EXTENSION_SQL_FILE = '.sql';
  CST_EXTENSION_FIREBIRD = '.fdb';
  CST_SQL_SELECT = 'SELECT ';
  CST_SQL_DISTINCT = ' DISTINCT ';
  CST_SQL_DELETE = 'DELETE ';
  CST_SQL_INSERT = 'INSERT ';
  CST_SQL_UPDATE = 'UPDATE ';
  CST_SQL_NULL   = ' NULL';
  CST_SQL_IS     = ' IS';
  CST_SQL_ALL    = '*';
  CST_SQL_FROM   = ' FROM ';
  CST_SQL_WHERE = ' WHERE ';
  CST_SQL_ORDER_BY = ' ORDER_BY ';
  CST_SQL_ASC  = ' ASC'  ;
  CST_SQL_AND  = ' AND ';
  CST_SQL_OR   = ' OR ';
  CST_SQL_DESC = ' DESC' ;
  CST_FIELD_DECLARE_SEPARATOR = '.';
  CST_TABLE_SEPARATOR = ',';
  CST_SQL_ORDER_INTERLEAVING = 1 ;
  CST_DELPHI_FIELD_STRING = [ftString, ftFmtMemo, ftMemo, ftFixedChar, ftWideString];
  {$IFDEF VERSIONS}
  gVer_fonctions_db : T_Version =  ( Component : 'Gestion des données' ; FileUnit : 'fonctions_db' ;
                        	     Owner : 'Matthieu Giroux' ;
                        	     Comment : 'Fonctions gestion des données partagées.' ;
                        	     BugsStory : 'Version 1.2.2.0 : Post If Edited.' + #13#10 +
                        			 'Version 1.2.1.0 : Add DB functions from fonctions_string.' + #13#10 +
                        			 'Version 1.2.0.1 : Integrating Remote and CSV Dataset.' + #13#10 +
                        			 'Version 1.2.0.0 : Fonctions sur les composants de données dans fonctions_dbcomponents.' + #13#10 +
                        			 'Version 1.1.0.1 : Changement de nom de procédures non utilisées, bug mode synchrone lent.' + #13#10 +
                        			 'Version 1.1.0.0 : Mode asynchrone.' + #13#10 +
                        			 'Version 1.0.8.0 : Fonction fb_RefreshDatasetIfEmpty.' + #13#10 +
                        			 'Version 1.0.7.0 : Toutes les fonctions de déplacement.' + #13#10 +
                        			 'Version 1.0.6.0 : Procédure p_InitNavigateurBoutonsDeplacement.' + #13#10 +
                        			 'Version 1.0.5.0 : Fonction fb_MAJTableNumOrdre.' + #13#10 +
                        			 'Version 1.0.4.0 : Fonction fb_RefreshADODataset correcte et fonction fb_RefreshADORecord.' + #13#10 +
                        			 'Version 1.0.3.0 : Fonction fb_DatasetFilterLikeRecord pour évènement OnFilterRecord.' + #13#10 +
                        			 'Version 1.0.2.0 : Fonction fb_RefreshADODataset.' + #13#10 +
                        			 'Version 1.0.1.1 : Bug texte de recherche à rien.' + #13#10 +
                        			 'Version 1.0.1.0 : Deuxième fonction fb_Locate.' + #13#10 +
                        			 'Version 1.0.0.0 : La fonction fb_Locate a des limites sur plusieurs champs recherchés.';
                        	     UnitType : 1 ;
                        	     Major : 1 ; Minor : 2 ; Release : 2 ; Build : 0 );
  {$ENDIF}

procedure p_DatasourcePostIfEdited ( const Datasource : TDatasource );
procedure p_DatasetPostIfEdited ( const Dataset : TDataset );
procedure p_DatasetEditIfNotEdited ( const Dataset : TDataset );
procedure p_GereExceptionEvent (const DataSet: TDataSet; const E: EDatabaseError;
    var DataAction: TDataAction ; const ab_Message : Boolean = False );
function fs_AjouteRechercheClePrimaire ( const adat_Dataset         : TDataset    ;
                                         const as_ChampsClePrimaire : TStringList ;
                                         const avar_ValeursCle      : Variant     ;
                                         const as_ChampExclu        : String      ): String ;
function fb_ChangeEnregistrement(var avar_EnregistrementCle : Variant ; const adat_Dataset : TDataset ;
  const as_Cle: String; const ab_Sort:Boolean): Boolean;

function fs_createFilter ( const  aadoq_Dataset : TDataSet; const lts_FieldsVerify, lts_Fields : TStrings ; const lt_Valeurs : tt_ValeurStrings ):String; overload;
function fs_createFilter ( const  aadoq_Dataset : TDataSet; const lts_FieldsVerify, lts_Fields : TStrings ; const lt_Valeurs : Variant ):String; overload;

function fb_AddIndexToDataSet(aDat_Dataset: TDataSet;const as_IndexName, as_NomChamp: String; const aio_IndexOptions: TIndexOptions; const as_NomChampOrigine : String = ''): Boolean;
function fb_MAJTableNumsOrdre ( const aDat_Dataset : TDataset ; const as_NomOrdre : String ; const ai_Intervalle : Longint ; const ab_DisableControls : Boolean ): Boolean ;
function fb_SetMultipleFieldToQuery ( const astl_Champs, astl_SQLQuery : TStrings ; const avar_Variant : Variant ; const adat_Dataset : TDataset ; const ab_AddColma : Boolean = True  ; as_table : String = '' ): Boolean ;
function fb_Locate ( const adat_Dataset : TDataset ; const as_Champ : String ; const avar_Recherche : Variant; const alo_Options : TLocateOptions ; const ab_Trie : Boolean ): Boolean ;
function fb_LocateFilter ( const aado_Seeker : TDataset ; const as_oldFilter, as_Fields, as_Condition : String ; const avar_Records : Variant ; const ach_Separator : Char ): Boolean ;

function  fb_MAJTableNumOrdre ( const aDat_Dataset : TDataset ; const avar_Numordre : Variant ; const as_NomOrdre : String ): Boolean;
function fb_IntervertitPositions2Champs   ( const aDat_Dataset : TDataset ; const as_NomOrdre : String ; const ab_Precedent, ab_SortAsc, ab_DisableControls : Boolean ): Boolean;
function  fb_SortADataset ( const aDat_Dataset : TDataset; const as_NomChamp : String ; const ab_Desc : Boolean ) : Boolean;
procedure p_UpdateBatch ( const adat_Dataset: Tdataset);
function fb_SortLocalDataSet(aDat_Dataset: TDataSet;const as_NomChamp: String; const ab_Desc : Boolean): Boolean;
function fs_stringDbQuote ( const as_Texte: string): string;
function fs_stringDbQuoteFilterLike ( const as_Texte: string): string;
function fs_stringDbQuoteLikeSQLServer ( const as_Texte: string): string;
function fs_AddDBString ( const as_Text : String ) : String;
function fb_ListeVersSQL(var as_TexteAjoute: String; const astl_Liste: TStringList; const ab_EstChaine: Boolean): Boolean;
function FieldCanAcceptKey(Field: TField; AKey: char): boolean;
// Traduit un tableau de clés de variants en résultat SQL
// as_TexteAjoute  : Le résultat sQL
// at_Liste        : la liste à traduire en SQL
// alst_Key        : le champ clé correspondant à la liste de clés
function fb_TableauVersSQL ( const ADataset : TDataset; const astl_Field : TStrings; var as_TexteAjoute : String ; const at_Liste : tt_TableauxVarOption ; const ab_TestOption : Boolean ; const aset_Options : tset_OctetOptions ) : Boolean ; overload ;

// Traduit un tableau de clés de variants en résultat SQL
// as_TexteAjoute  : Le résultat sQL
// at_Liste        : la liste à traduire en SQL
// alst_Key        : le champ clé correspondant à la liste de clés
// avar_option     : Rectification sur le champ
function fb_TableauVersSQL ( const ADataset : TDataset; const astl_Field : TStrings; const ai_Field, ai_FieldList : Integer;
                             var as_TexteAjoute : String ; const at_Liste : tt_TableauxStrings ;
                             const af_FieldValues : Variant ; const as_BeginText : String = ''; const as_EndText : String = '') : Boolean ; overload ;
function fb_DatasourceModifying ( const Datasource : TDatasource ): Boolean;



var ge_DataSetErrorEvent : TEDataSetErrorEvent = nil;
    ge_NilEvent : TDataSetErrorEvent = nil;
    // Affiche-t-on un message sur erreur ?
    gb_DBMessageOnError : Boolean =  true;
    gb_IniADOsetKeySet : Boolean = False;
    gb_ApplicationAsynchrone : Boolean = False;
  GI_GROUPE_HELP_CHANGEMENTS_SAUVER : Integer = 0 ;
  GB_ASYNCHRONE_PAR_DEFAUT : Boolean = False ;
  Gi_ASYNCHRONE_NB_ENREGISTREMENTS : Integer = 300 ;
  Gi_CONNECTION_TIMEOUT_DEFAUT : Integer = 15 ;

  
implementation

uses Variants,  Math,
{$IFDEF FPC}
     SQLDB, unite_messages,
{$ELSE}
     DBTables, unite_messages_delphi,
{$ENDIF}
   StrUtils,
   fonctions_dialogs,
   TypInfo;


function FieldCanAcceptKey(Field: TField; AKey: char): boolean;
begin
  Result := (Field<>nil) and Field.IsValidChar(AKey) and
            (Field.DataType<>ftAutoInc);
end;


///////////////////////////////////////////////////////////////////////////////
// Fonction : fs_stringDbQuote
// Description : Cette fonction permet de faire le doublement des ' dans une chaîne de caractères
// as_Texte : Le texte avec des ' éventuels
// Résultat : Le texte avec des '' à la place de '
///////////////////////////////////////////////////////////////////////////////
function fs_stringDbQuote ( const as_Texte: string): string;
begin
  result :=AnsiReplaceStr ( as_Texte, '''' , '''''' );
end;


function fs_AddDBString ( const as_Text : String ) : String;
Begin
  Result := '''' + fs_stringDbQuote(as_Text)+'''';
end;


///////////////////////////////////////////////////////////////////////////////
// fonction : fs_stringDbQuoteFilterLike
// Description : création d'un filtrage ADO en fonction de caractères spéciaux
//  Cette fonction permet de faire le doublement des ' dans une chaîne de caractères
// as_Texte : Le texte qui va devenir filtre
// Résultat : Le filtre du texte
///////////////////////////////////////////////////////////////////////////////
function fs_stringDbQuoteFilterLike ( const as_Texte: string): string;
//var li_i : Integer ;
begin
  Result :=AnsiReplaceStr ( as_Texte, '''' , '''''' );
  if  ( Result     <> ''  )
  and ( Result [1] =  '%' )Then
    Result := CST_SQL_ALL + copy ( Result, 2, length ( Result ) - 1 );
  if ( Result = '_' )
  or ( Result = '_*' )
  or ( Result = CST_SQL_ALL )
  or ( Result = '**' )
  or ( Result = '%' ) Then
    Result := '' ;
{  for li_i := 1 to length ( as_Texte ) do
    case ord ( as_Texte [ li_i ] ) of
      CST_ORD_GUILLEMENT : Result := Result + '''''' ;
      CST_ORD_ASTERISC   : Result := Result + CST_SQL_ALL ;
      CST_ORD_SOULIGNE   : Result := Result + '_' ;
      CST_ORD_POURCENT   : Result := Result + '%' ;
    Else
      Result := Result + as_Texte [ li_i ] ;
    End ;}
end;

function fs_stringDbQuoteLikeSQLServer ( const as_Texte: string): string;
var li_i : Integer ;
begin
  Result := '' ;
  for li_i := 1 to length ( as_Texte ) do
    case ord ( as_Texte [ li_i ] ) of
      CST_ORD_GUILLEMENT : Result := Result + '''''' ;
      CST_ORD_OUVRECROCHET : Result := Result + '[[]' ;
      CST_ORD_FERMECROCHET : Result := Result + '[]]' ;
      CST_ORD_ASTERISC : Result := Result + '[*]' ;
      CST_ORD_SOULIGNE : Result := Result + '[_]' ;
      CST_ORD_POURCENT : Result := Result + '[%]' ;
    Else
      Result := Result + as_Texte [ li_i ] ;
    End ;
end;


////////////////////////////////////////////////////////////////////////////////
// fonction : fb_ListeVersSQL
// Description : Fonction de transformation d'une string liste en SQL
// as_TexteAjoute : Le texte de la liste séparé par des virgules
// astl_Liste     : La liste
// ab_EstChaine   : La liste de retour sera une liste de chaînes
////////////////////////////////////////////////////////////////////////////////
function fb_ListeVersSQL(var as_TexteAjoute: String; const astl_Liste: TStringList; const ab_EstChaine: Boolean): Boolean;
var li_i: Integer;
begin
  // On a rien
  Result := False;
  // Pas de texte
  as_TexteAjoute := '';
  for li_i := 0 to astl_Liste.Count - 1 do
    begin
      // On a quelque chose
      Result := True;
      if li_i = 0 then // Première ligne
        if ab_EstChaine then // Chaîne
          as_TexteAjoute := '''' + fs_StringDBQuote(astl_Liste[li_i]) + ''''
        else
          as_TexteAjoute := astl_Liste[li_i] // Autre
      else
        if ab_EstChaine then
          as_TexteAjoute := as_TexteAjoute + ',''' + fs_StringDBQuote(astl_Liste[li_i]) + ''''
        else
          as_TexteAjoute := as_TexteAjoute + ',' + astl_Liste[li_i];
    end;
end;



function fb_LocateFilter ( const aado_Seeker : TDataset ; const as_oldFilter, as_Fields, as_Condition : String ; const avar_Records : Variant ; const ach_Separator : Char ): Boolean ;
var ls_Filter : String ;
    ls_And : String ;
Begin
  Result := False ;
  if pos ( ach_Separator, as_Fields ) <= 0 Then
    Begin
      if as_oldFilter <> ''  then
        ls_And := CST_SQL_AND
       else
        ls_And := '' ;

      ls_Filter := as_Fields + as_Condition ;
      if ( aado_Seeker.FieldByName ( as_Fields ).DataType in CST_DELPHI_FIELD_STRING )
        Then
          ls_Filter := ls_Filter + '''' + fs_stringDbQuote ( avar_Records ) + ''''
        Else
          ls_Filter := ls_Filter + fs_stringDbQuote ( VarToStr ( avar_Records )) ;
      aado_Seeker.Filter := as_oldFilter+ ls_And + ls_Filter;
      aado_Seeker.Refresh ;
      Result := aado_Seeker.RecordCount > 0 ;
    End ;
End ;

procedure p_GereExceptionEvent (const DataSet: TDataSet; const E: EDatabaseError;
    var DataAction: TDataAction ; const ab_Message : Boolean );
Begin
  if assigned ( ge_DataSetErrorEvent ) Then
    ge_DataSetErrorEvent (DataSet, E, DataAction );
  case DataAction of
    daFail: Exit;
    daAbort: Abort;
  End;
  if ab_Message then
    MyShowMessage ( GS_ERREUR_DONNEES + E.Message );
end;



function fb_Locate(const adat_Dataset: TDataset;
  const as_Champ: String; const avar_Recherche: Variant;
  const alo_Options: TLocateOptions; const ab_Trie : Boolean ): Boolean;
var lext_Tempo ,
    lext_Recherche : Extended ;
    lb_Continue    : Boolean ;
    lde_DoingAfter : TDataAction;
begin
  Result := False ;
  if not assigned ( adat_Dataset )
  or ( adat_Dataset.IsEmpty )
  or VarIsArray (  avar_Recherche )
  or ( avar_Recherche = Null ) Then
    Exit ;

  lb_Continue := False ;
  lext_Recherche := 0 ;
  if assigned ( adat_Dataset.FindField ( as_Champ ))
  and ( adat_Dataset.FieldByName ( as_Champ ) is TNumericField ) Then
    try
      if VarIsStr ( avar_Recherche ) Then
        Begin
          If  ( Trim ( avar_Recherche ) <> '**' )
          and ( Trim ( avar_Recherche ) <> ''   ) Then
            lext_Recherche := StrToFloat ( avar_Recherche )
        End
      Else
        lext_Recherche := avar_Recherche ;
      If  ( Trim ( avar_Recherche ) <> '**' )
      and ( Trim ( avar_Recherche ) <> ''   ) Then
        lb_Continue := True ;
    Except
    End
   Else lb_Continue := True ;
  try
    if ab_Trie
    and assigned ( adat_Dataset.FindField ( as_Champ )) then
      p_SetComponentProperty(adat_Dataset, 'Sort', as_Champ + CST_SQL_ASC  );

    if assigned ( adat_Dataset.FindField ( as_Champ ))
      and not adat_Dataset.IsEmpty
      and ( adat_Dataset.FieldByName ( as_Champ ) is TNumericField )
      and lb_Continue Then
        with adat_Dataset do
          Begin
            First ;
            while not eof do
              Begin
                lExt_Tempo := adat_Dataset.FieldByName ( as_Champ ).AsFloat ;
                if  ( CompareValue ( lext_Tempo, lext_Recherche, 0 ) = 0 )  Then
                  Begin
                    Result := True ;
                    Exit ;
                  End ;
                if  ( CompareValue ( lext_Tempo, lext_Recherche, 0 ) = 1 )  Then
                  Begin
                    Exit ;
                  End ;
                adat_Dataset.Next ;
              End ;
          End
        Else
          Result := adat_Dataset.Locate ( as_Champ, avar_Recherche, alo_Options );
  Except
    on e: EDatabaseError do
     begin
       lde_DoingAfter := daRetry;
       p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
     End;
  End ;
end;

// Mise à jour du numéro d'ordre ( position  dans une table )
// aDat_Dataset : Dataset à changer
// ai_NumOrdre : Nouveau numéro d'ordre de la table
// as_NomOrdre : Champ d'ordonnancement
// Retour   : Y a - t-il eu une erreur
function  fb_MAJTableNumOrdre ( const aDat_Dataset : TDataset ; const avar_Numordre : Variant ; const as_NomOrdre : String ): Boolean;
var lde_DoingAfter : TDataAction;
Begin
  Result := False ;
  try
    aDat_Dataset.Edit ;
    aDat_Dataset.FieldByName ( as_NomOrdre ).Value := avar_Numordre ;
    aDat_Dataset.Post ;
    Result := True ;
  Except
    on e: EDatabaseError do
     begin
       lde_DoingAfter := daRetry;
       p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
     End;
  End ;
End ;


// Mise à jour du numéro d'ordre ( position  dans une table )
// aDat_Dataset : Dataset à changer
// as_NomOrdre : Champ d'ordonnancement
// ab_erreur   : Y a - t-il eu une erreur
function fb_MAJTableNumsOrdre ( const aDat_Dataset : TDataset ; const as_NomOrdre : String ; const ai_Intervalle : Longint ; const ab_DisableControls : Boolean ): Boolean ;
var li_Numordre1    : Longint ;
    lde_DoingAfter : TDataAction;
begin
  Result := True ;
  if ab_DisableControls then
    aDat_Dataset.DisableControls;
  try
    aDat_Dataset.First ;
    li_Numordre1 := 1 ;
    // Début des numéros d'ordonancement
    // Affectation des nouveaux numéros d'ordre
    while li_Numordre1 <= 1 + aDat_Dataset.RecordCount * ai_Intervalle  do
      Begin
        if not fb_MAJTableNumOrdre ( aDat_Dataset, li_Numordre1, as_NomOrdre ) Then
          // Pa smis à jour
          Result := False ;
        aDat_Dataset.Next;
        if aDat_Dataset.Eof Then
          Break;
        inc ( li_Numordre1, ai_Intervalle );
      End;
  Except
   // Erreur = faux
    on e: EDatabaseError do
     begin
       lde_DoingAfter := daRetry;
       Result := False;
       p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
     End;
  End;
  if ab_DisableControls then
    aDat_Dataset.EnableControls;
End;

// Intervertit deux enregistrement dans le positionement
// aDat_GroupeFonctions : La dataset associé
// ab_Precedent         : Précédent ou non alors suivant
function fb_IntervertitPositions2Champs   ( const aDat_Dataset : TDataset ; const as_NomOrdre : String ; const ab_Precedent, ab_SortAsc, ab_DisableControls : Boolean ): Boolean;
var lvar_Numordre1      ,
    lvar_Numordre2      : Variant ;
    {$IFDEF WITH_TBOOKMARK}
    lbkm_GardeEnr     : TBookmark ;
    {$ELSE}
    lbkm_GardeEnr     : TBookmarkStr ;
    {$ENDIF}
    lb_continue       : Boolean ;

begin
  Result := False ;
  if not assigned ( aDat_Dataset )
  or not ( aDat_Dataset.Active )
   Then
    Exit ;
    // Enregistement en cours
  lvar_Numordre1      := aDat_Dataset.FieldByName ( as_NomOrdre ).Value ;
  if ab_Precedent
  and aDat_Dataset.Bof
   Then
    Exit ;
  if not ab_Precedent
  and aDat_Dataset.Eof
   Then
    Exit ;
// Bookmark pour revenir à l'enregistrement sélectionné
  lbkm_GardeEnr := aDat_Dataset.Bookmark ;
  if ab_DisableControls Then
    aDat_Dataset.DisableControls ;
  try
    fb_SortADataset ( aDat_Dataset, as_NomOrdre, True );
    try
      aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
    Except
    End ;
    lb_continue := True ;
    if ab_Precedent
     Then
      Begin
      // Enregistement précédent
        aDat_Dataset.Prior ;
        if not aDat_Dataset.Bof
         Then
          Begin
            lvar_Numordre2      := aDat_Dataset.FieldByName ( as_NomOrdre ).Value ;
            if VarCompareValue ( lvar_Numordre1, lvar_Numordre2 ) = vrEqual Then
              Begin
                lb_continue := False ;
                if ( aDat_Dataset.FieldByName ( as_NomOrdre ) is TNumericField ) Then
                  Begin
                    fb_MAJTableNumsOrdre ( aDat_Dataset, as_NomOrdre, CST_SQL_ORDER_INTERLEAVING, ab_DisableControls );
                    aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
                    fb_IntervertitPositions2Champs ( aDat_Dataset, as_NomOrdre, ab_Precedent, ab_SortAsc, ab_DisableControls );
                    Exit;
                  End;
              End ;
            if lb_continue Then
              Begin
                Result := fb_MAJTableNumOrdre ( aDat_Dataset, lvar_Numordre1, as_NomOrdre );
                try
                  aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
                Except
                End ;
                Result := Result and fb_MAJTableNumOrdre ( aDat_Dataset, lvar_Numordre2, as_NomOrdre );
              End ;
          End ;
      End
     Else
      Begin
      // Enregistement précédent
        aDat_Dataset.Next ;
        if not aDat_Dataset.Eof
         Then
           Begin
            lvar_Numordre2      := aDat_Dataset.FieldByName ( as_NomOrdre ).AsInteger ;
            if VarCompareValue ( lvar_Numordre1, lvar_Numordre2 ) = vrEqual Then
              Begin
                lb_continue := False ;
                if ( aDat_Dataset.FieldByName ( as_NomOrdre ) is TNumericField ) Then
                  Begin
                    fb_MAJTableNumsOrdre ( aDat_Dataset, as_NomOrdre, CST_SQL_ORDER_INTERLEAVING, ab_DisableControls);
                    aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
                    fb_IntervertitPositions2Champs ( aDat_Dataset, as_NomOrdre, ab_Precedent, ab_SortAsc, ab_DisableControls );
                    Exit;
                  End;
              End ;
            if lb_continue Then
              Begin
                Result := fb_MAJTableNumOrdre ( aDat_Dataset, lvar_Numordre1, as_NomOrdre );
                try
                  aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
                Except
                End ;
                Result := Result and fb_MAJTableNumOrdre ( aDat_Dataset, lvar_Numordre2, as_NomOrdre );
              End ;
           End;
      End ;
     // Mise à jour de la table liée
  //  aDat_Dataset.Refresh ;
  {  if (aDat_Dataset is TADOTable) then
      TADOTable(aDat_Dataset).Sort   := ls_NomOrdre + CST_SQL_ASC
      else if (aDat_Dataset is TADOQuery) then
         TADOQuery(aDat_Dataset).Sort   := ls_NomOrdre + CST_SQL_ASC ;}
  finally
    if ab_DisableControls Then
      aDat_Dataset.EnableControls ;
    try
      aDat_Dataset.Bookmark := lbkm_GardeEnr  ;
    Except
    End ;
  End ;
end;

function fb_SetMultipleFieldToQuery ( const astl_Champs, astl_SQLQuery : TStrings ; const avar_Variant : Variant ; const adat_Dataset : TDataset ; const ab_AddColma : Boolean = True ; as_table : String = ''): Boolean ;
var li_i : Integer ;
    lde_DoingAfter : TDataAction;
Begin
  Result := False ;
  if as_table <> '' Then
    as_table:=as_table+CST_FIELD_DECLARE_SEPARATOR;
  if astl_Champs.Count <= 1 Then
    try
      if VarIsNull ( avar_Variant ) Then
        astl_SQLQuery.Add( ' ' + as_table + astl_Champs [ 0 ] + CST_SQL_IS + CST_SQL_NULL   )
      Else
        if ((adat_Dataset.FindField ( astl_Champs [ 0 ] ) is TStringField )
        or (adat_Dataset.FindField ( astl_Champs [ 0 ] ) is TMemoField )
        or ( adat_Dataset.FindField ( astl_Champs [ 0 ] ).DataType IN CST_DELPHI_FIELD_STRING ))
         Then
          astl_SQLQuery.Add( ' ' + as_table + astl_Champs [ 0 ] + '=''' + avar_Variant + '''' )
         Else
          astl_SQLQuery.Add( ' ' + as_table + astl_Champs [ 0 ] + '=''' + avar_Variant + '''' );
      Result := True ;
    Except
      on e: EDatabaseError do
       begin
         lde_DoingAfter := daRetry;
         p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
       End;
    End ;
  try
    for li_i := 0 to astl_Champs.Count - 1 do
      Begin
        if VarIsNull ( avar_Variant [ li_i ] ) Then
          if li_i = 0 Then
            astl_SQLQuery.Add( ' (' + as_table + astl_Champs [ li_i ] + '=''' + avar_Variant [ li_i ] + '''' )
          Else
            astl_SQLQuery.Add ( CST_SQL_AND + as_table + astl_Champs [ li_i ] + CST_SQL_IS + CST_SQL_NULL );

        if ((adat_Dataset.FindField ( astl_Champs [ li_i ] ) is TStringField )
        or (adat_Dataset.FindField ( astl_Champs [ li_i ] ) is TMemoField )
        or ( adat_Dataset.FindField ( astl_Champs [ li_i ] ).DataType IN CST_DELPHI_FIELD_STRING ))
         Then
          Begin
            if li_i = 0 Then
              astl_SQLQuery.Add( ' (' + as_table + astl_Champs [ li_i ] + '=''' + avar_Variant [ li_i ] + '''' )
            Else
              astl_SQLQuery.Add ( CST_SQL_AND + as_table + astl_Champs [ li_i ] + '=''' + avar_Variant [ li_i ] + '''' )
          End
        Else
          Begin
            if li_i = 0 Then
              astl_SQLQuery.Add( ' (' + as_table + astl_Champs [ li_i ] + '=' + avar_Variant [ li_i ] )
            Else
              astl_SQLQuery.Add ( CST_SQL_AND + as_table + astl_Champs [ li_i ] + '=' + avar_Variant [ li_i ] )
          End ;
        End ;
    If ab_AddColma Then
      astl_SQLQuery.Add( ')' );
    Result := True ;
  Except
    on e: EDatabaseError do
     begin
       lde_DoingAfter := daRetry;
       Result := False;
       p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
     End;
  End ;
End ;

procedure p_UpdateBatch ( const adat_Dataset: Tdataset);
Begin
  {$IFDEF EADO}
  if Assigned ( ge_SpecialRefreshDataset ) then
   ge_SpecialRefreshDataset ( adat_Dataset )
  else
  {$ELSE}
   {$IFDEF FPC}
     adat_Dataset.Refresh;
   {$ELSE}
     adat_Dataset.Close;
     adat_Dataset.Open;
   {$ENDIF}
 {$ENDIF}

End ;
/////////////////////////////////////////////////////////////////////////////////
// Function : fvar_getKeyRecord
// Description : Get Key record
// Paramètres : adat_Dataset : Le dataset du compteur
//              aslt_Cle     : La clé du dataset
// Returns Variant
/////////////////////////////////////////////////////////////////////////////////

function fs_AjouteRechercheClePrimaire ( const adat_Dataset         : TDataset    ;
                                         const as_ChampsClePrimaire : TStringList ;
                                         const avar_ValeursCle      : Variant     ;
                                         const as_ChampExclu        : String      ): String ;

var
    ls_EnrChamp  : String ;
    lvar_Valeur  : Variant ;
    li_i         : Integer ;
    lb_First     : Boolean ;
    ls_SQL       : WideString;
Begin
  Result := '' ;
  lb_First     := True ;
  for li_i := 0 to as_ChampsClePrimaire.Count - 1 do
    if as_ChampExclu <> as_ChampsClePrimaire [ li_i ] Then
      Begin
        if  ( adat_Dataset.State <> dsInsert ) Then
          Begin
            if VarIsArray ( avar_ValeursCle ) Then
              Begin
                if  ( li_i >= varArrayLowBound  ( avar_ValeursCle, 1 ))
                and ( li_i <= varArrayHighBound ( avar_ValeursCle, 1 ))
                and ( avar_ValeursCle [ li_i ] <> Null ) Then
                  lvar_Valeur := avar_ValeursCle [ li_i ]
                Else
                  lvar_Valeur := Null ;
              End
            Else lvar_Valeur := avar_ValeursCle ;
            if  ( lvar_Valeur <> Null )
            and ( adat_Dataset.State = dsEdit )
            and ( Trim ( adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ).AsString ) <> Trim ( VarToStr( lvar_Valeur ))) Then
              Begin
                lvar_Valeur := adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ).Value ;
              End ;
          End
        Else
          Begin
            lvar_Valeur := adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ).Value ;
          End ;
        if lvar_Valeur = Null Then
          ls_EnrChamp := 'NULL'
        Else
          if VarIsFloat ( lvar_Valeur ) Then
            ls_EnrChamp := fs_RemplaceChar ( FloatToStr( lvar_Valeur ), ',', '.' )
        Else
          ls_EnrChamp := fs_RemplaceChar ( VarToStr( lvar_Valeur ), ',', '.' ) ;
        if lb_First then
          ls_SQL := CST_SQL_WHERE
         Else
          ls_SQL := CST_SQL_AND ;
        if  ( adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ) <> nil              )
        and ( adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ).DataType = ftString )
        and ( adat_Dataset.FindField ( as_ChampsClePrimaire [ li_i ] ).Value <> Null       )
         Then ls_SQL := ls_SQL + as_ChampsClePrimaire [ li_i ] + '=''' + fs_stringDbQuote ( ls_EnrChamp ) + ''''
         else ls_SQL := ls_SQL + as_ChampsClePrimaire [ li_i ] + '='   +                    ls_EnrChamp ;
       Result := ls_SQL ;
       lb_First     := False ;
      End ;
End ;




// Teste si on change d'enregistrement
// Compare Un enregistrement ( variant ) et l'affecte à nouveau avec l'enregistrement de la clé en renvoyant true
// avar_EnregistrementCle : un vairant à mette dans la form propriétaire et à ne toucher qu'avec cette fonction
// adat_Dataset           : Le dataset de la clé
// as_Cle                 : LA clé
function fb_ChangeEnregistrement(var avar_EnregistrementCle : Variant ; const adat_Dataset : TDataset ;
  const as_Cle: String; const ab_Sort:Boolean): Boolean;
var lvar_NouveauEnregistrementCle : Variant ;
    li_i : Integer ;
    lde_DoingAfter : TDataAction;
begin
  // On n'a pas changé d'enregistrement par défaut
  Result := False ;
  if ab_Sort Then
    Exit ;
  if      adat_Dataset.Active
  and not adat_Dataset.IsEmpty
  and ( adat_Dataset.FieldDefs.Count > 0 )
  and ( as_Cle <> '' ) Then
    Begin
      try
        lvar_NouveauEnregistrementCle := adat_Dataset.FieldValues [ as_Cle ];
    // Compare Un enregistrement ( variant )
    // Tableau de valeurs
      if  VarIsArray ( lvar_NouveauEnregistrementCle ) Then
        Begin
          if not VarIsArray ( avar_EnregistrementCle        ) Then
            Begin
              avar_EnregistrementCle := lvar_NouveauEnregistrementCle ;
              Result := True ;
            End
          Else
            for li_i := VarArrayLowBound ( lvar_NouveauEnregistrementCle, 1 ) to VarArrayHighBound ( lvar_NouveauEnregistrementCle, 1 ) do
              if  ( li_i >= VarArrayLowBound  ( avar_EnregistrementCle, 1 ))
              and ( li_i <= VarArrayHighBound ( avar_EnregistrementCle, 1 )) Then
                if (( avar_EnregistrementCle        [ li_i ] <> Null ) and ( lvar_NouveauEnregistrementCle [ li_i ] =  Null ))
                or (( avar_EnregistrementCle        [ li_i ] =  Null ) and ( lvar_NouveauEnregistrementCle [ li_i ] <> Null ))
                or  (( avar_EnregistrementCle       [ li_i ] <> Null )
                and ( lvar_NouveauEnregistrementCle [ li_i ] <> Null )
                and ( VarCompareValue ( avar_EnregistrementCle [ li_i ], lvar_NouveauEnregistrementCle [ li_i ] ) <> vrEqual )) Then
                  Begin
                    avar_EnregistrementCle        [ li_i ] := lvar_NouveauEnregistrementCle [ li_i ];
                    // Une valeur est différente alors on a changé d'enregistrement
                    Result := True ;
                  End
                Else
                  avar_EnregistrementCle        [ li_i ] := lvar_NouveauEnregistrementCle [ li_i ];

        End
      Else
        if ( as_Cle <> '' ) Then
        // Pas de tableau
          if  ( avar_EnregistrementCle        <> Null )
          and ( lvar_NouveauEnregistrementCle <> Null ) Then
            Begin
              if ( VarCompareValue ( avar_EnregistrementCle, lvar_NouveauEnregistrementCle ) <> vrEqual ) Then
                Begin
                  // et l'affecte à nouveau avec l'enregistrement de la clé en renvoyant true
                  avar_EnregistrementCle := lvar_NouveauEnregistrementCle ;
                  // La valeur est différente alors on a changé d'enregistrement
                  Result := True ;
                End ;
            End
          Else
            if  ( lvar_NouveauEnregistrementCle <> Null ) Then
              Begin
                // et l'affecte à nouveau avec l'enregistrement de la clé en renvoyant true
                avar_EnregistrementCle := lvar_NouveauEnregistrementCle ;
                // La valeur est différente alors on a changé d'enregistrement
                Result := True ;
              End

      except
        on e: EDatabaseError do
         begin
           lde_DoingAfter := daRetry;
           Result := False;
           p_GereExceptionEvent ( adat_Dataset, E, lde_DoingAfter );
         End;
      End ;
    End
   Else
     avar_EnregistrementCle := Null ;
end;

// Mise à jour de la propriété sort
// aDat_Dataset : Le dataset
// as_NomChamp : Le champ à trier
// ab_Desc  : Descendant ou Montant
function  fb_SortADataset ( const aDat_Dataset : TDataset; const as_NomChamp : String ; const ab_Desc : Boolean ) : Boolean;
Begin
  Result := False ;
  try
    if  Assigned( ge_SpecialSort )
     then
      ge_SpecialSort ( aDat_Dataset, as_NomChamp, ab_Desc )
     Else
    if assigned ( GetPropInfo ( aDat_DataSet, 'SortedFields' )) Then
      Begin
        Result := True;
        p_SetComponentProperty ( aDat_DataSet, 'SortedFields', as_NomChamp);
        if ab_Desc Then
          p_SetComponentProperty ( aDat_DataSet, 'SortType', 1)
         Else
          p_SetComponentProperty ( aDat_DataSet, 'SortType', 0);
        Exit;
      End;
     Result := fb_SortLocalDataSet(aDat_Dataset, as_NomChamp, ab_Desc );
  Except
  End ;
End ;


function fb_SortLocalDataSet(aDat_Dataset: TDataSet;const as_NomChamp: String; const ab_Desc : Boolean): Boolean;
var
  i: Integer;
  IndexDefs: TIndexDefs;
  ls_IndexName: String;
  IndexOptions: TIndexOptions;
  Field: TField;
begin
  Result := False;
  Field := aDat_DataSet.Fields.FindField(as_NomChamp);
  //If invalid field name, exit.
  if Field = nil then Exit;
  //if invalid field type, exit.
  if {(Field is TObjectField) or} (Field is TBlobField) or
    {(Field is TAggregateField) or} (Field is TVariantField)
     or (Field is TBinaryField) then Exit;
  //Get IndexDefs and IndexName using RTTI
  if IsPublishedProp(aDat_DataSet, 'IndexDefs') then
    IndexDefs := GetObjectProp(aDat_DataSet, 'IndexDefs') as TIndexDefs
  else
    Exit;
  if IsPublishedProp(aDat_DataSet, 'IndexName') then
    ls_IndexName := GetStrProp(aDat_DataSet, 'IndexName')
  else
    Exit;
  //Ensure IndexDefs is up-to-date
  IndexDefs.Update;
  //If an ascending index is already in use,
  //switch to a descending index
  if ab_Desc
  then
    begin
      ls_IndexName := as_NomChamp + '__IdxD';
      IndexOptions := [ixDescending];
    end
  else
    begin
      ls_IndexName := as_NomChamp + '__IdxA';
      IndexOptions := [];
    end;
  //Look for existing index
  for i := 0 to Pred(IndexDefs.Count) do
  begin
    if IndexDefs[i].Name = ls_IndexName then
      begin
        Result := True;
        Break
      end;  //if
  end; // for
  //If existing index not found, create one
  if not Result then
      begin
        if ls_IndexName=as_NomChamp + '__IdxD' then
          fb_AddIndexToDataSet(aDat_Dataset, ls_IndexName, as_NomChamp, IndexOptions, as_NomChamp)
        else
          fb_AddIndexToDataSet(aDat_Dataset, ls_IndexName, as_NomChamp, IndexOptions);
        Result := True;
      end; // if not
  //Set the index
  SetStrProp(aDat_DataSet, 'IndexName', ls_IndexName);
end;

function fb_AddIndexToDataSet(aDat_Dataset: TDataSet;const as_IndexName, as_NomChamp: String; const aio_IndexOptions: TIndexOptions; const as_NomChampOrigine : String = ''): Boolean;
Begin
  {$IFDEF REMOTE}
  if aDat_Dataset is TCustomBufDataset
   Then
     Begin
       (aDat_Dataset as TCustomBufDataset ).AddIndex(as_IndexName,as_NomChamp,aio_IndexOptions,as_NomChampOrigine)
       Exit;
     end;
  {$ENDIF}
  {$IFDEF CSV}
   if aDat_Dataset is TCustomSdfDataset
    Else (aDat_Dataset as TCustomSdfDataset ).AddIndex(as_IndexName,as_NomChamp,aio_IndexOptions,as_NomChampOrigine);
  {$ENDIF}
end;

{ TDataLinkOwnered }

procedure TDataLinkOwnered.EditingChanged;
begin
  inherited EditingChanged;
  if assigned ( FOwner ) Then
    FOwner.EditingChanged;
end;

procedure TDataLinkOwnered.DataSetChanged;
begin
  inherited DataSetChanged;
  if assigned ( FOwner ) Then
    FOwner.DataSetChanged;
end;

procedure TDataLinkOwnered.ActiveChanged;
begin
  inherited ActiveChanged;
  if assigned ( FOwner ) Then
    FOwner.ActiveChanged;
end;

constructor TDataLinkOwnered.Create(AOwner: IDatalinkOwner);
begin
  Inherited Create;
  FOwner := AOwner;
end;

function fs_createFilter ( const  aadoq_Dataset : TDataSet; const lts_FieldsVerify, lts_Fields : TStrings ; const lt_Valeurs : Variant ):String;
var lt_strings : tt_valeurStrings;
Begin
  CopyArrayVariantToArrayString (lt_Valeurs, lt_strings );
  Result:=fs_createFilter(aadoq_Dataset,lts_FieldsVerify,lts_Fields,lt_strings);
End;

function fs_createFilter ( const  aadoq_Dataset : TDataSet; const lts_FieldsVerify, lts_Fields : TStrings ; const lt_Valeurs : tt_ValeurStrings ):String;
var li_i : Integer;
Begin
  for li_i := 0 to lts_Fields.Count -1 do
   Begin
    if li_i > 0 Then Result := Result + CST_SQL_AND;
    if ( aadoq_Dataset.FindField ( lts_FieldsVerify [ li_i ] ).DataType in CST_DELPHI_FIELD_STRING )
     Then Result := Result + lts_Fields [ li_i ] + ' = ''' + fs_stringDbQuote ( lt_Valeurs [ li_i ] ) + ''''
     Else Result := Result + lts_Fields [ li_i ] + ' = ' + lt_Valeurs [ li_i ] ;
   end;
End;

function fb_TableauVersSQL ( const ADataset : TDataset; const astl_Field : TStrings; var as_TexteAjoute : String ; const at_Liste : tt_TableauxVarOption ; const ab_TestOption : Boolean ; const aset_Options : tset_OctetOptions ) : Boolean ;
var li_i, li_j : Integer ;
    lb_PremiereFois, lb_continue : Boolean ;
Begin
  // on a rien
  Result := False ;
  // Pas de texte
  as_TexteAjoute := '' ;
  if Length ( at_Liste ) <= 0
   Then
    Exit ;
  lb_PremiereFois := True ;
  with ADataset do
    for li_i := 0 to high ( at_Liste ) do
     with at_Liste [ li_i ] do
     for li_j := 0 to high ( as_Key ) do
      Begin
        // On a quelque chose
        if ( as_Key [li_j]= '' )
        or ( ab_TestOption and not ( i_Option in aset_Options ))
         Then
          Break ;
          // on a une clé
        Result := True ;
        // Ajoute
        if lb_PremiereFois // Première ligne
         Then
           Begin
             if FieldByName ( astl_Field [0] ) is TNumericField // Chaîne
               Then as_TexteAjoute :=  VarToStr ( at_Liste [ li_i ].as_Key [ li_j ])  // Numeric
               Else as_TexteAjoute := '''' + fs_StringDBQuote ( at_Liste [ li_i ].as_Key [ li_j ]) + ''''
           End
         Else
         if FieldByName ( astl_Field [0] ) is TNumericField // Chaîne
           Then as_TexteAjoute := as_TexteAjoute + ','   +         VarToStr ( at_Liste [ li_i ].as_Key [ li_j ])  // Numeric
           Else as_TexteAjoute := as_TexteAjoute + ',''' + fs_StringDBQuote ( at_Liste [ li_i ].as_Key [ li_j ]) + '''' ;
        lb_PremiereFois := False ;
      End ;
End ;

function fb_TableauVersSQL ( const ADataset : TDataset; const astl_Field : TStrings; const ai_Field, ai_FieldList : Integer;
                             var as_TexteAjoute : String ; const at_Liste : tt_TableauxStrings;
                             const af_FieldValues : Variant ; const as_BeginText : String = ''; const as_EndText : String = '') : Boolean ;
var li_i : Integer ;
    lb_PremiereFois : Boolean ;
Begin
  // on a rien
  Result := False ;
  // Pas de texte
  as_TexteAjoute := '' ;
  if Length ( at_Liste ) = 0
   Then
    Exit ;
  lb_PremiereFois := True ;
  with ADataset do
   for li_i := 0 to high ( at_Liste [ ai_FieldList ] ) do
    Begin
      // On a quelque chose
      if at_Liste [ ai_FieldList , li_i ] = ''
       Then
        Continue ;
        // on a une clé
      Result := True ;
      // Ajoute
      if lb_PremiereFois // Première ligne
       Then
         Begin
           if FieldByName ( astl_Field [ ai_Field ] ) is TNumericField
            Then as_TexteAjoute := as_BeginText +         fs_StringDBQuote ( at_Liste [ ai_FieldList , li_i ])       + as_EndText// option
            Else as_TexteAjoute := as_BeginText + '''' + fs_StringDBQuote ( at_Liste [ ai_FieldList , li_i ]) + '''' + as_EndText; // Chaîne
         End
       Else
       if FieldByName ( astl_Field [ ai_Field ] ) is TNumericField
         Then as_TexteAjoute := as_TexteAjoute + ','   + as_BeginText +        fs_StringDBQuote ( at_Liste [ ai_FieldList , li_i ])         + as_EndText// option
         Else as_TexteAjoute := as_TexteAjoute + ','   + as_BeginText + '''' + fs_StringDBQuote ( at_Liste [ ai_FieldList , li_i ]) + ''''  + as_EndText;// Chaîne
      lb_PremiereFois := False ;
    End ;
End ;

function fb_DatasourceModifying ( const Datasource : TDatasource ): Boolean;
Begin
  Result:=    assigned ( Datasource )
          and assigned ( Datasource.Dataset )
          and (Datasource.Dataset.State in [ dsedit,dsInsert ]);

end;

procedure p_DatasourcePostIfEdited ( const Datasource : TDatasource );
Begin
  with Datasource.Dataset do
   if State in [ dsedit,dsInsert ] Then
    Post;
end;

procedure p_DatasetPostIfEdited ( const Dataset : TDataset );
Begin
  with Dataset do
   if State in [ dsedit,dsInsert ] Then
    Post;
end;

procedure p_DatasetEditIfNotEdited ( const Dataset : TDataset );
Begin
  with Dataset do
   if not (State in [ dsedit,dsInsert ]) Then
    Edit;
end;

// récupère la propriété sort
// aDat_Dataset : Le dataset
// Sortie : La propriété sort
{function TF_CustomFrameWork.fs_GetSort ( const aDat_Dataset : TDataset ) : String ;
Begin
  Result := '' ;
  if ( aDat_DataSet is TCustomADODataset ) then
    Result := TCustomADODataset( aDat_DataSet ).Sort
End ;}



{$IFDEF VERSIONS}
initialization
  p_ConcatVersion ( gVer_fonctions_db );
{$ENDIF}
end.
