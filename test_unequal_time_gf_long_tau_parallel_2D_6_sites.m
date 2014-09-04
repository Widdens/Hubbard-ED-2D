function test_suite = test_unequal_time_gf_long_tau_parallel_2D_6_sites
initTestSuite;
global in_NUM_EIGEN_VALUES_UP;
global in_NUM_EIGEN_VALUES_DN;
in_NUM_EIGEN_VALUES_UP = 17; % These are the smallest values that we can get away with such that the result still agrees with the brute-force results to within 0.1%
in_NUM_EIGEN_VALUES_DN = 9;
global in_tau_start;
global in_tau_end;
global in_tau_step;
in_tau_start = 1;
in_tau_end = 3;
in_tau_step = 1;
end

function inp = setup
inp.in_t = 1;
inp.in_U = 4;
inp.Lx = 6;
inp.Ly = 1;
inp.in_noOfUp = 3;
inp.in_noOfDn = 5;
inp.method = 'long_tau';
inp.commit_number = 'testtesttest';
inp.need_profiling = 'No';
inp.NUM_CORES = 4;
end

function teardown(inp)
% do nothing
end

function test_unqual_time_gf_up_6(inp)
    global in_NUM_EIGEN_VALUES_UP;
    global in_tau_start;
    global in_tau_end;
    global in_tau_step;
    sector = 'up';

    list_of_generated_files = ...
        unequalTimeGF_long_tau_parallel_2D( inp.in_t, inp.in_U, in_tau_start, in_tau_end, in_tau_step, inp.Lx, inp.Ly, inp.in_noOfUp, inp.in_noOfDn, in_NUM_EIGEN_VALUES_UP, sector, inp.method, inp.commit_number, inp.need_profiling, inp.NUM_CORES );

%     expected_file_names = {};
%     list_of_taus = in_tau_start:in_tau_step:in_tau_end;
%     for i_filename = 1:length(list_of_taus)
%         tau = list_of_taus(i_filename);
%         expected_file_names{i_filename} = strcat('ED_',num2str(inp.in_noOfSites, '%02d'),...
%             '_sites_',num2str(inp.in_noOfUp, '%02d'),...
%             'u',num2str(inp.in_noOfDn, '%02d'),...
%             'd_U_',num2str(inp.in_U, '%4.2f'),...
%             '_tau_',num2str(tau, '%4.2f'),...
%             '_t_',num2str(inp.in_t),...
%             '_eigen_', num2str(in_NUM_EIGEN_VALUES_UP, '%04d'),...
%             ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
%     end
    
%     for i=1:length(expected_file_names)
%         expected = expected_file_names{i}(1:50);
%         result = list_of_generated_files{i}(1:50);
%         assertEqual( result, expected );
%     end

    load( list_of_generated_files{1}, '-mat', 'spinUpGreenFunction'); % tau = 1
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [0.0043129 -0.0024579 -0.0010315 0.0026811 -0.0010315 -0.0024579],...
       'relative', 0.001);
   clearvars spinUpGreenFunction;

    load( list_of_generated_files{2}, '-mat', 'spinUpGreenFunction'); % tau = 2
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [4.6613e-05 -2.54e-05 -1.6017e-05 3.6236e-05 -1.6017e-05 -2.54e-05],...
       'relative', 0.001);
   clearvars spinUpGreenFunction;

    load( list_of_generated_files{3}, '-mat', 'spinUpGreenFunction'); % tau = 3
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [5.3638e-07 -2.8605e-07 -2.0964e-07 4.5502e-07 -2.0964e-07 -2.8605e-07],...
            'relative', 0.001);
   clearvars spinUpGreenFunction;
    

end

function test_unqual_time_gf_dn_6(inp)
    global in_NUM_EIGEN_VALUES_DN;
    global in_tau_start;
    global in_tau_end;
    global in_tau_step;
    sector = 'dn';

    list_of_generated_files = ...
        unequalTimeGF_long_tau_parallel_2D( inp.in_t, inp.in_U, in_tau_start, in_tau_end, in_tau_step, inp.Lx, inp.Ly, inp.in_noOfUp, inp.in_noOfDn, in_NUM_EIGEN_VALUES_DN, sector, inp.method, inp.commit_number, inp.need_profiling, inp.NUM_CORES );
    
%     expected_file_names = {};
%     list_of_taus = in_tau_start:in_tau_step:in_tau_end;
%     for i_filename = 1:length(list_of_taus)
%         tau = list_of_taus(i_filename);
%         expected_file_names{i_filename} = strcat('ED_',num2str(inp.in_noOfSites, '%02d'),...
%             '_sites_',num2str(inp.in_noOfUp, '%02d'),...
%             'u',num2str(inp.in_noOfDn, '%02d'),...
%             'd_U_',num2str(inp.in_U, '%4.2f'),...
%             '_tau_',num2str(tau, '%4.2f'),...
%             '_t_',num2str(inp.in_t),...
%             '_eigen_', num2str(in_NUM_EIGEN_VALUES_DN, '%04d'),...
%             ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
%     end
%     
%     for i=1:length(expected_file_names)
%         expected = expected_file_names{i}(1:50);
%         result = list_of_generated_files{i}(1:50);
%         assertEqual( result, expected );
%     end

    load( list_of_generated_files{1}, '-mat', 'spinDnGreenFunction'); % tau = 1
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [0.001352 -0.0013343 0.0013278 -0.0013178 0.0013278 -0.0013343],...
        'relative', 0.001);
   clearvars spinDnGreenFunction;

    load( list_of_generated_files{2}, '-mat', 'spinDnGreenFunction'); % tau = 2
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [1.216e-05 -1.2141e-05 1.2133e-05 -1.2118e-05 1.2133e-05 -1.2141e-05],...
           'relative', 0.001);
   clearvars spinDnGreenFunction;
   
    load( list_of_generated_files{3}, '-mat', 'spinDnGreenFunction'); % tau = 3
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [1.106e-07 -1.1058e-07 1.1057e-07 -1.1055e-07 1.1057e-07 -1.1058e-07],...
                'relative', 0.001);
   clearvars spinDnGreenFunction;
   
end