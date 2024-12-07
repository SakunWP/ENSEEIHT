#include "dijkstra.h"
#include <stdlib.h>


static void algoD(const struct graphe_t* graphe, noeud_id_t source, liste_noeud_t* Visites) {
    liste_noeud_t* aVisiter = creer_liste();
    inserer_noeud_liste(aVisiter,source,NO_ID,0.0);
    noeud_id_t nc;
    noeud_id_t* voisins = (noeud_id_t*)malloc(nombre_noeuds(graphe)*sizeof(noeud_id_t));
    float distanceTotale;
    while (est_vide_liste(aVisiter) == false) {
        nc = min_noeud_liste(aVisiter);
        inserer_noeud_liste(Visites,nc,precedent_noeud_liste(aVisiter,nc), distance_noeud_liste(aVisiter,nc));
        supprimer_noeud_liste(aVisiter,nc);
        noeuds_voisins(graphe,nc,voisins);
        for (long unsigned int i=0; i<nombre_voisins(graphe,nc);i++) {
            if (contient_noeud_liste(Visites, voisins[i]) == false) {
                distanceTotale = distance_noeud_liste(Visites,nc) + noeud_distance(graphe,nc,voisins[i]);
                if (distanceTotale < distance_noeud_liste(aVisiter,voisins[i])){
                    changer_noeud_liste(aVisiter,voisins[i],nc,distanceTotale);
                }
            }
        }
    }
    free(voisins);
    voisins = NULL;
    detruire_liste(&aVisiter);
}

static void construire_chemin_vers(liste_noeud_t* Visites, liste_noeud_t* chemin, noeud_id_t n){
   
   noeud_id_t np = precedent_noeud_liste(Visites, n);
    if (np != NO_ID) {
        if (contient_noeud_liste(chemin, np) == false) {
            construire_chemin_vers(Visites, chemin, np);
            inserer_noeud_liste(chemin, np, precedent_noeud_liste(Visites, np), distance_noeud_liste(Visites, np));
        }
    }
}
/**
 * construire_chemin_vers - Construit le chemin depuis le noeud de départ donné vers le
 * noeud donné. On passe un chemin en entrée-sortie de la fonction, qui est mis à jour
 * par celle-ci.
 *
 * Le noeud de départ est caractérisé par un prédécesseur qui vaut `NO_ID`.
 *
 * Ce sous-programme fonctionne récursivement :
 *  1. Si le noeud a pour précédent `NO_ID`, on a fini (c'est le noeud de départ, le chemin de
 *     départ à départ se compose du simple noeud départ)
 *  2. Sinon, on construit le chemin du départ au noeud précédent (appel récursif)
 *  3. Dans tous les cas, on ajoute le noeud au chemin, avec les caractéristiques associées dans visites
 *
 * @param chemin [in/out] chemin dans lequel enregistrer les étapes depuis le départ vers noeud
 * @param visites [in] liste des noeuds visités créée par l'algorithme de Dijkstra
 * @param noeud noeud vers lequel on veut construire le chemin depuis le départ
 */
// TODO: construire_chemin_vers


float dijkstra(const struct graphe_t* graphe, noeud_id_t source, noeud_id_t destination, liste_noeud_t** chemin) {
    liste_noeud_t* Visites = creer_liste();    
    if (chemin != NULL) {
        *chemin = creer_liste();
        algoD(graphe, source, Visites);
        inserer_noeud_liste(*chemin, destination, precedent_noeud_liste(Visites, destination), distance_noeud_liste(Visites, destination));
        inserer_noeud_liste(*chemin, source, precedent_noeud_liste(Visites, source), distance_noeud_liste(Visites, source));
        construire_chemin_vers(Visites, *chemin, destination);
    } else {
        algoD(graphe, source, Visites);
    }
    float retour = distance_noeud_liste(Visites, destination);
    detruire_liste(&Visites);
    return retour;
}



