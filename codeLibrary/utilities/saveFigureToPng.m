function saveFigureToPng(fileName, hFig, resolution)
% saveFigureToPng(fileName, hFig, resolution)
%
% This function saves a figure to a png image file
%
% INPUTS:
%   fileName = string = save the figure under this file name
%       - extension is optional (and overridden if not .png)
%   hFig = figure handle = optional  (default:  gcf)
%   resolution = integer = dpi  (default: 150 dpi)

if nargin < 2
    hFig = gcf;
end
if nargin < 3
   resolution = 150; 
end


% Strip extension from file name
[~, fileName] = fileparts(fileName);

% Configure the figure to save in the correct format
hFig.PaperPositionMode = 'auto';
pos = hFig.PaperPosition;
hFig.PaperSize = [pos(3), pos(4)];

% Save to file
print(hFig, [fileName, '.png'],'-dpng', ['-r', num2str(resolution)]);

end

