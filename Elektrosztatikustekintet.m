% Coded by: Beszedes Mark, J. Csanad and Z. Aron
function elektro_vizualizer_2000
    fig = uifigure('Name', 'Elektrosztatikus Tér Szimulátor','Position', [200 200 1000 620]);
    
    % toltesek: [x y q] matrix
    toltesek = zeros(0, 3);  
    
    uilabel(fig, 'Text', 'Töltések listája:', 'Position', [20 580 150 22]);
    lst = uilistbox(fig, 'Position', [20 280 240 290]);
    
    uilabel(fig, 'Text', 'x koordináta:',  'Position', [20 240 100 22]);
    inX = uieditfield(fig, 'numeric', 'Position', [120 240 60 22], 'Value', 0, 'Limits', [-10 10]);
    
    uilabel(fig, 'Text', 'y koordináta:',  'Position', [20 200 100 22]);
    inY = uieditfield(fig, 'numeric', 'Position', [120 200 60 22], 'Value', 0, 'Limits', [-10 10]);
    
    uilabel(fig, 'Text', 'q Töltés (nC):', 'Position', [20 160 100 22]);
    inQ = uieditfield(fig, 'numeric', 'Position', [120 160 60 22], 'Value', 1);
    
    uibutton(fig, 'Text', 'Hozzáadás', 'Position', [20 110 110 35], 'ButtonPushedFcn', @addCharge);
    uibutton(fig, 'Text', 'Törlés', 'Position', [140 110 110 35], 'ButtonPushedFcn', @removeCharge);
    
    uilabel(fig, 'Text', 'Vektor sűrűség:', 'Position', [20 70 100 22]);
    csuszq = uislider(fig, 'Position', [130 72 130 3], 'Limits', [0.1 2], 'Value', 1, 'ValueChangedFcn', @frissitGrafikon);

    ax = uiaxes(fig, 'Position', [350 40 560 560]);
    title(ax, 'Elektrosztatikus Térerősség és Potenciál');
    grid(ax, 'on');
    axis(ax, 'equal');
    
    % toltes lista (felsorolas) megjelenitese
    function refreshLista()
        if isempty(toltesek)
            lst.Items = {}; return;
        end
        items = cell(size(toltesek,1),1);
        for i = 1:size(toltesek,1)
            items{i} = sprintf('ID:%d | x:%.1f y:%.1f | q:%+.1f nC', i, toltesek(i,1), toltesek(i,2), toltesek(i,3));
        end
        lst.Items = items;
    end

    function frissitGrafikon(~, ~)
        cla(ax);
        if isempty(toltesek)
            return;
        end
        
        % Racs kirajzolasa
        [X, Y] = meshgrid(linspace(-10,10,60), linspace(-10,10,60));
        Ex = zeros(size(X)); % tererosseg x komponense
        Ey = zeros(size(X)); % tererosseg y komponense
        V = zeros(size(X));  % potencial
        
        k = 8.99; % Coulomb-allando
        
        % minden racspont
        for i = 1:size(toltesek,1)
            dx = X - toltesek(i,1); % tavolsag vektor komponenseinek tavolsaga a toltestol
            dy = Y - toltesek(i,2);
            r = dx.^2 + dy.^2 + 0.1; 
            
            % Tererosseg komponensek:
            E_mag = k * toltesek(i,3) ./ r;
            Ex = Ex + E_mag .* (dx ./ sqrt(r));
            Ey = Ey + E_mag .* (dy ./ sqrt(r));
            
            % Potencial a hatternek
            V = V + k * toltesek(i,3) ./ sqrt(r);
        end

        hold(ax, 'on');
        
        % Potencialter abrazolasa V alapjan (Heatmap)
        contourf(ax, X, Y, V, 15, 'LineStyle', 'none');
        try colormap(ax, 'jet'); catch; end 
        
        % Vektorok abrazolasa
        quiver(ax, X, Y, Ex, Ey, csuszq.Value, 'Color', [1 1 1], 'LineWidth', 1);

        % Toltesek pontjai
        for i = 1:size(toltesek,1)
            szin = 'r'; 
            if toltesek(i,3) < 0, szin = 'b'; end
            plot(ax, toltesek(i,1), toltesek(i,2), 'o', 'MarkerSize', 12, 'MarkerFaceColor', szin, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        end
        
        axis(ax, [-10 10 -10 10]);
        hold(ax, 'off');
    end

    function addCharge(~, ~)
        toltesek = [toltesek; inX.Value, inY.Value, inQ.Value];
        refreshLista();
        inX.Value = 0; 
        inY.Value = 0; 
        inQ.Value = 1;
        frissitGrafikon();

    end

    function removeCharge(~, ~)
        val = lst.Value;
        if isempty(val), return; end
        
        idx_str = regexp(val, 'ID:(\d+)', 'tokens');
        if ~isempty(idx_str)
            idx = str2double(idx_str{1}{1});
            toltesek(idx, :) = [];
            refreshLista();
            frissitGrafikon();
        end
    end

    frissitGrafikon();
end
