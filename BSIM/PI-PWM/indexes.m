err_LacI=mwLacI-750;
err_TetR=mwTetR-300;
err_LacI_n=err_LacI/750;
err_TetR_n=err_TetR/300;
err_vett_n=[err_LacI_n; err_TetR_n];
for no=1:length(err_vett_n)
norm_err(no)=norm(err_vett_n(:,no));
end
err_norm_square=norm_err.^2;
ISE_norm=trapz(tvec(48:end), err_norm_square)
IAE_norm=trapz(tvec(48:end), norm_err)
ITAE_norm=trapz(tvec(48:end), tvec(48:end)'.*norm_err)
ISE_norm_6_18=trapz(tvec(288:end), err_norm_square(241:end))
IAE_norm_6_18=trapz(tvec(288:end), norm_err(241:end))
ITAE_norm_6_18=trapz(tvec(288:end), tvec(288:end)'.*norm_err(241:end))