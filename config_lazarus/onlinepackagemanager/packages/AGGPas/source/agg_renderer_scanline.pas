
{**********************************************************************
 Package pl_AGGPas
 is a modification of
 Anti-Grain Geometry 2D Graphics Library (http://www.aggpas.org/)
 for CodeTyphon Studio (http://www.pilotlogic.com/)
 This unit is part of CodeTyphon Studio
***********************************************************************}
unit
agg_renderer_scanline;

interface

{$I agg_mode.inc }
{$Q- }
{$R- }
uses
  agg_basics,
  agg_renderer_base,
  agg_color,
  agg_scanline,
  agg_scanline_p,
  agg_scanline_bin,
  agg_span_generator,
  agg_span_allocator,
  agg_rasterizer_scanline_aa,
  agg_rasterizer_compound_aa;

type
  renderer_scanline_ptr = ^renderer_scanline;

  renderer_scanline = object(rasterizer_scanline)
    procedure color_(c: aggclr_ptr); virtual; abstract;
    procedure prepare(u: unsigned); virtual; abstract;
    procedure render(sl: scanline_ptr); virtual; abstract;

  end;

  renderer_scanline_aa = object(renderer_scanline)
    m_ren: renderer_base_ptr;
    m_span_gen: span_generator_ptr;

    constructor Construct; overload;
    constructor Construct(ren: renderer_base_ptr; span_gen: span_generator_ptr); overload;

    procedure attach(ren: renderer_base_ptr; span_gen: span_generator_ptr);

    procedure prepare(u: unsigned); virtual;
    procedure render(sl: scanline_ptr); virtual;

  end;

  renderer_scanline_aa_solid_ptr = ^renderer_scanline_aa_solid;

  renderer_scanline_aa_solid = object(renderer_scanline)
    m_ren: renderer_base_ptr;
    m_color: aggclr;

    constructor Construct(ren: renderer_base_ptr);

    procedure color_(c: aggclr_ptr); virtual;
    procedure prepare(u: unsigned); virtual;
    procedure render(sl: scanline_ptr); virtual;

  end;

  renderer_scanline_bin_solid_ptr = ^renderer_scanline_bin_solid;

  renderer_scanline_bin_solid = object(renderer_scanline)
    m_ren: renderer_base_ptr;
    m_color: aggclr;

    constructor Construct(ren: renderer_base_ptr);

    procedure color_(c: aggclr_ptr); virtual;
    procedure prepare(u: unsigned); virtual;
    procedure render(sl: scanline_ptr); virtual;

  end;

  style_handler_ptr = ^style_handler;

  style_handler = object
    function is_solid(style: unsigned): boolean; virtual; abstract;
    function color(style: unsigned): aggclr_ptr; virtual; abstract;

    procedure generate_span(span: aggclr_ptr; x, y: int; len, style: unsigned); virtual; abstract;

  end;

procedure render_scanline_aa_solid(sl: scanline_ptr; ren: renderer_base_ptr; color: aggclr_ptr);

procedure render_scanlines_aa_solid(ras: rasterizer_scanline_ptr; sl: scanline_ptr;
  ren: renderer_base_ptr; color: aggclr_ptr);

procedure render_scanlines_compound(ras: rasterizer_compound_aa_ptr; sl_aa, sl_bin: scanline_ptr;
  ren: renderer_base_ptr; alloc: span_allocator_ptr; sh: style_handler_ptr);

procedure render_scanlines_compound_layered(ras: rasterizer_compound_aa_ptr; sl_aa: scanline_ptr;
  ren: renderer_base_ptr; alloc: span_allocator_ptr; sh: style_handler_ptr);

implementation

constructor renderer_scanline_aa.Construct;
begin
  m_ren := nil;
  m_span_gen := nil;

end;

{ CONSTRUCT }
constructor renderer_scanline_aa.Construct(ren: renderer_base_ptr; span_gen: span_generator_ptr);
begin
  m_ren := ren;
  m_span_gen := span_gen;

end;

{ ATTACH }
procedure renderer_scanline_aa.attach(ren: renderer_base_ptr; span_gen: span_generator_ptr) ;
begin
  m_ren := ren;
  m_span_gen := span_gen;

end;

{ PREPARE }
procedure renderer_scanline_aa.prepare(u: unsigned);
begin
  m_span_gen^.prepare(u);

end;

{ RENDER }
procedure renderer_scanline_aa.render(sl: scanline_ptr);
var
  y, xmin, xmax, x, len: int;

  num_spans, ss: unsigned;

  span: span_ptr;
  solid: boolean;
  covers: int8u_ptr;

begin
  y := sl^.y;

  m_ren^.first_clip_box;

  repeat
    xmin := m_ren^._xmin;
    xmax := m_ren^._xmax;

    if (y >= m_ren^._ymin) and (y <= m_ren^._ymax) then
    begin
      num_spans := sl^.num_spans;

      span := sl^.begin_;
      ss := sl^.sz_of_span;

      repeat
        x := span^.x;
        len := span^.len;

        solid := False;
        covers := span^.covers;

        if len < 0 then
        begin
          solid := True;
          len := -len;

        end;

        if x < xmin then
        begin
          Dec(len, xmin - x);

          if not solid then
            Inc(ptrcomp(covers), xmin - x);

          x := xmin;

        end;

        if len > 0 then
        begin
          if x + len > xmax then
            len := xmax - x + 1;

          if len > 0 then
            if solid then
              m_ren^.blend_color_hspan_no_clip(
                x, y, len, m_span_gen^.generate(x, y, len), nil, covers^)
            else
              m_ren^.blend_color_hspan_no_clip(
                x, y, len, m_span_gen^.generate(x, y, len), covers, covers^);

        end;

        Dec(num_spans);

        if num_spans = 0 then
          break;

        Inc(ptrcomp(span), ss);

      until False;

    end;

  until not m_ren^.next_clip_box;

end;

{ CONSTRUCT }
constructor renderer_scanline_aa_solid.Construct(ren: renderer_base_ptr);
begin
  m_ren := ren;

  m_color.Construct;

end;

{ COLOR_ }
procedure renderer_scanline_aa_solid.color_(c: aggclr_ptr);
begin
  m_color := c^;

end;

{ PREPARE }
procedure renderer_scanline_aa_solid.prepare(u: unsigned);
begin
end;

{ RENDER }
procedure renderer_scanline_aa_solid.render(sl: scanline_ptr);
var
  x, y: int;

  num_spans, ss: unsigned;

  span_pl: span_ptr;
  span_obj: span_obj_ptr;

begin
  y := sl^.y;

  num_spans := sl^.num_spans;

  span_pl := nil;
  span_obj := nil;

  if sl^.is_plain_span then
  begin
    span_pl := sl^.begin_;
    ss := sl^.sz_of_span;

  end
  else
    span_obj := sl^.begin_;

  if span_pl <> nil then
    repeat
      x := span_pl^.x;

      if span_pl^.len > 0 then
        m_ren^.blend_solid_hspan(x, y, unsigned(span_pl^.len), @m_color, span_pl^.covers)
      else
        m_ren^.blend_hline(x, y, unsigned(x - span_pl^.len - 1), @m_color, span_pl^.covers^);

      Dec(num_spans);

      if num_spans = 0 then
        break;

      Inc(ptrcomp(span_pl), ss);

    until False
  else
    repeat
      x := span_obj^.x;

      if span_obj^.len > 0 then
        m_ren^.blend_solid_hspan(x, y, unsigned(span_obj^.len), @m_color, span_obj^.covers)
      else
        m_ren^.blend_hline(x, y, unsigned(x - span_obj^.len - 1), @m_color, span_obj^.covers^);

      Dec(num_spans);

      if num_spans = 0 then
        break;

      span_obj^.inc_operator;

    until False;

end;

{ CONSTRUCT }
constructor renderer_scanline_bin_solid.Construct(ren: renderer_base_ptr);
begin
  m_ren := ren;

  m_color.Construct;

end;

{ COLOR_ }
procedure renderer_scanline_bin_solid.color_(c: aggclr_ptr);
begin
  m_color := c^;

end;

{ PREPARE }
procedure renderer_scanline_bin_solid.prepare(u: unsigned);
begin
end;

{ RENDER }
procedure renderer_scanline_bin_solid.render(sl: scanline_ptr);
var
  span_pl: span_ptr;
  span_obj: span_obj_ptr;

  num_spans, ss: unsigned;

begin
  num_spans := sl^.num_spans;

  span_pl := nil;
  span_obj := nil;

  if sl^.is_plain_span then
  begin
    span_pl := sl^.begin_;
    ss := sl^.sz_of_span;

  end
  else
    span_obj := sl^.begin_;

  if span_pl <> nil then
    repeat
      if span_pl^.len < 0 then
        m_ren^.blend_hline(
          span_pl^.x, sl^.y,
          span_pl^.x - 1 - span_pl^.len, @m_color, cover_full)
      else
        m_ren^.blend_hline(
          span_pl^.x, sl^.y,
          span_pl^.x - 1 + span_pl^.len, @m_color, cover_full);

      Dec(num_spans);

      if num_spans = 0 then
        break;

      Inc(ptrcomp(span_pl), ss);

    until False
  else
    repeat
      if span_obj^.len < 0 then
        m_ren^.blend_hline(
          span_obj^.x, sl^.y,
          span_obj^.x - 1 - span_obj^.len, @m_color, cover_full)
      else
        m_ren^.blend_hline(
          span_obj^.x, sl^.y,
          span_obj^.x - 1 + span_obj^.len, @m_color, cover_full);

      Dec(num_spans);

      if num_spans = 0 then
        break;

      span_obj^.inc_operator;

    until False;

end;

{ RENDER_SCANLINE_AA_SOLID }
procedure render_scanline_aa_solid(sl: scanline_ptr; ren: renderer_base_ptr; color: aggclr_ptr);
var
  y, x: int;

  num_spans, ss: unsigned;

  span: span_ptr;

begin
  y := sl^.y;
  num_spans := sl^.num_spans;
  span := sl^.begin_;
  ss := sl^.sz_of_span;

  repeat
    x := span^.x;

    if span^.len > 0 then
      ren^.blend_solid_hspan(x, y, unsigned(span^.len), color, span^.covers)
    else
      ren^.blend_hline(x, y, unsigned(x - span^.len - 1), color, span^.covers^);

    Dec(num_spans);

    if num_spans = 0 then
      break;

    Inc(ptrcomp(span), ss);

  until False;

end;

{ RENDER_SCANLINES_AA_SOLID }
procedure render_scanlines_aa_solid(ras: rasterizer_scanline_ptr; sl: scanline_ptr;
  ren: renderer_base_ptr; color: aggclr_ptr);
var
  y, x: int;

  num_spans, ss: unsigned;

  span: span_ptr;

begin
  if ras^.rewind_scanlines then
  begin
    sl^.reset(ras^._min_x, ras^._max_x);

    while ras^.sweep_scanline(sl) do
    begin
      y := sl^.y;
      num_spans := sl^.num_spans;
      ss := sl^.sz_of_span;
      span := sl^.begin_;

      repeat
        x := span^.x;

        if span^.len > 0 then
          ren^.blend_solid_hspan(x, y, unsigned(span^.len), color, span^.covers)
        else
          ren^.blend_hline(x, y, unsigned(x - span^.len - 1), color, span^.covers^);

        Dec(num_spans);

        if num_spans = 0 then
          break;

        Inc(ptrcomp(span), ss);

      until False;

    end;

  end;

end;

{ RENDER_SCANLINES_COMPOUND }
procedure render_scanlines_compound(ras: rasterizer_compound_aa_ptr; sl_aa, sl_bin: scanline_ptr;
  ren: renderer_base_ptr; alloc: span_allocator_ptr; sh: style_handler_ptr);
var
  min_x, len: int;

  num_spans, num_styles, style, i, ss_aa, ss_bin: unsigned;

  color_span, mix_buffer, colors, cspan: aggclr_ptr;

  c: aggclr;

  solid: boolean;

  span_aa: span_ptr;
  span_bin: span_bin_ptr;
  covers: int8u_ptr;

begin
  if ras^.rewind_scanlines then
  begin
    min_x := ras^.min_x;
    len := ras^.max_x - min_x + 2;

    sl_aa^.reset(min_x, ras^.max_x);
    sl_bin^.reset(min_x, ras^.max_x);

    color_span := alloc^.allocate(len * 2);
    mix_buffer := aggclr_ptr(ptrcomp(color_span) + len * sizeof(aggclr));

    num_styles := ras^.sweep_styles;

    while num_styles > 0 do
    begin
      if num_styles = 1 then
        // Optimization for a single style. Happens often
        if ras^.sweep_scanline(sl_aa, 0) then
        begin
          style := ras^.style(0);

          if sh^.is_solid(style) then
            // Just solid fill
            render_scanline_aa_solid(sl_aa, ren, sh^.color(style))

          else
          begin
            // Arbitrary span generator
            span_aa := sl_aa^.begin_;
            ss_aa := sl_aa^.sz_of_span;
            num_spans := sl_aa^.num_spans;

            repeat
              len := span_aa^.len;

              sh^.generate_span(color_span, span_aa^.x, sl_aa^.y, len, style);
              ren^.blend_color_hspan(span_aa^.x, sl_aa^.y, span_aa^.len, color_span, span_aa^.covers);

              Dec(num_spans);

              if num_spans = 0 then
                break;

              Inc(ptrcomp(span_aa), ss_aa);

            until False;

          end;

        end
        else
      else // if num_styles = 1 ... else
      if ras^.sweep_scanline(sl_bin, -1) then
      begin
        // Clear the spans of the mix_buffer
        span_bin := sl_bin^.begin_;
        ss_bin := sl_bin^.sz_of_span;
        num_spans := sl_bin^.num_spans;

        repeat
          FillChar(
            aggclr_ptr(ptrcomp(mix_buffer) + (span_bin^.x - min_x) * sizeof(aggclr))^,
            span_bin^.len * sizeof(aggclr), 0);

          Dec(num_spans);

          if num_spans = 0 then
            break;

          Inc(ptrcomp(span_bin), ss_bin);

        until False;

        i := 0;

        while i < num_styles do
        begin
          style := ras^.style(i);
          solid := sh^.is_solid(style);

          if ras^.sweep_scanline(sl_aa, i) then
          begin
            span_aa := sl_aa^.begin_;
            ss_aa := sl_aa^.sz_of_span;
            num_spans := sl_aa^.num_spans;

            if solid then
              // Just solid fill
              repeat
                c := sh^.color(style)^;
                len := span_aa^.len;

                colors := aggclr_ptr(ptrcomp(mix_buffer) + (span_aa^.x - min_x) * sizeof(aggclr));
                covers := span_aa^.covers;

                repeat
                  if covers^ = cover_full then
                    colors^ := c
                  else
                    colors^.add(@c, covers^);

                  Inc(ptrcomp(colors), sizeof(aggclr));
                  Inc(ptrcomp(covers), sizeof(int8u));
                  Dec(len);

                until len = 0;

                Dec(num_spans);

                if num_spans = 0 then
                  break;

                Inc(ptrcomp(span_aa), ss_aa);

              until False
            else
              // Arbitrary span generator
              repeat
                len := span_aa^.len;
                colors := aggclr_ptr(ptrcomp(mix_buffer) + (span_aa^.x - min_x) * sizeof(aggclr));
                cspan := color_span;

                sh^.generate_span(cspan, span_aa^.x, sl_aa^.y, len, style);

                covers := span_aa^.covers;

                repeat
                  if covers^ = cover_full then
                    colors^ := cspan^
                  else
                    colors^.add(cspan, covers^);

                  Inc(ptrcomp(cspan), sizeof(aggclr));
                  Inc(ptrcomp(colors), sizeof(aggclr));
                  Inc(ptrcomp(covers), sizeof(int8u));
                  Dec(len);

                until len = 0;

                Dec(num_spans);

                if num_spans = 0 then
                  break;

                Inc(ptrcomp(span_aa), ss_aa);

              until False;

          end;

          Inc(i);

        end;

        // Emit the blended result as a color hspan
        span_bin := sl_bin^.begin_;
        ss_bin := sl_bin^.sz_of_span;
        num_spans := sl_bin^.num_spans;

        repeat
          ren^.blend_color_hspan(
            span_bin^.x, sl_bin^.y, span_bin^.len,
            aggclr_ptr(ptrcomp(mix_buffer) + (span_bin^.x - min_x) * sizeof(aggclr)), nil, cover_full);

          Dec(num_spans);

          if num_spans = 0 then
            break;

          Inc(ptrcomp(span_bin), ss_bin);

        until False;

      end; // if ras^.sweep_scanline(sl_bin ,-1 )

      num_styles := ras^.sweep_styles;

    end; // while num_styles > 0

  end; // if ras^.rewind_scanlines

end;

{ RENDER_SCANLINES_COMPOUND_LAYERED }
procedure render_scanlines_compound_layered(ras: rasterizer_compound_aa_ptr; sl_aa: scanline_ptr;
  ren: renderer_base_ptr; alloc: span_allocator_ptr; sh: style_handler_ptr);
var
  min_x, len, sl_start, sl_y: int;

  num_spans, num_styles, style, ss_aa, sl_len, i, cover: unsigned;

  color_span, mix_buffer, colors, cspan: aggclr_ptr;

  solid: boolean;

  c: aggclr;

  cover_buffer, src_covers, dst_covers: cover_type_ptr;

  span_aa: span_ptr;

begin
  if ras^.rewind_scanlines then
  begin
    min_x := ras^.min_x;
    len := ras^.max_x - min_x + 2;

    sl_aa^.reset(min_x, ras^.max_x);

    color_span := alloc^.allocate(len * 2);
    mix_buffer := aggclr_ptr(ptrcomp(color_span) + len * sizeof(aggclr));
    cover_buffer := ras^.allocate_cover_buffer(len);

    num_styles := ras^.sweep_styles;

    while num_styles > 0 do
    begin
      if num_styles = 1 then
        // Optimization for a single style. Happens often
        if ras^.sweep_scanline(sl_aa, 0) then
        begin
          style := ras^.style(0);

          if sh^.is_solid(style) then
            // Just solid fill
            render_scanline_aa_solid(sl_aa, ren, sh^.color(style))

          else
          begin
            // Arbitrary span generator
            span_aa := sl_aa^.begin_;
            num_spans := sl_aa^.num_spans;
            ss_aa := sl_aa^.sz_of_span;

            repeat
              len := span_aa^.len;

              sh^.generate_span(color_span, span_aa^.x, sl_aa^.y, len, style);
              ren^.blend_color_hspan(span_aa^.x, sl_aa^.y, span_aa^.len, color_span, span_aa^.covers);

              Dec(num_spans);

              if num_spans = 0 then
                break;

              Inc(ptrcomp(span_aa), ss_aa);

            until False;

          end;

        end
        else
      else
      begin
        sl_start := ras^.scanline_start;
        sl_len := ras^.scanline_length;

        if sl_len <> 0 then
        begin
          FillChar(
            aggclr_ptr(ptrcomp(mix_buffer) + (sl_start - min_x) * sizeof(aggclr))^,
            sl_len * sizeof(aggclr), 0);

          FillChar(
            cover_type_ptr(ptrcomp(cover_buffer) + (sl_start - min_x) * sizeof(cover_type))^,
            sl_len * sizeof(cover_type), 0);

          sl_y := $7FFFFFFF;

          i := 0;

          while i < num_styles do
          begin
            style := ras^.style(i);
            solid := sh^.is_solid(style);

            if ras^.sweep_scanline(sl_aa, i) then
            begin
              span_aa := sl_aa^.begin_;
              num_spans := sl_aa^.num_spans;
              sl_y := sl_aa^.y;
              ss_aa := sl_aa^.sz_of_span;

              if solid then
                // Just solid fill
                repeat
                  c.Construct(sh^.color(style));

                  len := span_aa^.len;
                  colors := aggclr_ptr(ptrcomp(mix_buffer) + (span_aa^.x - min_x) * sizeof(aggclr));

                  src_covers := cover_type_ptr(span_aa^.covers);
                  dst_covers := cover_type_ptr(ptrcomp(cover_buffer) + (span_aa^.x - min_x) * sizeof(cover_type));

                  repeat
                    cover := src_covers^;

                    if dst_covers^ + cover > cover_full then
                      cover := cover_full - dst_covers^;

                    if cover <> 0 then
                    begin
                      colors^.add(@c, cover);

                      dst_covers^ := dst_covers^ + cover;

                    end;

                    Inc(ptrcomp(colors), sizeof(aggclr));
                    Inc(ptrcomp(src_covers), sizeof(cover_type));
                    Inc(ptrcomp(dst_covers), sizeof(cover_type));
                    Dec(len);

                  until len = 0;

                  Dec(num_spans);

                  if num_spans = 0 then
                    break;

                  Inc(ptrcomp(span_aa), ss_aa);

                until False
              else
                // Arbitrary span generator
                repeat
                  len := span_aa^.len;
                  colors := aggclr_ptr(ptrcomp(mix_buffer) + (span_aa^.x - min_x) * sizeof(aggclr));
                  cspan := color_span;

                  sh^.generate_span(cspan, span_aa^.x, sl_aa^.y, len, style);

                  src_covers := cover_type_ptr(span_aa^.covers);
                  dst_covers := cover_type_ptr(ptrcomp(cover_buffer) + (span_aa^.x - min_x) * sizeof(cover_type));

                  repeat
                    cover := src_covers^;

                    if dst_covers^ + cover > cover_full then
                      cover := cover_full - dst_covers^;

                    if cover <> 0 then
                    begin
                      colors^.add(cspan, cover);

                      dst_covers^ := dst_covers^ + cover;

                    end;

                    Inc(ptrcomp(cspan), sizeof(aggclr));
                    Inc(ptrcomp(colors), sizeof(aggclr));
                    Inc(ptrcomp(src_covers), sizeof(cover_type));
                    Inc(ptrcomp(dst_covers), sizeof(cover_type));
                    Dec(len);

                  until len = 0;

                  Dec(num_spans);

                  if num_spans = 0 then
                    break;

                  Inc(ptrcomp(span_aa), ss_aa);

                until False;

            end;

            Inc(i);

          end;

          ren^.blend_color_hspan(
            sl_start, sl_y, sl_len,
            aggclr_ptr(ptrcomp(mix_buffer) + (sl_start - min_x) * sizeof(aggclr)),
            nil, cover_full);

        end; // if sl_len <> 0

      end; // if num_styles = 1 ... else

      num_styles := ras^.sweep_styles;

    end; // while num_styles > 0

  end; // if ras^.rewind_scanlines

end;

end.

