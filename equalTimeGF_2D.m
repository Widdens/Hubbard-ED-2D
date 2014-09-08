function output_files = equalTimeGF_2D( t, U, Lx, Ly, noOfUp, noOfDn, sector, method, commit_number, NUM_CORES )

noOfSites = Lx * Ly;
format compact;
tau = 0;

aux_file_name = strcat('aux_', num2str(Lx, '%02d'),...
                                        'x', num2str(Ly, '%02d'),...
                                        num2str(noOfUp, '%02d'),...
                                        'u',num2str(noOfDn, '%02d'),...
                                        'd_U_',num2str(U, '%4.2f'),...
                                        '_tau_',num2str(tau, '%4.2f'),...
                                        '_t_',num2str(t),...
                                        ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
fprintf('Aux file: %s.\n\n', aux_file_name)

output_files = strcat('ED_equal', num2str(Lx, '%d'),...
                                    'x', num2str(Ly, '%d'),...
                                    '_', num2str(noOfUp, '%02d'),...
                                    'u',num2str(noOfDn, '%02d'),...
                                    'd_U_',num2str(U, '%4.2f'),...
                                    '_t_',num2str(t),...
                                    ' ',datestr(now,'_yymmdd_HHMMSS'),'.mat');
fprintf('Data file: %s\n\n', output_files)
save(output_files,'noOfSites','noOfUp','noOfDn','U','tau','t', 'method', 'commit_number', '-v7.3');   

fprintf('Begin calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
fprintf('\n')

if (noOfUp < noOfSites) && (noOfDn < noOfSites)    
    fprintf('Generating firstHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
    firstHamiltonian = hubbardHamiltonian_2D( t, U, Lx, Ly, noOfUp, noOfDn, NUM_CORES );
    fprintf('Begin diagonalizing firstHamiltonian at time %s.\n', datestr(now,'yymmdd_HHMMSS'))
    [groundState,groundStateEnergy]=eigs( firstHamiltonian,...
                                               1,'sa'); %ASSUMING THAT THE HAMILTONIAN IS REAL SYMMETRIC    
    save(aux_file_name, 'groundState', '-mat', '-v7.3'); 
    aux_file_object = matfile(aux_file_name);
    
    fprintf('Done with diagonalization at time %s.\n', datestr(now,'yymmdd_HHMMSS'))                    
    
    clearvars i_f;
    clearvars firstHamiltonian groundState;
    if strcmp( sector, 'up' ) || strcmp( sector, 'both' )
        fprintf('Begin spin-up calculations at time %s.\n', datestr(now,'yymmdd_HHMMSS'))    
        spinUpGreenFunction = zeros(1, noOfSites);

        i_site = 1;
        left_wave_function_up =(load_first_Hamiltonian_ground_state(aux_file_object))' * creationOperator_2D( noOfSites, noOfUp, noOfDn , i_site, 'up' )' ;
        save(aux_file_name, '-append', 'left_wave_function_up', '-v7.3');
        clearvars left_wave_function_up;
        parfor j_site = 1:noOfSites
            right_wave_function = creationOperator_2D( noOfSites, noOfUp, noOfDn , j_site, 'up' ) * load_first_Hamiltonian_ground_state(aux_file_object);
            result = (load_wave_function_up( aux_file_object )  * right_wave_function);
            spinUpGreenFunction(j_site) = result;                
        end            
        save(output_files, '-append', 'spinUpGreenFunction', '-v7.3');
    
    end
    

end
end

function loaded_ground_state = load_first_Hamiltonian_ground_state(aux_file_object)
loaded_ground_state = aux_file_object.groundState;
end

function loaded_left_wave_function_up = load_wave_function_up( aux_file_object )
loaded_left_wave_function_up = aux_file_object.left_wave_function_up;
end

function loaded_exp_second_Hamiltonian_up = load_exp_second_Hamiltonian_up( aux_file_object )
loaded_exp_second_Hamiltonian_up = aux_file_object.exp_second_Hamiltonian_up;
end