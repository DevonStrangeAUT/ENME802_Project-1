function [] = display_structure(~,ncon,X,Y,U,F,dzero)
% DISPLAY_STRUCTURE - Cleaner ANSYS-style undeformed/deformed mesh plot
figure('Color','w','Name','Structure View'); clf;
ax = axes; hold(ax,'on'); axis(ax,'equal'); box(ax,'on'); grid(ax,'on');

% Auto scale deformation
umag = sqrt(U(1:2:end).^2 + U(2:2:end).^2);
L = max(max(X)-min(X), max(Y)-min(Y));
scale = 0.08*L/max(max(umag),eps);

Xd = X + scale*U(1:2:end);
Yd = Y + scale*U(2:2:end);

% Undeformed mesh (light gray)
patch(ax,'Faces',ncon,'Vertices',[X Y], ...
    'FaceColor','none','EdgeColor',[0.75 0.75 0.75], ...
    'LineStyle','-','LineWidth',0.5);

% Deformed mesh colored by displacement magnitude
patch(ax,'Faces',ncon,'Vertices',[Xd Yd], ...
    'FaceVertexCData',umag,'FaceColor','interp', ...
    'EdgeColor',[0.35 0.35 0.35],'LineWidth',0.6);
colormap(ax,jet); colorbar(ax);

% Applied forces (only nonzero)
fnorm = max(abs(F)); if fnorm==0, fnorm = 1; end
arrowScale = 0.06*L/fnorm;
for i = 1:length(X)
    Fx = F(2*i-1); Fy = F(2*i);
    if abs(Fx)>0 || abs(Fy)>0
        quiver(ax,X(i),Y(i),Fx,Fy,arrowScale,'b','LineWidth',1.6,'MaxHeadSize',1.8);
    end
end

% Fixed supports
fixed_nodes = unique(ceil(dzero/2));
plot(ax,X(fixed_nodes),Y(fixed_nodes),'ks','MarkerFaceColor','y','MarkerSize',6);

xlabel(ax,'X (m)'); ylabel(ax,'Y (m)');
title(ax,sprintf('Deformed Shape (Scale = %.1fx)',scale));
legend(ax,{'Undeformed Mesh','Deformed Mesh','Applied Load','Fixed Support'}, ...
    'Location','bestoutside');
set(ax,'FontSize',11,'LineWidth',1);
padding = 0.05*L;
xlim([min([X;Xd])-padding, max([X;Xd])+padding]);
ylim([min([Y;Yd])-padding, max([Y;Yd])+padding]);
end