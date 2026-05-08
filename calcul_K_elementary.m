function Kel = calcul_K_elementary(S1,S2,S3,S4)
  %Get the local coordinates
  x1 = S1(1); y1 = S1(2); z1 = S1(3);
  x2 = S2(1); y2 = S2(2); z2 = S2(3);
  x3 = S3(1); y3 = S3(2); z3 = S3(3);
  x4 = S4(1); y4 = S4(2); z4 = S4(3);

  M = [1,x1,y1,z1;
       1,x2,y2,z2;
       1,x3,y3,z3;
       1,x4,y4,z4];
  V = det(M)/6;
  E = inv(M);

  b = E(2,:);
  c = E(3,:);
  d = E(4,:);

  Kel=zeros(4,4);

  for i = 1:4;
    for j = 1:4;
      Kel(i,j) = V*(b(i)*b(j) + c(i)*c(j) + d(i)*d(j));
    end
  end

