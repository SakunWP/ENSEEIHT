public class Cellule {

    public int element;
    public Cellule suivante;
    public Cellule(int elem){
        this.element=elem;
        this.suivante=null;
    }

    public int getElement() {
        return element;
    }

    public void setCellule(Cellule c){
        this.suivante=c;
    }

    public Cellule getSuivante(){
        return this.suivante;
    }
}
