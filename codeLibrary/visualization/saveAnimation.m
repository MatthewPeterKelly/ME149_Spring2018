function saveAnimation(t,x,P)
%saveAnimation(t,x,P)
%
%FUNCTION:
%   saveAnimation creates a mp4 video file, given data and a draw function.
%
%INPUTS:
%   t = [1xM] vector of times, Must be monotonic: t(k) < t(k+1)
%   x = [NxM] matrix of states, corresponding to times in t
%   P = animation parameter struct, with fields:
%     .plotFunc = @(t,x) = function handle to create a plot
%       	t = a scalar time
%       	x = [Nx1] state vector
%     .figNum = (optional) figure number for plotting. Default = 1000.
%     .frameRate = desired frame rate for the animation (real time)
%     .fileName = desired file name (do not include extension)
%
%OUTPUTS:
%   Animation file based on data in t and x.
%
%NOTES:
%
%   The animation works by looping through every element in the input
%   matricies, assuming that they are being presented at the desired frame
%   rate.
%

if ~isfield(P,'figNum')
    P.figNum=1000;  %Default to figure 1000
end

h = figure(P.figNum);

% Set up stuff for writing animation to file:
vidObj = VideoWriter([P.fileName, '.mp4'],'MPEG-4');   %This doesn't work on Linux   :-(   windows only
vidObj.Quality = 100;
open(vidObj);
for i=1:length(t)
    
    %Update the figure:
    feval(P.plotFunc,t(i),x(:,i));
    drawnow;
    pause(0.005);
    
    % Save the frame:
    writeVideo(vidObj,getframe(h));
    
end

close(vidObj);

end %animate.m
