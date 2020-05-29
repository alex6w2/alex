function showVariogram(givenDataSet)

% Visualisiert die mittleren Semivarianz in einzelnen Entfernungsschritten

% Input-Argumente:  givenDataSet:       struct-Variable mit drei Eintr?gen
%                                       f?r x-Position, y-Position und 
%                                       Werten f?r den jeweiligen Punkt (z)
%
% Output:           Plot der mittleren Semivarianz in einzelnen 
%                   Entfernungsschritten


    %Punktepaare
    pointCoordinates = horzcat(givenDataSet.x, givenDataSet.y);
    [Z1,Z2] = meshgrid(givenDataSet.z);

    % Abst?nde zwischen den Punkten
%     % Euklid
%     distances = squareform(pdist(pointCoordinates, 'euclidean'));

    % sph?risch
    pointCoordinatesRad = deg2rad(pointCoordinates);
    
    [lat1,lat2] = meshgrid(pointCoordinatesRad(:,1));
    [lon1,lon2] = meshgrid(pointCoordinatesRad(:,2));
    
    r = 6378.388;
    distances = r .* abs(acos(sin(lat1) .* sin(lat2) + ...
        cos(lat1) .* cos(lat2) .* cos(lon2 - lon1)));

    % Semivarianz von Punktepaaren der beobachteten variable z
    semivariance = 0.5*(Z1 - Z2).^2;

    % min lag-interval bestimmen - minimale distanz zwischen allen Punkten
    % (gemittelt) 
    distance_NaN = distances.*(diag(givenDataSet.x*NaN)+1);
    minLag = mean(min(distance_NaN));

    % max lag Interval bestimmen - H?lfte des Maximums
    halfMaxDistance = max(distances(:)) / 2;

    % Anzahl der lags
    numberLags = floor(halfMaxDistance / minLag);

    % Einteilung der Punktentfernungen in Klassen
    LAGS = ceil(distances / minLag); 

    % SEL: Matrix, die sich mir jedem Durchlauf ?ndert und jeweils die
    % passenden Eintr?ge in LAGS 1 setzt 
    % DE: Mittlere LAG Entfernung - durch 2, da symmetrische Distanzmatrix
    % GE: Mittlerer Semivarianz pro LAG 
    for i = 1 : numberLags
        SEL = (LAGS == i);
        DE1(i) = mean(mean(distances(SEL)));
        PN1(i) = sum(sum(SEL == 1))/2;
        GE1(i) = mean(mean(semivariance(SEL)));
    end


    plot(DE1,GE1,'o','MarkerFaceColor',[0.4940, 0.1840, 0.5560])
    var_z = var(givenDataSet.z);
    b = [0 max(DE1)];
    c = [var_z var_z];
    hold on

    % plot(b,c, '--r')
    y1 = 1.1 * max(GE1);
    grid
    ylim([0 y1])
    xlabel('Distanz')
    ylabel('Semivarianz')
    hold off

end

