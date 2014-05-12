% Parameters to be set from the beginning
Number_of_ports = 4;
clock_freq = 1.2; % 1.2GHz
Final_arrival_time_ns = 813525664;
Final_arrival_time_cc = (Final_arrival_time_ns * clock_freq );

% READS THE ORIGINAL TRACE FILE
file = 'trace.txt';
fid = fopen(file,'r');

a = textscan(fid,'%d %d %d %u64','delimiter', ' ');
source_core = a{1};
destination_core = a{2};
message_size = a{3};
arrival_times = a{4};

% DEFINITION OF THE VARIABLES
N = numel(arrival_times);
num_bits_time = ceil(log2(Final_arrival_time_cc)); % to be set depending on the 
num_bits_destination = ceil(log2(Number_of_ports)); % depends on the number of destinations that you have
slot_size = 512; % 512 bits

% CONVERTS THE TIME FROM ns TO clock cycles & SORTS THE COMMUNICATION IN
% ASCENDING VALUES OF TIME
arrival_times_cycles = ceil(arrival_times*1.2);
b = zeros(N,4);
for i=1:N
    b(i,1) = arrival_times_cycles(i);
    b(i,2) = source_core(i);
    b(i,3) = destination_core(i);
    if message_size(i) > 0
        b(i,4) = message_size(i);
    else
        b(i,4) = 1;
    end
end
b_sorted = sortrows(b);


for x = 0:(Number_of_ports - 1)
    
    % DIVIDES THE COMMUNICATION INTO THEIR RESPECTIVE SOURCE CORES
    count = 0;
    for i = 1:N
        if b_sorted(i,2) == x
            count = count + 1;
            c(count,1) = b_sorted(i,1); % time is in first column
            c(count,2) = b_sorted(i,3); % destination is in 2nd column
            c(count,3) = b_sorted(i,4); % message size is included in 3rd column
        end
    end
    
    % SPLITS THE MESSAGES INTO 512 BITS PACKETS AND SEND THEM SEQUENTIALLY VIA
    % THE FIFO, HENCE, MODIFICATION OF THE ARRIVAL TIMES OF THE MESSAGES
    count_decimal = 1;
    
    c_decimal(1,1) = -1;
    c_decimal(1,2) = 0;
    for i = 1:count
        for j = 1:c(i,3)
            count_decimal = count_decimal + 1;
            if c(i,1) > c_decimal((count_decimal-1),1)
                c_decimal(count_decimal,1) = c(i,1); % time variable
            else
                c_decimal(count_decimal,1) = c_decimal((count_decimal-1),1) + 1;
            end
            c_decimal(count_decimal,2) = c(i,2); % destination variable
        end
    end
    c_decimal(1,:) = [];
    
    % CONVERTING THE INFORMATION IN THE TRACE-FILE TO BINARY FORM
    node = cell(1,(2*(count_decimal-1)));
    for i = 1:(count_decimal-1)
        y = dec2bin(c_decimal(i,1),num_bits_time);
        node{((2*i)-1)} = y;
        node{(2*i)} = dec2bin(c_decimal(i,2),num_bits_destination);
    end
    
    % WRITING THE ARRAYS INTO .TXT FILES
    file_write = ['node_' num2str(x) '.txt'];
    fid1 = fopen( file_write, 'wt' );
    fprintf(fid1,'%s\n',node{:});
    fclose(fid1);
end


