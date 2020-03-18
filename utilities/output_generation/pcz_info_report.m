function [ret] = pcz_info_report(bool, varargin)
%% pcz_info_report
%  
%  File: pcz_info_report.m
%  Directory: 2_demonstrations/lib/matlab
%  Author: Peter Polcz (ppolcz@gmail.com) 
%  
%  Created on 2018. April 30.
%

%%

global SCOPE_DEPTH VERBOSE

% Find link to the caller code
% s = dbstack;
% link = '';
% stack_depth = 2;
% if numel(s) >= stack_depth
%     line = num2str(s(stack_depth).line);
%     file = s(stack_depth).file;
%     
%     filepath = which(file);
%     
%     cmd_line = [ 'opentoline(''' filepath ''',' line ')' ];
%     link = [ pcz_dispHRefMatlab([ file ':' line ], cmd_line) ' '];
% end

% Append GOTO link to the first parameter after the bool
% if numel(varargin) > 1 && ischar(varargin{1})
%     varargin{1} = [link varargin{1}];
% else
%     varargin{1} = link;
% end

if nargin == 1 && iscell(bool)
    varargin = bool(2:end);
    bool = bool{1};
end

opts.first = 1;
opts.last = 0;

if nargin > 1 && iscell(varargin{end})
    args = varargin{end};
    varargin = varargin(1:end-1);
    opts = parsepropval(opts,args{:});
end

% S = dbstack;
% S.name

depth = SCOPE_DEPTH;

if VERBOSE

    prefix = '';
    if depth >= 1
        tab = '│   ';
        prefix = repmat(tab,[1 depth]);
    end
    
    disp([ prefix ' '])

    fprintf(prefix)
    pcz_OK_FAILED(bool, varargin{:});
    fprintf('\n')

    pcz_dispFunctionStackTrace('', 'first', opts.first, 'last', opts.last)
    
    % pcz_dispFunction('Depth = %d', SCOPE_DEPTH)
    
    % disp([prefix '- ' link])
end

if nargout > 0
    if islogical(bool)
        ret = ~bool;
    else
        ret = [];
    end
end
    
% cprintf('_green', 'underlined green');

% web('text://<html><h1>Hello World</h1></html>')

end