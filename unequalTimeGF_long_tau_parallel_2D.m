function output_files = unequalTimeGF_long_tau_parallel_2D( t, U, tau_start, tau_end, tau_step, Lx, Ly, noOfUp, noOfDn, NUM_OF_EIGEN_VALUES, sector, method, commit_number, need_profiling, NUM_CORES )
% calculate the unequal time GF by using series expansion

OPTS.issym = 1;
OPTS.isreal = 1;
noOfSites = Lx * Ly;

expanded_space_size_up = nchoosek(noOfSites,noOfUp+1)*nchoosek(noOfSites,noOfDn);
expanded_space_size_dn = nchoosek(noOfSites,noOfUp)*nchoosek(noOfSites,noOfDn + 1);
format compact;

profile_directory_name = strcat('profile_',num2str(Lx, '%02d'),...
                                        'x', num2str(Ly, '%02d'),...
                                        num2str(noOfUp, '%02d'),...
                                        'u',num2str(noOfDn, '%02d'),...
                                        'd_U_',num2str(U, '%4.2f'),...
                                        '_tau_',num2str(tau_start, '%4.2f'),...
                                        '_t_',num2str(t),...
                                        '_eigen_', num2str(NUM_OF_EIGEN_VALUES, '%04d'),...
                                    ' ',datestr(now,'_yymmdd_HHMMSS'));
                                
