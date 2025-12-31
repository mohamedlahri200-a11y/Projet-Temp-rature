
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "include/Temperature.h"

// Fonction pour exporter au format Gnuplot (matrice)
void export_for_gnuplot(Grid *grid, const char *filename) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Erreur: Impossible de créer %s\n", filename);
        return;
    }
    
    // Créer une matrice temporaire
    double **matrix = (double **)malloc(grid->height * sizeof(double *));
    for (int i = 0; i < grid->height; i++) {
        matrix[i] = (double *)malloc(grid->width * sizeof(double));
        for (int j = 0; j < grid->width; j++) {
            matrix[i][j] = 0.0;
        }
    }
    
    // Remplir avec les températures
    GridPoint *current = grid->head;
    while (current != NULL) {
        if (current->y < grid->height && current->x < grid->width) {
            matrix[current->y][current->x] = current->temperature;
        }
        current = current->next;
    }
    
    // Écrire au format matrice (espace séparé)
    for (int y = 0; y < grid->height; y++) {
        for (int x = 0; x < grid->width; x++) {
            fprintf(file, "%.2f", matrix[y][x]);
            if (x < grid->width - 1) fprintf(file, " ");
        }
        fprintf(file, "\n");
    }
    
    // Libérer la mémoire
    for (int i = 0; i < grid->height; i++) {
        free(matrix[i]);
    }
    free(matrix);
    fclose(file);
}

int main() {
    printf("=== Simulation de Distribution de Température ===\n\n");
    
    // Paramètres de la simulation
    int width = 20;
    int height = 14;
    double k = 0.1;           // Conductivité thermique
    double q = 0.5;           // Source de chaleur
    double dt = 0.01;         // Pas de temps
    double dx = 1.0;          // Pas spatial
    int num_steps = 1000;     // Nombre d'itérations
    
    printf("Configuration:\n");
    printf("  Grille: %dx%d\n", width, height);
    printf("  Conductivité thermique (k): %.2f\n", k);
    printf("  Source de chaleur (q): %.2f\n", q);
    printf("  Pas de temps (dt): %.4f\n", dt);
    printf("  Pas spatial (dx): %.2f\n", dx);
    printf("  Nombre d'itérations: %d\n\n", num_steps);
    
    // Créer la grille
    Grid *grid = create_grid(width, height, k, q, dt, dx);
    if (!grid) {
        fprintf(stderr, "Échec de création de la grille\n");
        return 1;
    }

    // Ajouter des sources thermiques
    // Climatiseur (source froide) au centre
    add_heat_source(grid, width/2, height/2, -50.0, 5); // Puissance négative pour refroidir

    // Étudiants (sources de chaleur)
    add_heat_source(grid, 5, 5, 20.0, 2);
    add_heat_source(grid, 15, 5, 20.0, 2);
    add_heat_source(grid, 5, 12, 20.0, 2);
    add_heat_source(grid, 15, 12, 20.0, 2);

    // Projecteur (source de chaleur)
    add_heat_source(grid, width/2, 2, 30.0, 3);
    
    // Initialiser la grille
    printf("Initialisation de la grille...\n");
    initialize_grid(grid);
    
    // Afficher l'état initial
    printf("État initial:\n");
    print_grid(grid);
    
    // Simulation
    printf("Simulation en cours");
    clock_t start_time = clock();
    for (int step = 0; step < num_steps; step++) {
        simulate_step(grid);
        update_temperatures(grid);

        // Afficher la progression
        if ((step + 1) % 100 == 0) {
            printf(".");
            fflush(stdout);
        }
    }
    clock_t end_time = clock();
    double simulation_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;
    printf(" Terminé!\n");
    printf("Temps de simulation: %.2f secondes\n\n", simulation_time);
    
    // Afficher l'état final
    printf("État final après %d itérations:\n", num_steps);
    print_grid(grid);
    
    // Exporter les résultats
    export_temperatures(grid, "temperatures.txt");
    
    // NOUVEAU : Export pour Gnuplot
    export_for_gnuplot(grid, "Tmatrix.txt");
    printf("Données exportées vers Tmatrix.txt (format Gnuplot)\n");
    
    // Calculer quelques statistiques
    double min_temp = 1e9, max_temp = -1e9, avg_temp = 0.0;
    int count = 0;
    GridPoint *current = grid->head;
    while (current != NULL) {
        double temp = current->temperature;
        if (temp < min_temp) min_temp = temp;
        if (temp > max_temp) max_temp = temp;
        avg_temp += temp;
        count++;
        current = current->next;
    }
    avg_temp /= count;
    
    printf("\nStatistiques:\n");
    printf("  Température minimale: %.2f\n", min_temp);
    printf("  Température maximale: %.2f\n", max_temp);
    printf("  Température moyenne: %.2f\n", avg_temp);
    
    // NOUVEAU : Lancement automatique de l'interface Gnuplot
    printf("\n🚀 Lancement de l'interface graphique interactive...\n");
    system("gnuplot plot_temp.plt");
   
    // Libérer la mémoire
    free_grid(grid);
    
    return 0;
}