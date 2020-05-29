function covarianceMatrix = calculateCovariance(dataRealisations, ...
    queryRealisations)

% Berechnet die Kovarianz zwischen n Datenpunkten (n x n Kovarianzmatrix) 
% oder die Kovarianz zwischen den n Daten- und m Sch�tzpunkten (n x m
% Kovarianzmatrix.

% Input-Argumente:  dataRealisations:   Realisierungen der Zufallsvariablen 
%                                       an den Datenpunkten (ben�tigt)
%                   queryRealisations:  Realisierungen der Zufallsvariablen 
%                                       an den Sch�tzpunkten (optional)
%
% Beachten: Anzahl der dataRealisations und queryRealisations muss gleich
% sein.


  % Wie viele Parameter wurden �bergeben? 
  switch nargin
      case 1  
          %Kovarianz zwischen Datenpunkten
          
          N = size(dataRealisations, 2);
          meanData = mean(dataRealisations, 2);

          % Initialisierung Kovarianzmatrix
          covarianceMatrix = zeros(size(dataRealisations, 1));

          % Berechnung der Kovarianzmatrix zwischen allen Datenpunkten
          for i = 1:size(dataRealisations, 1)
                 for j = i:size(dataRealisations, 1)
                     
                     covij = sum((dataRealisations(i,:) - ...
                        meanData(i)) .* (dataRealisations(j,:) - ...
                        meanData(j))) / (N-1);
                    
                     covarianceMatrix(i,j) = covij;
                     covarianceMatrix(j,i) = covij;
                     % Erkl�rung: Da die Covarianzmatrix symetrisch ist, 
                     % m�ssen wir nicht alle Eintr�ge separat berechnen,
                     % sondern nur die H�lfte und an die Stellen i,j UND 
                     % j,i eintragen.
                     
                 end
          end          
          
      case 2 
          % Kovarianzmatrix zwischen Daten- und Sch�tzpunkten
          
          N = size(dataRealisations, 2);
          meanData_d = mean(dataRealisations, 2); 
          meanData_q = mean(queryRealisations, 2); 

          % Initialisierung Kovarianzmatrix
          covarianceMatrix = zeros(size(dataRealisations, 1), ...
            size(queryRealisations, 1));

            for i = 1:size(dataRealisations, 1)
                for j = 1:size(queryRealisations, 1)

                    covarianceMatrix(i,j) = ...
                        sum((queryRealisations(j,:) - ...
                        meanData_q(j)) .* (dataRealisations(i,:) - ...
                        meanData_d(i))) / (N-1);

                end
            end
            
  end          
end
