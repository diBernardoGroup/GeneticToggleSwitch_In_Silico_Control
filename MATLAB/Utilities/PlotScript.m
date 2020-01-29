%% Summary Figure
if settings.plot.complete
    figure()
    subplot(6,1,1:3)
    hold on
    for ind=1:settings.numcells
        h=plot(tvec/settings.period, othercells(ind).LacI, 'r');
        h.Color(4)=0.2;
    end
    j=plot(tvec/settings.period,TargetCell.LacI,'Color', 'r','LineWidth',2);
    hold off
    clear ind h%Not Needed Anymore
    line(xlim,[controller.setpoint.ref(1) controller.setpoint.ref(1)],'Color','r', 'LineStyle','- -')
    hold on
    for ind=1:settings.numcells
        h=plot(tvec/settings.period, othercells(ind).TetR, 'g');
        h.Color(4)=0.2;
    end
    k=plot(tvec/settings.period,TargetCell.TetR,'Color', [0 153/255 51/255],'LineWidth',2);
    hold off
    clear ind h%Not Needed Anymore
    ylabel({'LacI-TetR'},'fontsize',12)
    xlim([0 tvec(end)/settings.period])
    line(xlim,[controller.setpoint.ref(2) controller.setpoint.ref(2)],'Color','g', 'LineStyle','-.')
    subplot(6,1,4)
    xlim([0 tvec(end)/settings.period])
    ylim([0 1])
    [iptg_area_X, iptg_area_Y] = stairs(tvec/settings.period,inputs.iptg);
    h = area(iptg_area_X, iptg_area_Y, 0);
    set(h, 'EdgeColor', [0 0 1], 'FaceAlpha',.4, 'EdgeAlpha', .4)
    set(gca,'Box','off');
    ylabel('IPTG','fontsize',12)
    xlim([0 tvec(end)/settings.period])
    hold on
    plot(tvec/settings.period,TargetCell.iptg_del, 'b', 'LineWidth', 3)
    hold off
    subplot(6,1,5)
    xlim([0 tvec(end)/settings.period])
    ylim([0 100])
    [atc_area_X, atc_area_Y] = stairs(tvec/settings.period,inputs.atc);
    h = area(atc_area_X, atc_area_Y, 0);
    set(h, 'FaceColor', [255 53 0]/255, 'EdgeColor', [255 53 0]/255, 'FaceAlpha',.4, 'EdgeAlpha', .4);
    set(gca,'Box','off');
    xlim([0 tvec(end)/settings.period])
    ylabel('aTc','fontsize',12)
    hold on
    plot(tvec/settings.period,TargetCell.atc_del, 'Color', [255 53 0]/255, 'LineWidth', 3)
    hold off
    subplot(6,1,6)
    if(strcmp(settings.sim_method,'ODE'))
        stairs([0:settings.nperiod], [controller.DutyC controller.DutyC(end)], 'LineWidth', 2)
    else
        stairs(tvec/settings.period, [controller.DutyC(2:end) controller.DutyC(end) ], 'LineWidth', 2)
    end
    if exist('controller.Dref', 'var')
    hold on
    line([0 tvec(end)]/settings.period,[controller.Dref controller.Dref],'Color','r', 'LineStyle','-.')
    hold off
    end
    xlabel('Time [periods]','fontsize',12)
    ylabel('Duty-Cycle','fontsize',12)
    ylim([-0.05 1.05]);
    xlim([0 tvec(end)/settings.period])
    set(gcf,'color','w')
    set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',20);
end

