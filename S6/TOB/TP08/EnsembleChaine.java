public class EnsembleChaine implements Ensemble {
    public Cellule premier;
    public Cellule dernier;
    public int taille;


    public EnsembleChaine(){
        this.premier=null;
        this.dernier=null;
        this.taille=0;
    }
    @Override
    public int cardinal() {
        return taille;
    }

    @Override
    public boolean estVide() {
        return(premier==null && dernier==null);
    }

    @Override
    public boolean contient(int x) {
        if(estVide()){
            return false;
        }
        Cellule aux = this.premier;
        while(aux!=null){
            if (aux.element==x){
                return true;
            }
            aux=aux.suivante;
        }
        return false;
    }

    @Override
    public void ajouter(int x) {
        Cellule nc= new Cellule(x);
        if(!this.contient(x)){
            if (estVide()){
                this.premier=nc;
                this.dernier=nc;
                this.taille ++;
            } else {
                this.dernier.suivante=nc;
                this.dernier=nc;
                this.taille++;
            }
        }



    }

    @Override
    public void supprimer(int x) {
        Cellule courante= premier.suivante;
        Cellule precedent= premier;
        if(cardinal()==1){
            premier=null;
            dernier=null;
            taille=0;
        }
        while(courante.suivante!=null){
            if (courante.element==x){
                precedent.suivante=courante.suivante;
            }
            courante=courante.suivante;
            precedent=precedent.suivante;
        }
        if (courante.suivante==null){
            precedent.suivante=null;
            precedent=dernier;
        }

    }
}
