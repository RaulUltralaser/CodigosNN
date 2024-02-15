import numpy as np
from scipy.linalg import eigvals

A = np.array([[0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 1],
    [-331.915564102500, 0, 0, 0, -0.422670360000000, 0, 0, 0],
    [0, -16311.0573675625, 0, 0, 0, -3.49938415000000, 0, 0],
    [0, 0, -59760.1880134609, 0, 0, 0, -2.73794046400000, 0],
    [0, 0, 0, -140942.203675290, 0, 0, 0, -2.70304344000000]])  

eigenvalues = eigvals(A)
if np.all(np.real(eigenvalues) < 0):
    print('La matriz es de Hurwitz.')
else:
    print('La matriz no es de Hurwitz.')
