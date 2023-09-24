%% Ground Penetrating Radar TWT conversion to snow density
% Intended to convert GPR twt's into snow density using snow probe depths for validation
% Created by Kori Mooney 6/19/2023; Last Edited: 9/24/2023 to clarify for
% uploading to GitHub repo

%% Table of Constants...............................................................................................................................
clear
c = 0.2998;                                      % Speed of light in a vacuum [m ns^-1]
ei = 3.17;                                       % Dielectric constant of ice 
ea = 1;                                          % Dielectric constant of air
pw = 1000;                                       % Density of water @0-10 C [kg m^-3]
c1 = 0.000851;

%% Required inputs..................................................................................................................................
GPR = readtable('GPR_5_NORTHTOP.csv');           % Two way travel time (TWT) [ns] in ReflexW .csv format
ds_cm = readmatrix('Probe_5_NORTHTOP.csv');      % Snow probe depth [cm]
Density_Pit = 232.71;                            % Average snow pit density [kg m^-3]

%% Format data & convert units......................................................................................................................
ds = ds_cm./100;                                 % Snow probe depth [m]

%% Sort GPR data into snow surface and ground surface returns.......................................................................................
% snow surface=1 (top of snowpack) and ground surface=2 (bottom of
% snowpack), must be coded this way in ReflexW before exporting data as
% .csv
n=length(GPR.Var1);
for i=1:n
   if GPR.Var2(i) < 2                            % if label is less than 2, it is a snow surface measurement 
    Top(i) = GPR.Var3(i);
   else 
       Bottom (i) =GPR.Var3(i);                  % otherwise, it is a ground surface measurement
   end
end
Top = Top';                                      % format to a vector
Bottom = Bottom';

Bottom(find(Bottom==0)) = [];                    % remove zeros from Top and Bottom TWT values
Top(find(Top==0)) = [];

%% Match up lengths so net TWT can be calculate.....................................................................................................
% Plot comparing boxplots of surface reflection and ground reflection
subplot(2,2,1)
boxplot(Top)
title('range of snow surface reflection values')
ylabel('TWT [ns]')
subplot(2,2,2)
plot(Top)
ylabel('TWT [ns]')
subplot(2,2,3)
boxplot(Bottom)
title('range of ground reflection values')
ylabel('TWT [ns]')
subplot(2,2,4)
plot(Bottom)
ylabel('TWT [ns]')

% by looking at these plots, we can infer that subtracting the median snow surface reflection value from each individual ground reflection point
% will give us the net TWT 
Top_med = median(Top);   % 0.8 ns

% 1.) create a loop that subtracts median value of snow surface reflection
% from all ground reflections
n=length(Bottom);
for i=1:n
TWT(i) = Bottom(i) - median(Top);
end
TWT = TWT';
TWT_median = median(TWT)                        % 13.2000 ns (example calc)

subplot(1,2,1)
boxplot(TWT)
title('range of net TWT values')
ylabel('TWT [ns]')
subplot(1,2,2)
plot(TWT)
ylabel('TWT [ns]')

% These can be used to double check your work...

% % 2.) If top is larger than bottom, it can be cropped to match the bottom
% CropTop = length(Top)-length(Bottom)            
% Top(CropTop:length(Top))
% Top=ans(1:length(Bottom))
% 
% % 3.) If bottom is larger than top, average the values first to avoid loss of ground reflection data
% Top = median(Top)
% Bottom = median(Bottom)
% TWT = Bottom - Top                              % 13.2000 ns (example calc)
% 
% % 4.) Crop ground reflection to match surface reflection (removes some ground reflection values in order to line up your vectors, which changes median)
% CropBottom = length(Bottom)-length(Top)
% Bottom(CropBottom:length(Bottom))
% Bottom=ans(1:length(Top))
% TWT = Bottom - Top
% 
% TWT_median = median(TWT)                        % 13.6000 ns (example calc)

% results unclear as to best method to proceed with. 
        
% % subtract snow surface from ground surface to get net TWT [ns]....................................................................................
% n = length(Bottom)
% for i=1:n
%     TWT(i)=Bottom(i)-Top(i)
% end
% TWT = TWT'

%% Use probe depth to calculate wave velocity......................................................................................................
boxplot(ds)
ds_median = median(ds)                          % calculate the median snow depth  

TWT_sin = (TWT_median./(sin(20)))


u = (ds_median./(TWT_sin./2))                   % Velocity [m ns^-3]

% Use velocity to calculate permittivity..........................................................................................................
Ks = (c./u).^2

% Use permittivity to calculate snow density
% ps = ((sqrt(Ks))-1)/c1                % density of snow [kg m^-3]

% use paper density equation (Kovacs et al. 1995) (eq 3)
ps = (((sqrt(Ks))-1)./0.845).*1000              % Converts g cm^-3 to kg m^-3







