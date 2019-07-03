function [x_bar, y_bar, As] = xycentroid(x,y)
%Function calculates centroid and area of a list of xy points
%SCd 11/24/2010
%
%
%Input Arguments:
%   -x: vector of x coordinates (can be row or column vector)
%   -y: vector of y coordinates (can be row or column vector)
%
%Output Arguments:
%   -x_bar: x location of centroid
%   -y_bar: y location of centroid
%   -A: area of polygon
%
      %Error checking:
      assert(nargin==2,'This function expects 2 and only 2 input arguments');
      assert(all(size(x(:))==size(y(:))),'Input arguments: x & y are expected to be the same length');
      x = x(:);
      y = y(:);
      %Engine:
      A = x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1);
      As = sum(A)/2;
      x_bar = (sum((x(2:end)+x(1:end-1)).*A)*1/6)/As;
      y_bar = (sum((y(2:end)+y(1:end-1)).*A)*1/6)/As;
end