import java.awt.Color;
public abstract class ElemSchema {
    public Color couleur;

    public ElemSchema(Color c){
        this.couleur=c;
    }

    abstract void dessiner(afficheur.Afficheur afficheur);
    abstract void afficher();

    public abstract void translater(double dx, double dy);

    public Color getCouleur(){
        return this.couleur;
    }

    public void setCouleur(Color c){
        this.couleur=c;
    }

}
