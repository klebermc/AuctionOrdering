%load('experiment_1.mat')

plot(graphs{85},'XData',positions{85}(1,:),'YData',positions{85}(2,:), 'Linewidth', 2.0, 'MarkerSize', 10, 'NodeFontSize', 16);
xlabel('Pos X_I [m]');
ylabel('Pos Y_I [m]');
grid on;
axis equal;

ax=gca;
ax.FontSize=16;