function [ M_new ] = Normalization( M, major )
%�Ծ���M���У�major = 1�����У�major = 2��ִ�������淶��

if(major == 1)
    M_new = M./repmat(sqrt(sum(M.^2,2)),[1,3]);
elseif(major == 2)
    M_new = M./repmat(sqrt(sum(M.^2)),[3,1]);
else
    error('Input Error! In function Normalization.');
end
end
