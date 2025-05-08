function decoded_part_num = topaz_part_number_decoder( part_num )
% Function to decode Atna part number
%
% Input Example: SiT9501AC1FSB2-3310-125.000000T
%
% Output Example:
%   decoded_part_num.
%                 product_family: 'SIT9501'
%                      cmos_type: 'SS_VCO2.5G'
%                  silicon_revision: 'A'
%     temperature_range_notation: 'C'
%              temperature_range: [-20 70]
%                output_waveform: 'FSPECL_VDD'
%                 fspecl_vdd_VHn: 1.050000000000000
%                 fspecl_vdd_VLn: 1.550000000000000
%                     package_sz: '3225'
%        frequency_stability_ppm: 25
%                   vdd_notation: '33'
%                superreg_enable: 1
%                        vdd_nom: 3.300000000000000
%                        vdd_max: 3.630000000000000
%                    feature_pin: 'OE'
%                   frequency_hz: 125000000
%
% Note: Silicon revision is different from CMOS revision. CMOS revision
% can only be identified from the device ID read from the part

%% parse inputs

if ~exist('part_num', 'var') || isempty(part_num)
    error('Missing input part number!');
end

part_num = upper( part_num );

%% product family & cmos type

decoded_part_num.product_family = part_num( 1:7 );

% map_product2cmos = containers.Map( ...
%     {'SIT9501', 'SIT9375', 'SIT9376', 'SIT9377', 'SITXX01'}, ...
%     {'SS_VCO2.5G', 'CP_fracN', 'CP_fracN', 'CP_fracN', 'SS_VCO5G'} );
product = {'SIT5134', 'SIT5135', 'SIT5136', 'SIT5137', 'SIT5334', 'SIT5335', 'SIT5336', 'SIT5337', 'SIT7343', 'SIT7344' ,'SIT7341'};
decoded_part_num.StabilityGrade = part_num( 12:12 );
					freq_range = {'1-60MHz', '60-105MHz', '1-60MHz', '60-105MHz', '1-60MHz', '60-105MHz', '1-60MHz', '60-105MHz', '1-105MHz', '1-105MHz' ,'1-100MHz'};
trim_mode = {'LP', 'LP', 'LJ', 'LJ', 'LP', 'LP', 'LJ', 'LJ', 'LP', 'LJ' , 'LP'};																															  

% cmos = {};
% if ~ismember( part_num( 1:7 ), keys( map_product2cmos ))
%     error('Invalid part number!');
% end

if ~ismember( part_num( 1:7 ), product)
    error('Invalid part number!');
end
decoded_part_num.freq_range = freq_range(find(ismember(product, part_num( 1:7 ))));
decoded_part_num.trim_mode = trim_mode(find(ismember(product, part_num( 1:7 ))));
% decoded_part_num.cmos_type = map_product2cmos( part_num( 1:7 ));
% decoded_part_num.cmos_type = cmos(find(ismember(product, part_num( 1:7 ))));

%% silicon revision

decoded_part_num.silicon_revision = part_num( 8 );

%% temperature range

% map_temprange = containers.Map( ...
%     {'C', 'I', 'B', 'E'}, {[-20 70], [-40 85], [-40 95], [-40 105]});
label = {'C', 'I', 'B', 'E', 'A', 'M'};
temp_range = {[-20 70], [-40 85], [-40 95], [-40 105], [-40 125], [-55 125]};
if ~ismember( part_num( 9 ), label)
    error('Invalid temperature range in part number!');
end
decoded_part_num.temperature_range_notation = part_num( 9 );
decoded_part_num.temperature_range = temp_range(find(ismember(label, part_num( 9 ))));

%% output waveform

% map_nonfspecloutdrv = containers.Map( ...
%     {'01', '02', '04', '08'}, {'LVPECL', 'LVDS', 'HCSL', 'HCSL_LP'});
type = {'-', 'C', 'J', 'H'};
outdrv_waveform = {'LVCMOS', 'CSINE', 'Regulated LVCMOS, 1.0V typ ', 'Regulated LVCMOS, 1.5V typ '};
outdrv = {'LVCMOS', 'CSINE', 'LVCMOS', 'LVCMOS'};


if ~ismember( part_num( 10 ), type)
    error('Invalid output waveform in part number!');
end
decoded_part_num.output_waveform = outdrv_waveform(find(ismember(type, part_num( 10 ))));
decoded_part_num.outdrv =  char(outdrv(find(ismember(type, part_num( 10 )))));

%% package size

% map_package = containers.Map({'P', 'A', 'B'}, {'2016', '2520', '3225'});
package = {'F'};
size =  {'5032'};
if ~ismember( part_num( 11 ), package)
    error('Invalid package size in part number!');
end
decoded_part_num.package_sz = size(find(ismember(package, part_num( 11))));


%% frequency stability

% map_fstab = containers.Map({ '1', '2', '8', '3'}, {20, 25, 30, 50});
fmap = { 'K', 'A', 'D', 'Q', 'P'};
stab = {0.5, 1.0, 2.5, 0.1, 0.2};
if ~ismember( part_num( 12 ), fmap)
    error('Invalid frequency stability in part number!');
end
decoded_part_num.frequency_stability_ppm = stab(find(ismember(fmap, part_num( 12))));



