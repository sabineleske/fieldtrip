function varargout = delayedexit(varargin)

% DELAYEDEXIT schedules a timer that will exit Matlab after a specified time.
% The timer runs in a seperate thread and will call the exit function
% regardless ow whether Matlab is busy or not.
%
% Examples
%   delayedexit(180);   % this will cause Matlab to exit in 180 seconds
%   delayedexit;        % show the remaining time to the delayed exit
%   t = delayedexit;    % return the remaining time to the delayed exit
%   clear delayedexit;  % to cancel the previous delayed exit
%
% Note that the timer will also be canceled if you do "clear all".

% -----------------------------------------------------------------------
% Copyright (C) 2010, Robert Oostenveld
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/
% -----------------------------------------------------------------------

% try to compile the missing mex file on the fly

% remember the original working directory
pwdir = pwd;

% determine the name and full path of this function
funname = mfilename('fullpath');
[p, f, x] = fileparts(funname);
mexsrc = fullfile(p, 'src', [f '.c']);
mexdir = fileparts(funname);

try
  % try to compile the mex file on the fly
  warning('trying to compile MEX file from %s', mexsrc);
  cd(mexdir);
  mex(mexsrc);
  cd(pwdir);
  success = true;

catch
  % compilation failed
  disp(lasterr);
  error('could not locate MEX file for %s', mfilename);
  cd(pwdir);
  success = false;
end

if success
  % execute the mex file that was juist created
  funname   = mfilename;
  funhandle = str2func(funname);
  [varargout{1:nargout}] = funhandle(varargin{:});
end

