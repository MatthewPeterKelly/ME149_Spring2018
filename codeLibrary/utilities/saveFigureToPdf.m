function saveFigureToPdf(fileName, hFig)
% saveFigureToPdf(fileName, hFig)
%
% This function saves a figure to a pdf file
%
% INPUTS:
%   fileName = string = save the figure under this file name
%   hFig = figure handle = optional  (default:  gcf)
% 

if nargin < 2
    hFig = gcf;
end

hFig.PaperPositionMode = 'auto';
pos = hFig.PaperPosition;
hFig.PaperSize = [pos(3), pos(4)];
print(hFig, fileName,'-dpdf')

end