%% supply voltage
% <NOTE> CHECK WITH CMOS DESIGN

supply_opts = {'18', '30', '33'};
if ~ismember( part_num( 14:15 ), supply_opts)
    error('Invalid supply voltage in part number!');
end

% map_superreg = containers.Map( supply_opts, { 0, 0, 1, 1, 1, 0});
% map_vdd_nom  = containers.Map( supply_opts, { 1.5, 1.8, 2.5, 3.3, 2.5, 1.8});
% map_vdd_min  = containers.Map( supply_opts, { 1.425, 1.71, 2.25, 2.97, 2.25, 1.71});
% map_vdd_max  = containers.Map( supply_opts, { 1.575, 1.89, 2.75, 3.63, 3.63, 3.63});

map_vdd_nom  = { 1.8, 3.0, 3.3};
map_vdd_min  = { 1.70, 2.7, 2.97};
map_vdd_max  = { 1.90, 3.3,  3.63};

decoded_part_num.vdd_notation = part_num ( 14:15 );

decoded_part_num.vdd_nom = map_vdd_nom(find(ismember(supply_opts, part_num( 14:15 ))));
decoded_part_num.vdd_min = map_vdd_min(find(ismember(supply_opts, part_num( 14:15 ))));
decoded_part_num.vdd_max = map_vdd_max(find(ismember(supply_opts, part_num( 14:15 ))));


%% prog pin feature

% map_progfeature = containers.Map( {'0', '1', '2'}, {'NF', 'OE', 'OEbar'} );
prog = {'N', 'E', 'K', 'L', 'M'};
feature = {'NF', 'Pin 1 - OE', 'Pin 1 - OE', 'NF Software OE Control, Output Default OFF', 'NF Software OE Control, Output Default ON'};
if ~ismember( part_num( 16 ), prog)
    error('Invalid prog pin feature in part number!');
end
decoded_part_num.feature_pin = feature(find(ismember(prog, part_num( 16 ))));

%% Pin3 feature


			   
% map_progfeature = containers.Map( {'0', '1', '2'}, {'NF', 'OE', 'OEbar'} );
prog = {'L', 'N' , 'H', 'Y', 'Z', 'T'};
feature = {'LO Lock Output', 'NF', '200ppm', '800ppm', '1600ppm', '200ppm'};
lo_lock = {'lock_pad','default','lock_pad','lock_pad','lock_pad','lock_pad'};
if ~ismember( part_num( 17 ), prog)
    error('Invalid Pin3 feature in part number!');
end

decoded_part_num.pin_3 = feature(find(ismember(prog, part_num( 17 ))));
decoded_part_num.lo_lock = lo_lock(find(ismember(prog, part_num( 17 ))));

 if (strcmp(decoded_part_num.pin_3 , 'LO Lock Output') || strcmp(decoded_part_num.pin_3 , 'NF'))
        decoded_part_num.trim = 'TCXO';
        decoded_part_num.i2c = 0;
    elseif (strcmp(decoded_part_num.pin_3 , '200ppm') || strcmp(decoded_part_num.pin_3 , '800ppm') || strcmp(decoded_part_num.pin_3 , '1600ppm'))
       decoded_part_num.trim =  'DCTCXO';
       decoded_part_num.i2c = 1;
       decoded_part_num.lo_lock = 'lock_pad';
 end


%% Protocol Address mode
if strcmp(decoded_part_num.trim, 'DCTCXO')
    % map_fstab = containers.Map({ '1', '2', '8', '3'}, {20, 25, 30, 50});
    prog = {'8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    if ~ismember( part_num( 13 ), prog)
        error('Invalid Protocol Address mode in part number!');
    end
    switch part_num(13)
        case {'8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
            decoded_part_num.I2C_mode = 'A0 Pin is NC';
        case 'G'
            decoded_part_num.I2C_mode = 'Controlled by A0 Pin';
        otherwise
            error('Invalid Protocol Address mode in part number!');
    end
    decoded_part_num.i2c_addres = part_num( 13 );
end


%% Sensitivity 

prog = {'-', 'A'};
feature = {'-', 'Low g-Sensitivity, 0.1 ppb/g'};
if ~ismember( part_num( 18 ), prog)
    error('Invalid Sensitivity feature in part number!');
end
decoded_part_num.Sensitivity = feature(find(ismember(prog, part_num( 18 ))));

%% NVM Burn
I = strfind(part_num,'-NOBURN');
if ~isempty(I)
    decoded_part_num.burn_nvm = false;
    part_num(I:(I+6)) = '';  % Remove the -NOBURN flag
else
    decoded_part_num.burn_nvm = true;
end


%% output frequency

if isletter(part_num(end))
    frequency_Mhz_txt = part_num( 19:end-1 );																	 
else
    frequency_Mhz_txt = part_num( 19:end );
																			
end
decoded_part_num.frequency_Mhz = str2double(frequency_Mhz_txt)*1e6 ;



%% *Info:*
%  Author           :	Santhoshd
%  Email address	:	santhoshd@anoralabs.com
%  Date             :	19/11/2024
%  Revision         :	1.0
%  Update           :	update for Topaz part number decode
%
% ANORA