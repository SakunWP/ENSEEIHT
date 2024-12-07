#define _GNU_SOURCE
#include "liste_noeud.h"
#include <stdlib.h>
#include <math.h>


struct Cellule {
    float distance;
    noeud_id_t noeud;
    noeud_id_t precedent;
    struct Cellule* suivant;
};
typedef struct Cellule Cellule;

struct liste_noeud_t {
    Cellule* cellule;
};

liste_noeud_t* creer_liste(){
     liste_noeud_t* liste= (liste_noeud_t*)malloc(sizeof(liste_noeud_t));
     liste->cellule =NULL;
     return liste;
}

static void detruire_cellule(Cellule** cell){
    if (*cell != NULL) {
        detruire_cellule(&((*cell)->suivant));
        free(*cell);
        *cell = NULL;
    }
}
void detruire_liste(liste_noeud_t** liste){
    detruire_cellule(&((*liste)->cellule));
    free(*liste);
    *liste = NULL;
}

bool est_vide_liste(const liste_noeud_t* liste_ptre){
    return liste_ptre->cellule == NULL;
}

static bool contient_noeud_cellule(const Cellule* cell, noeud_id_t noeud){
    if (cell == NULL) {
        return false;
    } else {
        if (cell->noeud == noeud) {
            return true;
        } else {
            return contient_noeud_cellule(cell->suivant, noeud);
        }
    }
}



bool contient_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud){
    return contient_noeud_cellule(liste->cellule, noeud);
}


static bool contient_arrete_cellule(const Cellule* cell, noeud_id_t source, noeud_id_t destination){
    if (cell == NULL) {
        return false;
    } else {
        if (cell->noeud == destination && cell->precedent == source) {
            return true;
        } else {
            return contient_arrete_cellule(cell->suivant, source, destination);
        }
    }
}

bool contient_arrete_liste(const liste_noeud_t* liste, noeud_id_t source, noeud_id_t destination){
    return contient_arrete_cellule(liste->cellule, source, destination);
}

static double distance_noeud_cellule(const Cellule* cell, noeud_id_t noeud){
    if (cell == NULL) {
        return INFINITY;
    } else {
        if (cell->noeud == noeud) {
            return cell->distance;
        } else {
            return distance_noeud_cellule(cell->suivant, noeud);
        }
    }
}

double distance_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud){
    return distance_noeud_cellule(liste->cellule, noeud);
}

static noeud_id_t precedent_noeud_cellule(const Cellule* cell, noeud_id_t noeud){
    if (cell == NULL) {
        return NO_ID;
    } else {
        if (cell->noeud == noeud) {
            return cell->precedent;
        } else {
            return precedent_noeud_cellule(cell->suivant, noeud);
        }
    }
}

noeud_id_t precedent_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud){
    return precedent_noeud_cellule(liste->cellule, noeud);
}

noeud_id_t min_noeud_liste(const liste_noeud_t* liste){
    Cellule* cell = liste->cellule;
    if (cell==NULL) {
        return NO_ID;
    } else {
        double distanceMin = cell->distance;
        noeud_id_t noeudMin = cell->noeud;
        cell = cell->suivant;
        while (cell!= NULL) {
            if (cell->distance < distanceMin) {
                distanceMin = cell->distance;
                noeudMin = cell->noeud;
            }
            cell = cell->suivant;
        }
        return noeudMin;
    }
}

void inserer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud, noeud_id_t precedent, float distance){
    Cellule* cell = (Cellule*)malloc(sizeof(Cellule));
    if (cell == NULL){
        return;
    }   
    cell->distance = distance;
    cell->noeud = noeud;
    cell->precedent = precedent;
    cell->suivant = liste->cellule;
    liste->cellule = cell;
}

void changer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud, noeud_id_t precedent, float distance){
    if(!contient_noeud_liste(liste, noeud)){
        inserer_noeud_liste(liste,noeud,precedent,distance);
    } else {
        Cellule* cell = liste->cellule;
        while (cell != NULL && cell->noeud!=noeud){
            cell = cell->suivant;
        }
        if (cell!=NULL && cell->noeud == noeud){
            cell->distance = distance;
            cell->precedent = precedent;
        }
    }
    
}

void supprimer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud){
    Cellule* cell = liste->cellule;
    if (cell == NULL){
        NULL;
    } else if (cell->noeud == noeud){
        Cellule* cell2 = cell;
        cell = cell->suivant;
        free(cell2);
        cell2 = NULL;
        liste->cellule = cell;
       
    } else {
        while(cell->suivant != NULL) {
            if (cell->suivant->noeud == noeud){
                Cellule* cell2 = cell->suivant;
                cell->suivant = cell->suivant->suivant;
                free(cell2);
                cell2 = NULL;
            } else {
                cell = cell->suivant;
            }
        }
    }

}
