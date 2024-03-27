# Condensed Kalman filter implementation methods 
This repository contains MATLAB functions for various discrete-time Kalman filter (KF) implementation methods. They are given in a priori form (the predicted form), i.e., the first measurement is available at the initial step and, hence, the measurement update stage comes first. All such methods can be written in the so-called condensed form, i.e., without division on the time and measurement updates. Thus, only condensed algorithms are mentioned in this repository. Two-stage implementations can be easily obtained from algorithms <a href="https://github.com/Maria-Kulikova/KF-a-posteriori">here</a>.   

## References
Each code (implementation method) includes the exact reference where the particular algorithm was published. 
If you use these codes in your research, please, cite the corresponding articles mentioned in the codes or in the list below.  

## Remark
The codes have been presented here for their instructional value only. They have been tested with care but are not guaranteed to be free of error and, hence, they should not be relied on as the sole basis to solve problems. 

# Steps to reproduce
- `Test_KFs` is the script that performs Monte Carlo runs for solving filtering problem by various KF implementations.
- `Test_LLF` is the script for calculating the negative log LF by various filtering algorithms. 
- `Illustrate_XP` is the script that illustrates the obtained estimates and the diagonal entries of the error covariance matrix (over time). You can find its call at the end of the script above, which is commented. Just delete this comment sign.
- `Illustrate_LLF` is the script that illustrates the negative log LF calculated by various filtering algorithms. 
- `Simulate_Measurements` stands for simulating the state-space model and generating the measurements for the filtering methods.

When the state is estimated, the resulted errors should be the same for all implementation methods because they are mathematically equivalent to each other. Their numerical properties differ, but the ill-conditioned test examples are not given here. 

# List of the KF implementation methods
## Riccati recursion-based KF implementation methods:
- Conventional algorithms:
  - `Riccati_KF_standard` is the Conventional implementation in one-step condensed form
- Square-root Cholesky factorization-based methods:
  - `Riccati_KF_SRCF_QL`   is the Square-Root Covariance Filter (SRCF) with lower triangular factors by Park & Kailath (1995), <a href="http://doi.org/10.1109/9.384225">DOI</a> 
  - `Riccati_KF_SRCF_QR`   is the SRCF with upper triangular factors by Park & Kailath (1995), <a href="http://doi.org/10.1109/9.384225">DOI</a> 
  - `Riccati_KF_eSRCF_QL`  is the Extended SRCF with lower triangular factors by Park & Kailath (1995), <a href="http://doi.org/10.1109/9.384225">DOI</a> 
  - `Riccati_KF_eSRCF_QR`  is the Extended SRCF with upper triangular factors by Park & Kailath (1995), <a href="http://doi.org/10.1109/9.384225">DOI</a> 
   
## Chandrasekhar recursion-based KF implementation methods:
- Conventional algorithms:
  - `Chandrasekhar_KF1` is the Conventional implementation by Morf et.al. (1974), <a href="http://doi.org/10.1109/TAC.1974.1100576">DOI</a>
  - `Chandrasekhar_KF2` is the Conventional implementation by Morf et.al. (1974), <a href="http://doi.org/10.1109/TAC.1974.1100576">DOI</a>
  - `Chandrasekhar_KF3` is the Conventional implementation by Morf et.al. (1974), <a href="http://doi.org/10.1109/TAC.1974.1100576">DOI</a>
  - `Chandrasekhar_KF4` is the Conventional implementation by Morf et.al. (1974), <a href="http://doi.org/10.1109/TAC.1974.1100576">DOI</a>
  
[^1]: Park, P. and Kailath, T. (1995) New square-root algorithms for Kalman filtering. IEEE Transactions on Automatic Control. 40(5):895-9.  <a href="http://doi.org/10.1109/9.384225">DOI</a> 
