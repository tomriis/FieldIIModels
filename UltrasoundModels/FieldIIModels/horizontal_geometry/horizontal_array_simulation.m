function [max_hp, sum_hilbert, xdc_data]=horizontal_array_simulation(varargin)

p = inputParser;
addRequired(p,'n_elements_r', @(x) isnumeric(x));
addRequired(p,'n_elements_z', @(x) isnumeric(x));
addRequired(p,'a', @(x) isnumeric(x));
addRequired(p,'b', @(x) isnumeric(x));
addRequired(p,'D');
addRequired(p, 'focal_point');
addOptional(p, 'kerf',0.4);
addOptional(p, 'R_focus', 1e15, @(x) isnumeric(x));
addOptional(p,'visualize_transducer',false);
addOptional(p,'Slice','xy');
addOptional(p,'excitation',-1);
addOptional(p,'f0',650000)
parse(p, varargin{:})

%% Parameters to vary in this exercise
visualize_transducer = p.Results.visualize_transducer;
focal_point = p.Results.focal_point; %(mm) point of ultrasound focus relative to the top of the dome transducer array (Insightec Exablate Neuro system)
if size(focal_point,2) == 1
    focal_point = focal_point';
end

plane = p.Results.Slice; %('xy' or 'xz'); the plane within which we visualize the pressure field

%% Initialize Field II:
field_init(-1);

%% Set up medium & simulation:
c = 1500;  %(m/s) global speed of sound in medium
f0 = p.Results.f0;  %(Hz) center frequency of the transducer
fs = f0 * 20;  %(Hz) sampling frequency of the simulation; 20 times the transducer frequency is enough
alpha = 0.5 * 100 / 1e6;  %(dB/m/Hz) attenuation of ultrasound in the brain
%
set_field('c', c);
set_field('fs', fs);
set_field('att', alpha);

%% Linear concave array

a = p.Results.a; %mm
b = p.Results.b;
n_elements_r = p.Results.n_elements_r;  %number of physical elements in X.
n_elements_z = p.Results.n_elements_z;  %number of physical elements in Y.
kerf = p.Results.kerf;
D_rz = p.Results.D; % Diameter, width, and length of element (mm)
R_focus = p.Results.R_focus;
[Tx] = horizontal_array(n_elements_r,n_elements_z, kerf/1000, D_rz/1000, R_focus/1000, a/1000, b/1000);

%Show the transducer array in 3D
if visualize_transducer
    xdc_data = xdc_get(Tx,'rect');
    show_xdc(Tx);
    txfield = 0;
    max_hp = 0;
    sum_hilbert = 0;
    return
end
%xdc_show(Tx); %this displays the coordinates of each element within the array

%% Impulse response of a transducer (= acoustic pressure response emitted by a transducer when subjected to an electric dirac driving pulse)
fracBW = .250;  %fractional bandwidth of the xducer
tc = gauspuls('cutoff', f0, fracBW, -6, -40);  %cutoff time at -40dB, fracBW @ -6dB
t = -tc : 1/fs : tc;  %(s) time vector centered about t=0
impulse_response = gauspuls(t,f0,fracBW);
xdc_impulse(Tx,impulse_response);
%
% Plot the impulse response
% plot(t*1e6, impulse_response); grid on; xlabel('t (\musec)');

%% Driving waveform
if p.Results.excitation == -1
   excitation = 1;  % driving signel; 1 = simple pulse
else    
    excitation = p.Results.excitation;
end

xdc_excitation(Tx, excitation);

%% Set focal point
focus = focal_point * 1e-3;  %(m)

rect = xdc_pointer_to_rect(Tx);
delays = compute_delays(rect, focus, c); %(s) The delay within which the ultrasound is fired from each of the array elements such as to achieve the desired focal point
%(could also use xdc_center_focus(Tx,[0 0 0]); xdc_focus(Tx, 0, focus) for physical element designs (e.g., dome tiled with xdc_rectangles()), instead of the mathematical xdc_concave)

%delays=repmat(delays,1,Nx*Ny);

%ele_delay(Tx, rect(1,:)', delays); %set the delays
%xdc_center_focus(Tx, [0,0,0]);
xdc_focus(Tx, 0, focus);
% times = (1:4:200)'*1/f0;
% all_delays = zeros([length(times), size(rect,2)]);
% for i = 1:length(times)
%     all_delays(i,:) = compute_delays(rect, focus,c, p.Results.jitter)';
% end
    
    
%xdc_focus_times (Tx, 0, delays');
%% Set measurement points
[x,y,z] = get_slice_xyz(plane, focus);
%create all individual x, y, z points within the above ranges
[xv, yv, zv] = meshgrid(x, y, z);
pos = [xv(:), yv(:), zv(:)];

%% Calculate the emitted field at those points
[hp, ~] = calc_hp(Tx, pos); %this is where the simulation happens

xdc_data = xdc_get(Tx, 'rect');
%% Plot the emitted field
sum_hilbert = sum(abs(hilbert(hp)), 1); %Hilbert transform finds the envelop
%of the propagating pulse; summing it is a dirty way to approximate the amplitude of the signal regardless of the time it occurs at 
max_hp = max(abs(hp)); %take the maximal value of the propagating pulse, and this way not have to worry about at which time point the pulse arrived to the given location
size(sum_hilbert);

if length(x) == 1
    x = y; 
elseif length(y) == 1
    y = x;
elseif length(z) == 1
    z = y;
end
sum_hilbert = reshape(sum_hilbert, length(x), length(z));
max_hp = reshape(max_hp,length(x), length(z));

%% Terminate Field II
field_end();