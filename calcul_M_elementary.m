function Mel = calcul_M_elementary(S1, S2, S3)
  %Get the local coordinates
  v1 = S2 - S1;
  v2 = S3 - S1;
  aire = 0.5 * norm(cross(v1, v2));


  Mel = (aire/12) * [2, 1, 1;
                             1, 2, 1;
                             1, 1, 2];
