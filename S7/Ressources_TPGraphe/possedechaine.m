function connecte = possedechaine (A,c)

    connecte=false;
    for i=1 : length(c)-1
        if A(c(i),c(i+1))==0 
            break; 
        else A(c(i),c(i+1)) ==1
            connecte = true;
        end 
    end


    