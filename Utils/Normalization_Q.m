function [ Q_new ] = Normalization_Q( Q )
%����Ԫ������Q���й淶��

if(size(Q) ~= 4)
    error('Input Error! In function Normalization_Q.');
end

length = sqrt(Q(1)^2 + Q(2)^2 + Q(3)^2 + Q(4)^2);
Q_new = Q./length;
end
