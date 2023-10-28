% ------------------------------------------------------------------- 
% Script for comparing various KF implementation methods.
% Authors: Maria Kulikova:  kulikova dot maria at yahoo dot com     
% ------------------------------------------------------------------- 

clear all; close all; clc; warning off;

% ---- Parameters that you may change ------
MC_runs  = 10;                 % Number of Monte Carlo runs
Delta    = 2;                  % Sampling interval Delta = t_{k}-t_{k-1}
N_total  = 200;                % Discrete-time instances
noise_type = @noise_gauss;     % Type of uncertainties 

% ----Load  Model to be examined ----
p = pwd; cd('Models/'); [Fsys,Gsys,Qsys,Hsys,Rsys,P0,x0] = Model_satellite; cd(p); % e.g. see also Model_electrocardiogram, Model_navigation or add your own

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

% --- Monte Carlo runs ----

 for exp_number = 1:MC_runs  
     fprintf(1,'Simulation #%d: \n',exp_number); 

     % ----Simulate the system to get "true" state and measurements  ----
     [DT,EX,yk] = Simulate_Measurements(noise_type,{Fsys,Gsys,Qsys,Hsys,Rsys},{x0,P0},N_total);
      DST = DT(:,1:Delta:end);                             % Discrete time points of sampling interval
      Exact_StateVectorX = EX(:,1:Delta:end);              % Exact X at the points of sampling interval
      Measurements = yk(:,1:Delta:end);                    % Data come at the points of sampling intervals

     % ----Solve the inverse problem, i.e. perform the filtering process
     for i=1:Number_Methods;
       filters{i}.legend = func2str(handle_funs{i}); 
       tstart = tic;
       [LLF,predX,predDP] = feval(handle_funs{i},{Fsys,Gsys,Qsys,Hsys,Rsys},{x0,P0},Measurements);
       ElapsedTime = toc(tstart);
       filters{i}.predX(:,:,exp_number)  = predX;
       filters{i}.predDP(:,:,exp_number) = predDP;
       filters{i}.trueX(:,:,exp_number) = Exact_StateVectorX;
       filters{i}.DST(:,:,exp_number)   = DST;
       filters{i}.yk(:,:,exp_number)    = Measurements;
       filters{i}.AE(:,:,exp_number)    = abs(predX(:,1:end-1)-Exact_StateVectorX); 
       filters{i}.Time(exp_number)      = ElapsedTime;
       filters{i}.neg_LLF(exp_number)   = LLF;
    end;
end;

% --- Estimation errors computation  ----
for i=1:Number_Methods;
   val1 = mean((filters{i}.AE).^2,3);             % mean by Monte Carlo runs 
   filters{i}.RMSE = sqrt(mean(val1,2));          % mean by time, i.e. RMSE in each component
end;

% --- Print the results  
fprintf(1,'--------------------- \n'); fprintf(1,'  Filter Implementations:\t');       
for i=1:size(P0,1), fprintf(1,'RMSE_x(%d)\t',i); end; fprintf(1,'||RMSE||_2 \t av.CPU (s) \t neg LLF \n');
for i=1:Number_Methods
 fprintf(1,'%d.%22s\t ',i,filters{i}.legend); 
 fprintf(1,'%8.4f\t',filters{i}.RMSE); fprintf(1,'%8.4f\t%8.4f\t%8.4f \n',norm(filters{i}.RMSE,2),mean(filters{i}.Time),filters{i}.neg_LLF(1));
end;

% --- Illustrate, if you wish (ensure that all related entries coincide)
 Illustrate_XP(filters(1:Number_Methods));  % One may illustrate all filters or part of them  


