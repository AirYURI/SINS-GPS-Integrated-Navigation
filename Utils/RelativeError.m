function [ err ] = RelativeError( S_0, S )
%�ɾ�ֵS_0����ֵS����������仯�ʣ��ľ���ֵerr

err = abs(S - S_0)/S_0;
end
