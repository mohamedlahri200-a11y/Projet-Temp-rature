#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "include/Temperature.h"

// Créer une nouvelle grille
Grid* create_grid(int width, int height, double k, double q, double dt, double dx) {
    Grid *grid = (Grid*)malloc(sizeof(Grid));
    if (!grid) {
        fprintf(stderr, "Erreur d'allocation mémoire pour la grille\n");
        return NULL;
    }
    
    grid->width = width;
    grid->height = height;
    grid->k = k;
    grid->q = q;
    grid->dt = dt;
    grid->dx = dx;
    grid->head = NULL;
    grid->sources = NULL;
    grid->num_sources = 0;

    // Créer tous les points de la grille
    GridPoint *current = NULL;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            GridPoint *point = (GridPoint*)malloc(sizeof(GridPoint));
            if (!point) {
                fprintf(stderr, "Erreur d'allocation mémoire pour un point\n");
                free_grid(grid);
                return NULL;
            }
            
            point->x = x;
            point->y = y;
            point->temperature = 0.0;
            point->new_temperature = 0.0;
            point->next = NULL;
            
            if (grid->head == NULL) {
                grid->head = point;
                current = point;
            } else {
                current->next = point;
                current = point;
            }
        }
    }
    
    return grid;
}

// Libérer la mémoire de la grille
void free_grid(Grid *grid) {
    if (!grid) return;

    GridPoint *current = grid->head;
    while (current != NULL) {
        GridPoint *next = current->next;
        free(current);
        current = next;
    }

    if (grid->sources) {
        free(grid->sources);
    }

    free(grid);
}

// Initialiser la grille avec des conditions initiales
void initialize_grid(Grid *grid) {
    if (!grid) return;
    
    GridPoint *current = grid->head;
    while (current != NULL) {
        // Diviser la grille en 4 parties de 10x10
        // Quadrant haut-gauche: source de chaleur forte
        if (current->x < 10 && current->y < 10) {
            current->temperature = 100.0;
        }
        // Quadrant haut-droite: source moyenne
        else if (current->x >= 10 && current->y < 10) {
            current->temperature = 50.0;
        }
        // Quadrant bas-gauche: source faible
        else if (current->x < 10 && current->y >= 10) {
            current->temperature = 25.0;
        }
        // Quadrant bas-droite: température initiale basse
        else {
            current->temperature = 0.0;
        }
        
        current->new_temperature = current->temperature;
        current = current->next;
    }
}

// Obtenir un point spécifique de la grille
GridPoint* get_point(Grid *grid, int x, int y) {
    if (!grid || x < 0 || x >= grid->width || y < 0 || y >= grid->height) {
        return NULL;
    }
    
    GridPoint *current = grid->head;
    while (current != NULL) {
        if (current->x == x && current->y == y) {
            return current;
        }
        current = current->next;
    }
    
    return NULL;
}

// Calculer la nouvelle température pour un point
void simulate_step(Grid *grid) {
    if (!grid) return;

    double alpha = grid->k * grid->dt / (grid->dx * grid->dx);

    GridPoint *current = grid->head;
    while (current != NULL) {
        int x = current->x;
        int y = current->y;

        // Conditions aux limites (bords isolés)
        if (x == 0 || x == grid->width - 1 || y == 0 || y == grid->height - 1) {
            current->new_temperature = current->temperature;
        } else {
            // Équation de la chaleur: ∂T/∂t = k ∇²T + Q
            GridPoint *left = get_point(grid, x - 1, y);
            GridPoint *right = get_point(grid, x + 1, y);
            GridPoint *top = get_point(grid, x, y - 1);
            GridPoint *bottom = get_point(grid, x, y + 1);

            if (left && right && top && bottom) {
                double laplacian = (left->temperature + right->temperature +
                                   top->temperature + bottom->temperature -
                                   4.0 * current->temperature);

                current->new_temperature = current->temperature +
                                          alpha * laplacian +
                                          grid->q * grid->dt;
            }
        }

        current = current->next;
    }

    // Appliquer les sources thermiques
    apply_heat_sources(grid);
}

// Mettre à jour les températures
void update_temperatures(Grid *grid) {
    if (!grid) return;
    
    GridPoint *current = grid->head;
    while (current != NULL) {
        current->temperature = current->new_temperature;
        current = current->next;
    }
}

// Exporter les températures dans un fichier
void export_temperatures(Grid *grid, const char *filename) {
    if (!grid) return;
    
    FILE *file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Erreur d'ouverture du fichier %s\n", filename);
        return;
    }
    
    // Écrire les dimensions
    fprintf(file, "%d %d\n", grid->width, grid->height);
    
    // Écrire les températures
    GridPoint *current = grid->head;
    while (current != NULL) {
        fprintf(file, "%d %d %.6f\n", current->x, current->y, current->temperature);
        current = current->next;
    }
    
    fclose(file);
    printf("Températures exportées dans %s\n", filename);
}

// Afficher la grille dans la console (pour débogage)
void print_grid(Grid *grid) {
    if (!grid) return;
    
    printf("\nGrille de températures (%dx%d):\n", grid->width, grid->height);
    for (int y = 0; y < grid->height; y++) {
        for (int x = 0; x < grid->width; x++) {
            GridPoint *point = get_point(grid, x, y);
            if (point) {
                printf("%6.1f ", point->temperature);
            }
        }
        printf("\n");
    }
    printf("\n");
}

// Ajouter une source thermique à la grille
void add_heat_source(Grid *grid, int x, int y, double power, int radius) {
    if (!grid) return;

    // Réallouer le tableau des sources
    grid->sources = (HeatSource*)realloc(grid->sources, (grid->num_sources + 1) * sizeof(HeatSource));
    if (!grid->sources) {
        fprintf(stderr, "Erreur d'allocation mémoire pour les sources thermiques\n");
        return;
    }

    // Ajouter la nouvelle source
    grid->sources[grid->num_sources].x = x;
    grid->sources[grid->num_sources].y = y;
    grid->sources[grid->num_sources].power = power;
    grid->sources[grid->num_sources].radius = radius;
    grid->sources[grid->num_sources].active = 1; // Actif par défaut

    grid->num_sources++;
}

// Activer/désactiver une source thermique
void toggle_heat_source(Grid *grid, int index) {
    if (!grid || index < 0 || index >= grid->num_sources) return;

    grid->sources[index].active = !grid->sources[index].active;
}

// Appliquer les sources thermiques à la grille
void apply_heat_sources(Grid *grid) {
    if (!grid || !grid->sources) return;

    GridPoint *current = grid->head;
    while (current != NULL) {
        for (int i = 0; i < grid->num_sources; i++) {
            if (!grid->sources[i].active) continue;

            int dx = current->x - grid->sources[i].x;
            int dy = current->y - grid->sources[i].y;
            double distance = sqrt(dx * dx + dy * dy);

            if (distance <= grid->sources[i].radius) {
                // Influence décroissante avec la distance
                double influence = 1.0 - (distance / grid->sources[i].radius);
                current->new_temperature += grid->sources[i].power * influence * grid->dt;
            }
        }

        current = current->next;
    }
}
