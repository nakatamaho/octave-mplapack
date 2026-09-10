% Make the optional NEIG spectrum visualization.
function nes_plot (results, output_path)
  if (nargin != 2 || ! isstruct (results) || ! ischar (output_path))
    error ("NEIG:PlotArguments", "nes_plot expects results and an output path");
  endif
  if (exist (output_path, "file"))
    error ("NEIG:PlotExists", "refusing to overwrite plot: %s", output_path);
  endif
  figure ("visible", "off");
  unwind_protect
    hold on;
    legend_entries = {};
    for k = 1:numel (results.rows)
      row = results.rows(k);
      if (isempty (row.computed_values))
        continue;
      endif
      % This is a presentation-only conversion.  Solver and metric paths
      % retain MP values; the plot is explicitly labeled as visualization.
      values = double (row.computed_values);
      plot (real (values), imag (values), ".", "markersize", 12);
      legend_entries{end + 1} = sprintf ("%s/%s/%s/%db", ...
                                         row.family, row.representation, ...
                                         row.mode, row.work_bits);
    endfor
    xlabel ("real(lambda) [visualization]");
    ylabel ("imag(lambda) [visualization]");
    title (sprintf ("NEIG %s spectrum (display conversion only)", results.profile));
    grid on;
    if (! isempty (legend_entries))
      legend (legend_entries, "location", "eastoutside");
    endif
    print (output_path, "-dpng");
  unwind_protect_cleanup
    close;
  end_unwind_protect
endfunction