aux_file_name = strcat('aux_', num2str(Lx, '%02d'),...
                                        'x', num2str(Ly, '%02d'),...
                                        num2str(noOfUp, '%02d'),...
                                        'u',num2str(noOfDn, '%02d'),...
                                        'd_U_',num2str(U, '%4.2f'),...
                                        '_tau_',num2str(tau_start, '%4.2f'),...
                                        '_t_',num2str(t),...
                                        '_eigen_', num2str(NUM_OF_EIGEN_VALUES, '%04d'),...
                                        ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
fprintf('Aux file: %s.\n\n', aux_file_name)

if strcmp( need_profiling, 'Yes' )
    fprintf('Profile directory: %s.\n', profile_directory_name )
end

                                
output_files = {};
list_of_taus = tau_start:tau_step:tau_end;
for i_filename = 1:length(list_of_taus)
    tau = list_of_taus(i_filename);
    output_files{i_filename} = strcat('ED_', num2str(Lx, '%d'),...
                                        'x', num2str(Ly, '%d'),...
                                        '_', num2str(noOfUp, '%02d'),...
                                        'u',num2str(noOfDn, '%02d'),...
                                        'd_U_',num2str(U, '%4.2f'),...
                                        '_tau_',num2str(tau, '%4.2f'),...
                                        '_t_',num2str(t),...
                                        '_eigen_', num2str(NUM_OF_EIGEN_VALUES, '%04d'),...
                                        ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
    save(output_files{i_filename},'Lx', 'Ly', 'noOfUp','noOfDn','U','tau','t','method', 'commit_number', '-v7.3'); 
end
    

fprintf('Begin calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
fprintf('%03d data files:\n', length(list_of_taus))
for i_dat_files = 1:length(list_of_taus)
    disp(output_files{i_dat_files});
end

fprintf('\n')

tic;
if strcmp( need_profiling, 'Yes' )
    profile -memory on;
end

if (noOfUp < noOfSites) && (noOfDn < noOfSites)
    fprintf('Generating firstHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
    firstHamiltonian = hubbardHamiltonian_2D( t, U, Lx, Ly, noOfUp, noOfDn, NUM_CORES );
    fprintf('Begin diagonalizing firstHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
    [groundState,groundStateEnergy]=eigs( firstHamiltonian,...
                                               1,'sa'); %ASSUMING THAT THE HAMILTONIAN IS REAL SYMMETRIC    
    save(aux_file_name, 'groundState', 'groundStateEnergy', '-mat', '-v7.3'); 
    aux_file_object = matfile(aux_file_name);
    
    fprintf('Done with diagonalization at time %s.\n', datestr(now,'yymmdd_HHMMSS'))                    
    
%     for i_f = 1:length(output_files)
%         save(output_files{i_f},'groundState','groundStateEnergy', 'firstHamiltonian', '-v7.3');            
%     end     
    clearvars i_f;
    clearvars firstHamiltonian groundState;
    
%% SPIN UP:    
    if strcmp( sector, 'up' ) || strcmp( sector, 'both' )
        
        fprintf('Begin spin-up calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        if NUM_OF_EIGEN_VALUES >= expanded_space_size_up
            NUM_OF_EIGEN_VALUES_UP = expanded_space_size_up - 1;
            fprintf('NUM_EIGEN_VALUES exceeds dimension of spin-up matrix. Now set to %d\n', NUM_OF_EIGEN_VALUES_UP)
        else
            NUM_OF_EIGEN_VALUES_UP = NUM_OF_EIGEN_VALUES;
        end
        fprintf('Generating spin-up secondHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        secondHamiltonianUp = hubbardHamiltonian_2D( t, U, Lx, Ly, noOfUp+1, noOfDn, NUM_CORES );
        fprintf('Begin diagonalizing spin-up of secondHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        [eigenVectors_up, eigenValues_up] = eigs( secondHamiltonianUp, ...
                                                NUM_OF_EIGEN_VALUES_UP, 'sa', OPTS);
        eigenValues_up = diag(eigenValues_up);
        fprintf('Done with diagonalization at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        save(aux_file_name, '-append', 'eigenVectors_up', '-mat', '-v7.3'); 
%         for i_f = 1:length(output_files)
%             save(output_files{i_f},'-append','eigenValues_up','eigenVectors_up', 'secondHamiltonianUp', '-v7.3');            
%         end     
        clearvars i_f secondHamiltonianUp;

        fprintf('Begin spin-up Greens function calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))    
        fprintf('Number of workers in pool: %d\n', matlabpool('size'))
        i_site = 1;
        
        i_sum = sum(bsxfun(@times, ...
                           ( (load_first_Hamiltonian_ground_state(aux_file_object))' * ...
                                            creationOperator_2D( noOfSites, noOfUp, noOfDn , i_site, 'up' )' )' , ...
                           eigenVectors_up...
                           )...
                    );    
        up_gf_temp = zeros(length(list_of_taus) + 1, 1);
        clearvars eigenVectors_up
        
        parfor j_site = 1:noOfSites
            j_sum = sum(bsxfun(@times, ...
                               ( creationOperator_2D( noOfSites, noOfUp, noOfDn , j_site, 'up' ) * ...
                                                load_first_Hamiltonian_ground_state(aux_file_object) ), ...
                               load_eigenVectors_up(aux_file_object) ...
                               )...
                        );            
            i_sum_times_j_sum = i_sum.*j_sum;                        
            aaa = tau_start:tau_step:tau_end;
            bbb = groundStateEnergy - eigenValues_up;
            expo_factor = exp( bbb * aaa)';
            ress = sum(bsxfun(@times, i_sum_times_j_sum,expo_factor), 2);            
            resulting_vector = zeros( length(list_of_taus) + 1, 1);
            resulting_vector( 1) = j_site;
            for i_f = 1:length(output_files)
                resulting_vector(i_f + 1) = ress(i_f);
            end
            up_gf_temp = [up_gf_temp resulting_vector];
            fprintf('    Worker %2d: End.\n', j_site)
        end
        
        fprintf('Done with spin-up Greens function calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))        
        up_gf_temp = up_gf_temp(:, 2:end);
        up_gf_temp = sortrows( up_gf_temp')';
        up_gf_temp = up_gf_temp(2:end, :);
        
        
        for t_tau = 1:length(output_files)
            spinUpGreenFunction = up_gf_temp(t_tau,:);   
            save(output_files{t_tau},'-append', 'spinUpGreenFunction', 'NUM_OF_EIGEN_VALUES_UP', '-v7.3');
        end               

    end
%% SPIN DOWN:           
        
    if strcmp( sector, 'dn' ) || strcmp( sector, 'both' )        
        if NUM_OF_EIGEN_VALUES >= expanded_space_size_dn
            NUM_OF_EIGEN_VALUES_DN = expanded_space_size_dn - 1;
            fprintf('NUM_EIGEN_VALUES exceeds dimension of spin-down matrix. Now set to %d\n', NUM_OF_EIGEN_VALUES_DN)
        else
            NUM_OF_EIGEN_VALUES_DN = NUM_OF_EIGEN_VALUES;
        end
        fprintf('Generating spin-down secondHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        secondHamiltonianDn = hubbardHamiltonian_2D( t, U, Lx, Ly, noOfUp, noOfDn + 1, NUM_CORES );
        fprintf('Begin diagonalizing spin-down of secondHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        [eigenVectors_dn, eigenValues_dn] = eigs( secondHamiltonianDn, ...
                                                NUM_OF_EIGEN_VALUES_DN, 'sa', OPTS);
        eigenValues_dn = diag(eigenValues_dn);
        fprintf('Done with diagonalization at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
        save(aux_file_name, '-append', 'eigenVectors_dn', '-mat', '-v7.3');
%         for i_f = 1:length(output_files)
%             save(output_files{i_f},'-append','eigenValues_dn','eigenVectors_dn', 'secondHamiltonianDn', '-v7.3');            
%         end     
        clearvars i_f secondHamiltonianDn;

        fprintf('Begin spin-down Greens function calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))    
        fprintf('Number of workers in pool: %d\n', matlabpool('size'))
        i_site = 1;        
        i_sum = sum(bsxfun(@times, ...
                           ( (load_first_Hamiltonian_ground_state(aux_file_object))' * ...
                                            creationOperator_2D( noOfSites, noOfUp, noOfDn , i_site, 'dn' )' )' , ...
                           eigenVectors_dn...
                           )...
                    );    
        dn_gf_temp = zeros(length(list_of_taus) + 1, 1);
        clearvars eigenVectors_dn
        
        parfor j_site = 1:noOfSites
            j_sum = sum(bsxfun(@times, ...
                               ( creationOperator_2D( noOfSites, noOfUp, noOfDn , j_site, 'dn' ) * ...
                                                load_first_Hamiltonian_ground_state(aux_file_object) ), ...
                               load_eigenVectors_dn(aux_file_object) ...
                               )...
                        );            
            i_sum_times_j_sum = i_sum.*j_sum;                        
            aaa = tau_start:tau_step:tau_end;
            bbb = groundStateEnergy - eigenValues_dn;
            expo_factor = exp( bbb * aaa)';
            ress = sum(bsxfun(@times, i_sum_times_j_sum,expo_factor), 2);            
            resulting_vector = zeros( length(list_of_taus) + 1, 1);
            resulting_vector( 1) = j_site;
            for i_f = 1:length(output_files)
                resulting_vector(i_f + 1) = ress(i_f);
            end
            dn_gf_temp = [dn_gf_temp resulting_vector];
            fprintf('    Worker %2d: End.\n', j_site)
        end
        
        fprintf('Done with spin-down Greens function calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))        
        dn_gf_temp = dn_gf_temp(:, 2:end);
        dn_gf_temp = sortrows( dn_gf_temp')';
        dn_gf_temp = dn_gf_temp(2:end, :);
        
        
        for t_tau = 1:length(output_files)
            spinDnGreenFunction = dn_gf_temp(t_tau,:);   
            save(output_files{t_tau},'-append', 'spinDnGreenFunction', 'NUM_OF_EIGEN_VALUES_DN', '-v7.3');
        end               

    end
else
    error('Error: cannot apply creation operator when number of electrons = number of sites');
end

time=toc

if strcmp( need_profiling, 'Yes' )
    profile off;
end

for i_f = 1:length(output_files)
    tau = list_of_taus(i_f);
    save(output_files{i_f},'-append', 'time', '-v7.3');            
end     
fprintf('Finish all calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))

if strcmp( need_profiling, 'Yes' )
    profsave(profile('info'), profile_directory_name);
end

delete( aux_file_name);
end

function loaded_ground_state = load_first_Hamiltonian_ground_state(aux_file_object)
loaded_ground_state = aux_file_object.groundState;
end

function loaded_eigenVectors_up = load_eigenVectors_up(aux_file_object)
loaded_eigenVectors_up = aux_file_object.eigenVectors_up;
end

function loaded_eigenVectors_dn = load_eigenVectors_dn(aux_file_object)
loaded_eigenVectors_dn = aux_file_object.eigenVectors_dn;
end