## SPDX-License-Identifier: BSD-2-Clause

function ok = svt_check_coverage (rows, expected_rows)
  ## Reject missing and duplicate measured rows before a profile is complete.
  ok = iscell (rows) && numel (rows) == expected_rows;
  if (! ok), return; endif
  keys = cell (numel (rows), 1);
  for index = 1:numel (rows)
    row = rows{index};
    required = {"case_id", "mode", "native", "work_bits", "status"};
    if (! isstruct (row) || any (! cellfun (@(name) isfield (row, name), required)))
      ok = false;
      return;
    endif
    keys{index} = sprintf ("%s|%s|%d|%d", row.case_id, row.mode, ...
                           row.native, row.work_bits);
  endfor
  ok = numel (unique (keys)) == expected_rows;
endfunction
