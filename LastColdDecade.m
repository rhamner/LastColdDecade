clear all
close all

%Load the file
path = #LOADPATH;
ncdisp(path);
file = netcdf.open(path, 'NC_NOWRITE');
lat = netcdf.getVar(file, 1); 
lon = netcdf.getVar(file, 0);
time = netcdf.getVar(file, 2);
temp = netcdf.getVar(file, 3);

%Remove unused data
p = find(lat >= 25 & lat <= 45);
q = find(lon >= -130 & lon <= -60);
lat = lat(p);
lon = lon(q);
temp = temp(q, p, :);

%Figure out the average temperature (anomaly) in each decade
decadeTemp = zeros(length(lon), length(lat), 16);
year = 1;
for k = 1:120:(length(time) - 120)
    decadeTemp(:, :, year) = mean(temp(:, :, k:(k + 119)), 3);
    year = year + 1;
end

%Figure out the average temperature (anomaly) from 1850-1900
avTemp = zeros(length(lon), length(lat));
avTemp(:, :) = mean(temp(:, :, 1:600), 3);

%Find the last decade that was cooler than the 1850-1900 average for each
%location
avTime = zeros(length(lon), length(lat));
for i = 1:length(lon)
    for j = 1:length(lat)
        if(~isnan(avTemp(i, j, 1)))
            avTime(i, j) = 1840 + 10*max(find(decadeTemp(i, j, :) < avTemp(i, j)));
        else
            avTime(i, j) = NaN;
        end
    end
end

%Plot a map with cities
figure(1)
surface(lon, lat, avTime', 'edgecolor', 'none')
colorbar
caxis([min(min(avTime)) max(max(avTime))])
hold on

citynames{1} = 'Philadelphia';
citynames{2} = 'Manchester';
citynames{3} = 'Atlanta';
citynames{4} = 'Sioux Falls';
citynames{5} = 'Las Vegas';
citynames{6} = 'Topeka';
citynames{7} = 'Jackson';
citynames{8} = 'San Antonio';
citynames{9} = 'Denver';
citynames{10} = 'Boise';
citynames{11} = 'Chicago';
citynames{12} = 'Phoenix';

clat(1) = 39.95;
clon(1) = -75.17;
clat(2) = 43;
clon(2) = -71.45;
clat(3) = 33.75;
clon(3) = -84.39;
clat(4) = 43.54;
clon(4) = -96.73;
clat(5) = 36.1;
clon(5) = -115.8;
clat(6) = 39.06;
clon(6) = -95.69;
clat(7) = 32.30;
clon(7) = -90.18;
clat(8) = 29.42;
clon(8) = -98.49;
clat(9) = 39.74;
clon(9) = -105;
clat(10) = 43.62;
clon(10) = -116.21;
clat(11) = 41.88;
clon(11) = -87.63;
clat(12) = 33.45;
clon(12) = -112.07;

%scatter with zindex high enough to be on top
scatter3(clon, clat, [10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000], 50, 'k', 'filled')
for j = 1:length(clon)
    text(clon(j) + 0.5, clat(j), 10000, char(citynames{j}), 'fontsize', 16, 'color', 'black');
end
set(gca, 'box', 'off')
axis off
title('Last ''colder than average'' decade', 'fontsize', 16)

%Dump data to file for tableau
f = fopen(#SAVEPATH, 'w');
for i = 1:length(lon)
    for j = 1:length(lat)
        fprintf(f, '%d\t%.2f\t%.2f\t%d''s\tn\\a\r\n', i*length(lat) + j, lon(i), lat(j), avTime(i, j));
    end
end
for i = 1:length(clon)
    fprintf(f, '%d\t%.2f\t%.2f\tCity Label\t%s\r\n', 999990 + i, clon(i), clat(i), citynames{i});
end
fclose(f);