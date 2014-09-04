function test_suite = test_unequal_time_gf_long_tau_parallel_2D_5_sites
initTestSuite;
global in_NUM_EIGEN_VALUES;
in_NUM_EIGEN_VALUES = 23; % These are the smallest values that we can get away with such that the result still agrees with the brute-force results to within 0.1%
end

function inp = setup
inp.in_t = 1;
inp.in_U = 4;
inp.Lx = 1;
inp.Ly = 5;
inp.in_noOfUp = 3;
inp.in_noOfDn = 3;
inp.tau_start = 0.0;
inp.tau_step = 0.5;
inp.tau_end = 1.0;
inp.method = 'long_tau';
inp.commit_number = 'testtesttest';
inp.sector = 'both';
inp.need_profiling = 'No';
inp.NUM_CORES = 4;
end

function teardown(inp)
% do nothing
end

function test_5_sites(inp)
    global in_NUM_EIGEN_VALUES;

    [ list_of_generated_files ] = ...
         unequalTimeGF_long_tau_parallel_2D( inp.in_t, inp.in_U, inp.tau_start, inp.tau_end, inp.tau_step, inp.Lx, inp.Ly, inp.in_noOfUp, inp.in_noOfDn, in_NUM_EIGEN_VALUES, inp.sector, inp.method, inp.commit_number, inp.need_profiling, inp.NUM_CORES );
    
%     expected_file_names = {};
%     list_of_taus = inp.tau_start:inp.tau_step:inp.tau_end;
%     for i_filename = 1:length(list_of_taus)
%         tau = list_of_taus(i_filename);
%         expected_file_names{i_filename} = strcat('ED_',num2str(inp.in_noOfSites, '%02d'),...
%             '_sites_',num2str(inp.in_noOfUp, '%02d'),...
%             'u',num2str(inp.in_noOfDn, '%02d'),...
%             'd_U_',num2str(inp.in_U, '%4.2f'),...
%             '_tau_',num2str(tau, '%4.2f'),...
%             '_t_',num2str(inp.in_t),...
%             '_eigen_', num2str(in_NUM_EIGEN_VALUES, '%04d'),...
%             ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
%     end
    
%     for i=1:length(expected_file_names)
%         expected = expected_file_names{i}(1:50);
%         result = list_of_generated_files{i}(1:50);
%         assertEqual( result, expected );
%     end

    load( list_of_generated_files{1}, '-mat', 'spinUpGreenFunction'); % tau = 0
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [0.4 -0.28245 0.10829 0.10829 -0.28245],...
       'relative', 0.001);
   clearvars spinUpGreenFunction;

    load( list_of_generated_files{2}, '-mat', 'spinUpGreenFunction'); % tau = 0.5
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [0.040428 -0.031364 0.012102 0.012102 -0.031364],...
       'relative', 0.001);
   clearvars spinUpGreenFunction;

    load( list_of_generated_files{3}, '-mat', 'spinUpGreenFunction'); % tau = 1
    assertElementsAlmostEqual(spinUpGreenFunction,...
       [0.0044057 -0.0035174 0.0013523 0.0013523 -0.0035174],...
       'relative', 0.001);

   clearvars spinUpGreenFunction;
    

    load( list_of_generated_files{1}, '-mat', 'spinDnGreenFunction'); % tau = 0
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [0.4 -0.28245 0.10829 0.10829 -0.28245],...
        'relative', 0.001);
   clearvars spinDnGreenFunction;

    load( list_of_generated_files{2}, '-mat', 'spinDnGreenFunction'); % tau = 0.5
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [0.040428 -0.031364 0.012102 0.012102 -0.031364],...
        'relative', 0.001);
   clearvars spinDnGreenFunction;
   
    load( list_of_generated_files{3}, '-mat', 'spinDnGreenFunction'); % tau = 1
    assertElementsAlmostEqual(spinDnGreenFunction,...
       [0.0044057 -0.0035174 0.0013523 0.0013523 -0.0035174],...
        'relative', 0.001);
   clearvars spinDnGreenFunction;
end