% function noircir_pixels_blancs (pour exercice_3.m)

function I_sans_blanc = noircir_pixels_blancs(I)

       I_sans_blanc =double(I);
       n=size(I_sans_blanc,1)
       m=size(I_sans_blanc,2)
       for i=1:n
           for j=1:m
               if I_sans_blanc(i,j,1)+I_sans_blanc(i,j,2)+I_sans_blanc(i,j,3) == 3*255
                   I_sans_blanc(i,j,1)=0;
                   I_sans_blanc(i,j,2)=0;
                   I_sans_blanc(i,j,3)=0;
               end
           end
       end
    
end
