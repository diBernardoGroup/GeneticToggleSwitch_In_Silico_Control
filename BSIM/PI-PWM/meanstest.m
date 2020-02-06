[ind1, val]=find((tvec-240)>0,1,'first');
    
% for k=1801:-1:ind1
% 
%     [ind, val]=find((tvec(k)-tvec)>240,1,'last');
%     mwLacI(k-ind1+1)=trapz(tvec(ind:k),TargetCell.LacI(ind:k))/(tvec(k)-tvec(ind));
%     mwTetR(k-ind1+1)=trapz(tvec(ind:k),TargetCell.TetR(ind:k))/(tvec(k)-tvec(ind));
% end

    for k=48:length(tvec)
    mwTetR(k-47)=trapz(tvec(k-47:k),avg_Tet(k-47:k))/(tvec(k)-tvec(k-47));
    mwLacI(k-47)=trapz(tvec(k-47:k),avg_Lac(k-47:k))/(tvec(k)-tvec(k-47));
    end