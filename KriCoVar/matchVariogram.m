function matchVariogram(givenDataSet, model, nugget, sill, ...
    range, slope)

% Passt ein Variogrammmodell mit spezifischen Parametern an das 
% experimentelle Variogramm an.

% Input-Argumente:  givenDataSet:       struct-Variable mit drei Eintr?gen
%                                       f?r x-Position, y-Position und 
%                                       Werten f?r den jeweiligen Punkt (z)
%                   model:              char-Variable. Es stehen folgende 
%                                       Optionen bereit:
%                                       'linear' - lineares Variogramm
%                                       'exponential' - exponentielles Var.
%                                       'spherical' - spherisches Var.
%                                       'gaussian' - gaussches Var.
%                   nugget:             double-Variable. Wert zur
%                                       Beschreibung des Nuggets
%                   sill:               double-Variable. Wert zur
%                                       Beschreibung des Sills. Bei 
%                                       model = 'linear' kann sill = 0
%                                       ?bergeben werden.
%                   range:              double-Variable. Wert zur
%                                       Beschreibung des Ranges. Bei 
%                                       model = 'linear' kann range = 0
%                                       ?bergeben werden.
%                   slope:              double-Variable. Wert zur
%                                       Beschreibung des Anstieges. Nur bei
%                                       model = 'linear' erforderlich. Bei
%                                       model ~= 'linear' kann slope = 0
%                                       ?bergeben werden.
%
% Output:           Plot der Variogrammmodelfunktion in Abh?ngigkeit der
%                   ?bergebenen Parametern. Dargestellt werden auch die 
%                   gemittelten Semivarianzen (experimentelles 
%                   Semivariogramm).
            

    % Punktepaare
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
    
    distances = distances - diag(diag(distances));

    % Semivarianz von Punktepaaren der beobachteten variable z
    semivariance = 0.5 * (Z1 - Z2) .^ 2;

    % min lag-interval bestimmen - minimale distanz zwischen allen Punkten
    % (gemittelt) 
    distance_NaN = distances .* (diag(givenDataSet.x*  NaN) +1);
    minLag = mean(min(distance_NaN));

    % max lag interval bestimmen - h?lfte des Maximums
    halfMaxDistance = max(distances(:))/2;

    % Anzahl der lags
    numberLags = floor(halfMaxDistance/minLag);

    % Einteilung der Punktentfernungen in Klassen
    LAGS = ceil(distances / minLag); 

    % SEL: Matrix, die sich mir jedem Durchlauf ?ndert und jeweils die passenden
    % Eintr?ge in LAGS 1 setzt - Eintr?ge > 16 werden nicht ber?cksichtigt weil
    % zu gro?e Distanz
    % DE: Mittlere LAG Entfernung - durch 2, da symmetrische Distanzmatrix
    % GE: Mittlerer Semivarianz pro LAG 
    for i = 1 : numberLags
        SEL = (LAGS == i);
        DE1(i) = mean(mean(distances(SEL)));
        PN1(i) = sum(sum(SEL == 1)) / 2;
        GE1(i) = mean(mean(semivariance(SEL)));
    end


    plot(DE1, GE1, 'o', 'MarkerFaceColor', [0.4940, 0.1840, 0.5560])
    var_z = var(givenDataSet.z);
    b = [0 max(DE1)];
    c = [var_z var_z];
    hold on

    % plot(b,c, '--r')
    grid
    y1 = 1.1 * max(GE1);
    ylim([0 y1])
    hold on

    lags = 0:max(DE1);

    % Plot der Variogrammfunktion in Abh?ngiggkeit der ?bergebenen
    % Parameter
    switch model
        case 'linear'
            
            Glin = nugget + slope * lags;
            plot(lags, Glin, '-m')
            xlabel('Distanz')
            ylabel('Semivarianz')
            legend('Variogramm Schätzer', ...
             'Linear', 'location', 'southeast')
            hold off      

        case 'exponential'
            
            Gexp = nugget + sill*  (1 - exp(-3 * lags / range));
            plot(lags, Gexp, '-.b')
            xlabel('Distanz')
            ylabel('Semivarianz')
            legend('Variogramm Sch?tzer', ...
             'Exponentiell', 'location', 'southeast')
            hold off

        case 'spherical'
            lags = 0:max(DE1);
            Gsph = nugget + ...
                (sill * (1.5 * lags / range - 0.5 * (lags / ...
                range) .^ 3) .* (lags <= range) + ...
                sill * (lags > range));
            plot(lags, Gsph, ':b')
            xlabel('Distanz')
            ylabel('Semivarianz')
            legend('Variogramm Sch?tzer', ...
             'Spherisch', 'location', 'southeast')
            hold off

        case 'gaussian'
            Ggau = nugget + ...
                sill * (1 - exp(-((lags .^ 2) / (range^2))));
            plot(lags, Ggau, '-.b')
            xlabel('Distanz')
            ylabel('Semivarianz')
            legend('Variogramm Schätzer', ...
             'Gauss', 'location', 'southeast')
            hold off

        otherwise
            disp('wrong Model')

    end

end

