% count the connect/disconnect cycles 

function [cc,dc,bcc,acc] = cycle_tracker(time_1,time_2,files)

    % Counts and displays the connect and disconnect cycles for BiVACOR device cables based on Gemini APP files.
    % Cables include driveline, console cable, battery cable, ac adaptor cable.
    % User may input start time and end time for counts (as well as file location).
    % Assumes UTC time inputs.
    
    
    % specify location of APP files - Found on desktop of device running the BiVACOR app inside the ‘Gemini’ folder - change path
        %files = dir("C:\Users\DanielleVillaruel\OneDrive - BiVACOR Inc\Desktop\SANDBOX\Driveline (Dis)Connect Testing\Connect-Disconnect Test\*.csv");
        %addpath("C:\Users\DanielleVillaruel\OneDrive - BiVACOR Inc\Desktop\SANDBOX\Driveline (Dis)Connect Testing\Connect-Disconnect Test\");
        
    % input start and end times
        %time_1 = '7/2/2025 11:40:23 PM';
        %time_2 = '7/2/2025 11:41:24 PM';

    %start_time_UTC = datetime(time_1, 'InputFormat', 'M/d/yyyy hh:mm:ss a','Timezone','UTC');
    start_time_UTC = datetime(time_1, 'InputFormat','dd-MMM-yyyy hhmmss a','Timezone','UTC');
    start_time_LA = start_time_UTC;
    start_time_LA.TimeZone = 'America/Los_Angeles';

    %end_time_UTC = datetime(time_2, 'InputFormat', 'M/d/yyyy hh:mm:ss a','Timezone','UTC');
    end_time_UTC = datetime(time_2, 'InputFormat','dd-MMM-yyyy hhmmss a','Timezone','UTC');
    end_time_LA = end_time_UTC;
    end_time_LA.TimeZone = 'America/Los_Angeles';


    %% console count
    % Count the number of ‘…_APP_...’ event files generated in a specific folder

    %console_files = struct2table(files);
    %console_files.date = datetime(console_files.datenum,'ConvertFrom',"datenum"); % can easily compare dates
    %console_files = removevars(console_files,"datenum");


    console_cycles = 0;
    for i = 1:length(files)
        %console_time = datetime(files(i).name(19:35), 'InputFormat', 'yyyy-M-d_HHmmss', 'Timezone', 'UTC');
        if contains(files(i).name,'_APP_')
            console_time = datetime(files(i).name(20:36), 'InputFormat', 'yyyy-M-d_HHmmss', 'Timezone', 'UTC');
        else
            console_time = NaT;
        end
        
        console_time.Timezone = 'America/Los_Angeles';
        if (start_time_LA <= console_time) && (console_time <= end_time_LA)
            console_cycles = console_cycles +1;
        end
        % may need to change 1st datetime input into a regexp() entry
        %{
        console_time.TimeZone = 'America/Los_Angeles';
        if (start_time_LA <= console_time) && (console_time <= end_time_LA)
            if contains(files(i).name,'_APP_')
                console_cycles = console_cycles + 1;
            end
        end
        %}
    end
    cc = console_cycles;


    %% driveline, battery cable, and ac adaptor count 
    driveline_cycles = 0;
    battery_cycles = 0;
    ac_cycles = 0;
    

    for i = 1:numel({files.name})
        
        %alarms = readtable(files(i).name);
        filename = fullfile(files(i).folder, files(i).name);
        alarms = readtable(filename);
        
        for j = 1:height(alarms)
            time = alarms{j,1};
            time.TimeZone = 'UTC'; % specify original zone before converting, because it starts unzoned
            time.TimeZone = 'America/Los_Angeles';
            if (start_time_LA <= time) && (time <= end_time_LA)
                if isequal(char(alarms{j,5}),'Driveline Disconnected') && isequal(char(alarms{j,6}),'Critical')
                    driveline_cycles = driveline_cycles + 1;
                %elseif isequal(char(alarms{j,5}),'Disconnected Battery 2') && isequal(char(alarms{j,6}),'Alarm')
                elseif isequal(char(alarms{j,5}),'Disconnected Battery 1') && isequal(char(alarms{j,6}),'Alarm')
                    battery_cycles = battery_cycles + 1;
                elseif isequal(char(alarms{j,5}),'Backup Battery In Use') && isequal(char(alarms{j,6}),'Critical')
                    ac_cycles = ac_cycles + 1;    
                end
            end
        end
    end
    dc = driveline_cycles;
    bcc = battery_cycles;
    acc = ac_cycles;

end

    %{ 
    for example: 
        console_cycles = 1
        driveline_cycles = 2
        battery_cycles = 1
        ac_cycles = 1

    ** also tested by making copies of the same example files
    * then test time range by 'caging in' specific cycles
    %}

