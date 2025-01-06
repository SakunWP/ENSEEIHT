
N=50;
bits = randi(2, 1, N) - 1;
trellis=poly2trellis(3, [5 7]);
donnees_codees=convenc(bits, trellis);
tbdepth = 34;
decodedData = vitdec(donnees_codees,trellis,tbdepth,'trunc','hard');
