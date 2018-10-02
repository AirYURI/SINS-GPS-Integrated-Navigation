function [ M_new ] = Orthogonalization_Schmidt( M )
%ʹ��ʩ������������Schmidt orthogonalization��������3�׷���M�任Ϊ��������

if(sum(size(M) == [3 3],2) ~= 2)
    error('Input Error! In function Orthogonalization_Schmidt.');
end

M(:,2) = M(:,2) - ((M(:,2)'*M(:,1))/(M(:,1)'*M(:,1))).*M(:,1);
M(:,3) = M(:,3) - ((M(:,3)'*M(:,1))/(M(:,1)'*M(:,1))).*M(:,1) - ((M(:,3)'*M(:,2))/(M(:,2)'*M(:,2))).*M(:,2);

M_new = Normalization(M,2);
end
