% ------------------------------------------------------------------- 
% Script for comparing various KF implementation methods and log LF evaluation.
% Authors: Maria Kulikova:  kulikova dot maria at yahoo dot com     
% ------------------------------------------------------------------- 

clear all; close all; clc; warning off;

% ---- Parameters that you may change ------
Delta    = 2;                  % Sampling interval Delta = t_{k}-t_{k-1}
N_total  = 120;                % Discrete-time instances
noise_type = @noise_gauss;     % Type of uncertainties 
true_tau = 10;                 %'true' value for the system parameter
grid4tau = 3:1:35;             % grid for parameter value


% ----Load  Model to be examined ----
p = pwd; cd('Models/'); [Fsym,Gsym,Qsym,Hsym,Rsym,P0sym,x0sym,parameters] = PModel_simple(Delta); cd(p); % e.g. see also Model_electrocardiogram, Model_navigation or add your own

%--- Filtering methods to be examined ----
p = pwd; cd('Methods-KF'); 
    % ----- Conventional algorithms --------
    handle_funs{1} = @Riccati_KF_standard;       % Conventional implementation by Kalman (1960)
    handle_funs{2} = @Chandrasekhar_KF1;         % Conventional Chandrasekhar-based by Morf et.al. (1974)
    handle_funs{3} = @Chandrasekhar_KF2;         % Conventional Chandrasekhar-based by Morf et.al. (1974)
    handle_funs{4} = @Chandrasekhar_KF3;         % Conventional Chandrasekhar-based by Morf et.al. (1974)
    handle_funs{5} = @Chandrasekhar_KF4;         % Conventional Chandrasekhar-based by Morf et.al. (1974)

   % ----- Cholesky-based methods --------------------
     handle_funs{6} = @Riccati_KF_SRCF_QL;     % Square-Root Covariance Filter, lower triangular factors
     handle_funs{7} = @Riccati_KF_SRCF_QR;     % Square-Root Covariance Filter, upper triangular factors
     handle_funs{8} = @Riccati_KF_eSRCF_QL;    % Extended Square-Root Covariance Filter by Park & Kailath (1995), lower triangular factors
     handle_funs{9} = @Riccati_KF_eSRCF_QR;    % Extended Square-Root Covariance Filter, upper triangular factors
   % you can add any other method in the same way;  
cd(p); 

 Number_Methods = size(handle_funs,2);       % number of methods to be tested
 filters        = cell(Number_Methods,1);    % prelocate for efficiency

  % ----Simulate the system to get "true" state and measurements  ----
  % substitute the "True" parameter value 
  [F,G,Q,H,R,P0,x0]    = Substitute(parameters,true_tau,Fsym,Gsym,Qsym,Hsym,Rsym,P0sym,x0sym);
  [DT,EX,yk] = Simulate_Measurements(noise_type,{F,G,Q,H,R},{x0,P0},N_total);
      DST = DT(:,1:Delta:end);                             % Discrete time points of sampling interval
      Exact_StateVectorX = EX(:,1:Delta:end);              % Exact X at the points of sampling interval
      Measurements = yk(:,1:Delta:end);                    % Data come at the points of sampling intervals

 for exp_number = 1:length(grid4tau)  
     current_tau = grid4tau(exp_number);
     fprintf(1,'Simulation tau = %8.4f: \n',current_tau); 
     [Fi,Gi,Qi,Hi,Ri,P0i,x0i]    = Substitute(parameters,current_tau,Fsym,Gsym,Qsym,Hsym,Rsym,P0sym,x0sym);


     % ----Solve the inverse problem, i.e. perform the filtering process and compute LLF
     for i=1:Number_Methods;
       filters{i}.legend = func2str(handle_funs{i}); 
       tstart = tic;
       [LLF,predX,predDP] =  feval(handle_funs{i},{Fi,Gi,Qi,Hi,Ri},{x0i,P0i},Measurements);
       ElapsedTime = toc(tstart);
       filters{i}.predX(:,:,exp_number)  = predX;
       filters{i}.predDP(:,:,exp_number) = predDP;
       filters{i}.trueX(:,:,exp_number) = Exact_StateVectorX;
       filters{i}.DST(:,:,exp_number)   = DST;
       filters{i}.yk(:,:,exp_number)    = Measurements;
       filters{i}.AE(:,:,exp_number)    = abs(predX(:,1:end-1)-Exact_StateVectorX); 
       filters{i}.Time(exp_number)      = ElapsedTime;
       filters{i}.neg_LLF(exp_number)   = LLF;
       filters{i}.grid(exp_number)      = current_tau; % save the grid for parameters 

    end;
end;
fprintf(1,' DONE \n \n');
Illustrate_LLF(filters);
